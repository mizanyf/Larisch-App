# TASKS — Checklist Pengembangan Larisch (`larisch_app`)

Checklist pengerjaan bertahap untuk aplikasi mobile **Larisch**.  
**Prioritas Utama:** Aplikasi Mobile Flutter MVP -> **Tahap Terakhir:** Website Marketing Landing Page.

---

## Phase 0 — Dokumentasi & Persiapan Project
- [x] Inisialisasi project Flutter (`c:\larisch_app`)
- [x] Menempatkan logo resmi di `assets/logo/larisch.png`
- [x] Menyusun dokumentasi fondasi (`README.md`, `PRD.md`, `DESIGN.md`, `ARCHITECTURE.md`, `AGENTS.md`, `TASKS.md`)
- [x] Daftarkan `assets/logo/larisch.png` dan dependencies (`drift`, `drift_flutter`, `flutter_riverpod`, `go_router`, `fl_chart`, `intl`, `file_picker`, `share_plus`, `path_provider`, `google_fonts`) di `pubspec.yaml`
- [x] Verifikasi Flutter SDK (`3.47.5` / Dart `3.13.4`) & `flutter pub get` berjalan bersih

---

## Phase 1 — Design Tokens & Fondasi Core
- [x] Buat Design Tokens di `lib/core/theme/` (`app_colors.dart`, `app_typography.dart`, `app_spacing.dart`, `app_radius.dart`, `app_theme.dart`, `theme.dart`) sesuai `DESIGN.md`
- [x] Buat formatter utilitas (`currency_formatter.dart` untuk format `Rp` integer & `date_formatter.dart` locale `id_ID`) + unit test
- [x] Buat komponen global reusable di `lib/core/widgets/`:
  - [x] `LarischLogoBadge`
  - [x] `FloatingBottomNav` (4 tab + FAB `+` biru terpisah)
  - [x] `TransactionListTile`
  - [x] `AccountSelectorChips` (Tunai, QRIS, Rekening Bank)
  - [x] `EmptyStateView`

---

## Phase 2 — Database Lokal (Drift SQLite) & Domain Logic
- [x] Definisikan tabel Drift (`business_profiles`, `cash_accounts`, `categories`, `transactions`) di `lib/core/database/`
- [x] Seed 3 akun kas manual (`Tunai`, `QRIS`, `Rekening Bank`) & kategori bawaan pemasukan/pengeluaran saat pertama kali buka aplikasi
- [x] Jalankan `dart run build_runner build` untuk generate `app_database.g.dart`
- [x] Implementasikan `FinanceRepository`, `FinanceCalculator`, dan Riverpod providers (`finance_providers.dart`) untuk:
  - [x] Perhitungan dinamis **Saldo per Akun Kas** & **Total Saldo Kas**
  - [x] Perhitungan dinamis **Laba Bersih**, **Total Pemasukan**, **Total Pengeluaran**, dan **Margin (%)** per periode
- [x] Tulis unit test perhitungan saldo (`test/core/finance_database_test.dart`: tambah, edit, hapus, pindah akun, validasi `<= 0`, periode kosong)

---

## Phase 3 — Onboarding & Navigasi Utama
- [x] Setup `GoRouter` (`app_router.dart`, `app_routes.dart`) & `MainShellScreen` (4 tab + FAB `+`) dengan redirect otomatis user baru vs user lama
- [x] `00 - Splash Screen` (logo-only `assets/logo/larisch.png` di latar `#000000`)
- [x] `01 - Welcome Screen`
- [x] `02 - Setup Profil Usaha`
- [x] `03 - Setup Saldo Awal Manual` (Tunai, QRIS, Rekening Bank)
- [x] `04 - Onboarding Success` -> masuk ke Beranda (+ widget test end-to-end `test/features/onboarding_flow_test.dart`)

---

## Phase 4 — Beranda & Pencatatan Transaksi
- [x] `Screen 1 - Beranda` (`beranda_screen.dart`: dark header, Total Saldo Kas + 3 akun, white sheet Laba Bersih, Quick Actions `+ Pemasukan` / `- Pengeluaran`, Transaksi Terbaru, month picker)
- [x] `Empty State Beranda` untuk user baru
- [x] `Screen 3 - Catat Transaksi` (`catat_transaksi_screen.dart`: mode Pemasukan & Pengeluaran + Edit, validasi nominal `<= 0`, pilih akun, kategori, tanggal/jam, catatan, feedback SnackBar)
- [x] `Screen 2 - Transaksi` (`transaksi_screen.dart`: search, filter jenis/akun/bulan, ringkasan cashflow, daftar grouped by date, `Empty State Transaksi`)
- [x] `Detail Transaksi`, `Edit Transaksi`, dan `Konfirmasi Hapus Transaksi` (`detail_transaksi_screen.dart` + widget test `test/features/transactions_flow_test.dart`)

---

## Phase 5 — Laporan Keuangan & Profil / Pengaturan
- [x] `Screen 4 - Laporan Keuangan` (`laporan_screen.dart`: filter Harian/Mingguan/Bulanan, Laba Bersih & Margin, grafik tren `fl_chart`, breakdown pengeluaran per kategori, `Empty State Laporan`)
- [x] `Screen 5 - Profil` (`profil_screen.dart`: kartu identitas usaha + menu pengaturan)
- [x] `Edit Profil Usaha` & `Atur Saldo Awal Manual`
- [x] `Kelola Kategori` (`kelola_kategori_screen.dart`: tambah, edit, arsipkan/hapus kategori)
- [x] `Backup Data Lokal` (`local_backup_service.dart` + `backup_restore_screen.dart`: export `.json` sesuai skema di `ARCHITECTURE.md`)
- [x] `Restore Data Lokal` (validasi & import `.json` dalam transaksi SQLite atomik + pratinjau konfirmasi)
- [x] `Reset Data` (dialog konfirmasi ganda -> kembali ke Welcome) + unit & widget tests (`local_backup_test.dart`, `reports_profile_test.dart`)

---

## Phase 6 — QA, Verifikasi Offline & Build APK
- [ ] Uji seluruh flow di mode offline (tanpa koneksi internet)
- [ ] Uji validasi edge case (nominal besar, nama usaha panjang, restore file rusak/invalid)
- [ ] Pastikan `flutter analyze` dan `flutter test` lolos 100% tanpa error
- [ ] Build APK release (`flutter build apk --release`) dan uji langsung di perangkat Android

---

## Phase 7 — Website Marketing Landing Page (Terakhir)
- [ ] Bangun landing page resmi Larisch berdasarkan **Page 3 (`🌐 Website — Larisch Landing Page`)** di FigCraft setelah aplikasi mobile MVP selesai
- [ ] Sertakan screenshot real & tautan unduhan aplikasi Larisch
