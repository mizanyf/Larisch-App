import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'app_database.dart';
import 'seed_data.dart';

/// Parsed metadata preview shown to the user before confirming a local restore.
class BackupPreview {
  const BackupPreview({
    required this.businessName,
    required this.businessType,
    required this.exportedAt,
    required this.categoryCount,
    required this.transactionCount,
    required this.rawMap,
  });

  final String businessName;
  final String? businessType;
  final DateTime exportedAt;
  final int categoryCount;
  final int transactionCount;
  final Map<String, dynamic> rawMap;
}

/// 100% local JSON Backup & Restore service (zero cloud/server dependencies).
class LocalBackupService {
  const LocalBackupService(this._db);

  final AppDatabase _db;

  static const String appIdentifier = 'Larisch';
  static const int currentSchemaVersion = 1;

  /// Serializes all local Larisch tables into a deterministic JSON string.
  Future<String> exportToJsonString() async {
    final profile = await (_db.select(
      _db.businessProfiles,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    final accounts = await (_db.select(
      _db.cashAccounts,
    )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
    final categories = await (_db.select(
      _db.categories,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
    final transactions = await (_db.select(
      _db.transactions,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

    final payload = <String, dynamic>{
      'app': appIdentifier,
      'schemaVersion': currentSchemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'businessProfile': profile == null
          ? null
          : {
              'businessName': profile.businessName,
              'businessType': profile.businessType,
              'onboardingCompleted': profile.onboardingCompleted,
            },
      'cashAccounts': accounts
          .map(
            (a) => {
              'id': a.id,
              'name': a.name,
              'initialBalance': a.initialBalance,
              'sortOrder': a.sortOrder,
            },
          )
          .toList(),
      'categories': categories
          .map(
            (c) => {
              'id': c.id,
              'name': c.name,
              'type': c.type,
              'iconKey': c.iconKey,
              'isDefault': c.isDefault,
              'isArchived': c.isArchived,
            },
          )
          .toList(),
      'transactions': transactions
          .map(
            (tx) => {
              'id': tx.id,
              'type': tx.type,
              'amount': tx.amount,
              'accountId': tx.accountId,
              'categoryId': tx.categoryId,
              'note': tx.note,
              'transactionDate': tx.transactionDate.toIso8601String(),
            },
          )
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Writes backup JSON to a local file and opens the OS share/save sheet.
  /// Returns the generated filename.
  Future<String> exportAndShareFile() async {
    final jsonContent = await exportToJsonString();
    final now = DateTime.now();
    final stamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    final fileName = 'larisch_backup_$stamp.json';

    if (kIsWeb) {
      final bytes = Uint8List.fromList(utf8.encode(jsonContent));
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              name: fileName,
              mimeType: 'application/json',
            ),
          ],
          text: 'Backup lokal Larisch ($fileName)',
        ),
      );
      return fileName;
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}$fileName');
    await file.writeAsString(jsonContent, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        text: 'Backup lokal Larisch ($fileName)',
      ),
    );
    return fileName;
  }

  /// Validates JSON structure, app identifier, schema version, and FK integrity.
  BackupPreview parseAndValidate(String jsonContent) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(jsonContent);
    } catch (_) {
      throw const FormatException(
        'File backup tidak valid atau rusak (bukan format JSON).',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Struktur file backup Larisch tidak valid.');
    }

    if (decoded['app'] != appIdentifier) {
      throw const FormatException(
        'File ini bukan file backup resmi aplikasi Larisch.',
      );
    }

    final schemaVersion = decoded['schemaVersion'];
    if (schemaVersion is! int || schemaVersion > currentSchemaVersion) {
      throw const FormatException(
        'Versi skema backup tidak didukung oleh versi aplikasi ini.',
      );
    }

    final accounts = decoded['cashAccounts'];
    final categories = decoded['categories'];
    final transactions = decoded['transactions'];
    if (accounts is! List || categories is! List || transactions is! List) {
      throw const FormatException('Data tabel pada file backup tidak lengkap.');
    }

    final validCategoryIds = <int>{};
    for (final rawCat in categories) {
      if (rawCat is! Map<String, dynamic> || rawCat['id'] is! int) {
        throw const FormatException('Data kategori pada backup tidak valid.');
      }
      validCategoryIds.add(rawCat['id'] as int);
    }

    for (final rawTx in transactions) {
      if (rawTx is! Map<String, dynamic>) {
        throw const FormatException('Data transaksi pada backup tidak valid.');
      }
      final amount = rawTx['amount'];
      final accountId = rawTx['accountId'];
      final categoryId = rawTx['categoryId'];
      final type = rawTx['type'];
      if (amount is! int || amount <= 0) {
        throw const FormatException(
          'Terdapat nominal transaksi tidak valid pada file backup.',
        );
      }
      if (type != TransactionTypes.income && type != TransactionTypes.expense) {
        throw const FormatException(
          'Terdapat jenis transaksi tidak valid pada file backup.',
        );
      }
      if (accountId is! String || !AccountIds.all.contains(accountId)) {
        throw const FormatException(
          'Terdapat akun kas tidak dikenal pada file backup.',
        );
      }
      if (categoryId is! int || !validCategoryIds.contains(categoryId)) {
        throw const FormatException(
          'Terdapat referensi kategori tidak ditemukan pada file backup.',
        );
      }
    }

    final rawProfile = decoded['businessProfile'];
    final businessName =
        (rawProfile is Map<String, dynamic> &&
            rawProfile['businessName'] is String)
        ? rawProfile['businessName'] as String
        : 'Usaha Saya';
    final businessType =
        (rawProfile is Map<String, dynamic> &&
            rawProfile['businessType'] is String)
        ? rawProfile['businessType'] as String
        : null;

    final exportedAtRaw = decoded['exportedAt'];
    final exportedAt = exportedAtRaw is String
        ? (DateTime.tryParse(exportedAtRaw) ?? DateTime.now())
        : DateTime.now();

    return BackupPreview(
      businessName: businessName,
      businessType: businessType,
      exportedAt: exportedAt,
      categoryCount: categories.length,
      transactionCount: transactions.length,
      rawMap: decoded,
    );
  }

  /// Atomically replaces all local data with validated backup data inside a
  /// single SQLite transaction (rolls back automatically on any error).
  Future<BackupPreview> restoreFromJsonString(String jsonContent) async {
    final preview = parseAndValidate(jsonContent);
    final data = preview.rawMap;
    final now = DateTime.now();

    await _db.transaction(() async {
      await _db.delete(_db.transactions).go();
      await _db.delete(_db.categories).go();
      await _db.delete(_db.cashAccounts).go();
      await _db.delete(_db.businessProfiles).go();

      // 1. Restore Business Profile
      final rawProfile = data['businessProfile'];
      if (rawProfile is Map<String, dynamic>) {
        await _db.into(_db.businessProfiles).insert(
          BusinessProfilesCompanion.insert(
            id: const Value(1),
            businessName: (rawProfile['businessName'] as String?) ?? 'Usaha Saya',
            businessType: Value(rawProfile['businessType'] as String?),
            onboardingCompleted: Value(
              (rawProfile['onboardingCompleted'] as bool?) ?? true,
            ),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      }

      // 2. Restore 3 Manual Cash Accounts
      final rawAccounts = data['cashAccounts'] as List<dynamic>;
      final accountById = <String, Map<String, dynamic>>{};
      for (final item in rawAccounts) {
        if (item is Map<String, dynamic> && item['id'] is String) {
          accountById[item['id'] as String] = item;
        }
      }

      final defaultAccounts = DatabaseSeedData.defaultAccounts();
      await _db.batch((b) {
        for (final def in defaultAccounts) {
          final id = def.id.value;
          final saved = accountById[id];
          b.insert(
            _db.cashAccounts,
            CashAccountsCompanion.insert(
              id: id,
              name: (saved?['name'] as String?) ?? def.name.value,
              initialBalance: Value((saved?['initialBalance'] as int?) ?? 0),
              sortOrder: (saved?['sortOrder'] as int?) ?? def.sortOrder.value,
              updatedAt: Value(now),
            ),
          );
        }
      });

      // 3. Restore Categories preserving exact IDs
      final rawCategories = data['categories'] as List<dynamic>;
      await _db.batch((b) {
        for (final item in rawCategories) {
          final map = item as Map<String, dynamic>;
          b.insert(
            _db.categories,
            CategoriesCompanion.insert(
              id: Value(map['id'] as int),
              name: map['name'] as String,
              type: map['type'] as String,
              iconKey: (map['iconKey'] as String?) ?? 'label',
              isDefault: Value((map['isDefault'] as bool?) ?? false),
              isArchived: Value((map['isArchived'] as bool?) ?? false),
            ),
          );
        }
      });

      // 4. Restore Transactions
      final rawTransactions = data['transactions'] as List<dynamic>;
      await _db.batch((b) {
        for (final item in rawTransactions) {
          final map = item as Map<String, dynamic>;
          final txDate =
              DateTime.tryParse((map['transactionDate'] as String?) ?? '') ??
              now;
          b.insert(
            _db.transactions,
            TransactionsCompanion.insert(
              type: map['type'] as String,
              amount: map['amount'] as int,
              accountId: map['accountId'] as String,
              categoryId: map['categoryId'] as int,
              note: Value(map['note'] as String?),
              transactionDate: txDate,
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
        }
      });
    });

    return preview;
  }
}
