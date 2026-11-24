# Larisch — Aplikasi Pembukuan Keuangan UMKM (Flutter)

**Larisch** (`larisch_app`) adalah aplikasi pembukuan keuangan harian **offline-first** untuk UMKM Indonesia. Dibangun menggunakan **Flutter**, **Drift (SQLite lokal)**, **Riverpod**, dan **GoRouter**.

---

## Fitur Utama MVP

- **100% Offline & Penyimpanan Lokal:** Tanpa login cloud, tanpa server, data tersimpan langsung di perangkat.
- **3 Akun Kas Manual:** Pemantauan saldo **Tunai**, **QRIS**, dan **Rekening Bank** secara terpisah.
- **Pemisahan Metrik Keuangan:** Memisahkan secara jelas antara **Total Saldo Kas** dan **Laba Bersih** periode.
- **Pencatatan Cepat:** Catat pemasukan & pengeluaran dengan validasi nominal, kategori, tanggal, dan catatan.
- **Laporan Keuangan Sederhana:** Ringkasan Harian/Mingguan/Bulanan, margin laba, grafik tren, dan breakdown kategori.
- **Backup & Restore Lokal:** Export dan import file `.json` langsung di perangkat.

---

## Dokumentasi Project

- [PRD.md](./PRD.md) — Kebutuhan produk, aturan bisnis, dan lingkup fitur MVP.
- [DESIGN.md](./DESIGN.md) — Design system, design tokens, dan peta 24 screen FigCraft.
- [ARCHITECTURE.md](./ARCHITECTURE.md) — Struktur folder, skema SQLite (Drift), rumus saldo, dan format backup JSON.
- [AGENTS.md](./AGENTS.md) — Standar coding & aturan teknis pengerjaan.
- [TASKS.md](./TASKS.md) — Checklist progres pengembangan bertahap.

---

## Cara Menjalankan Project

### Prasyarat
- Flutter SDK (Dart `^3.13.4`)
- Android Studio / Android SDK atau emulator/perangkat fisik Android

### Langkah Setup
```bash
# 1. Install dependencies
flutter pub get

# 2. Generate kode Drift (SQLite) setelah schema database dibuat/diubah
dart run build_runner build --delete-conflicting-outputs

# 3. Jalankan aplikasi di emulator / perangkat
flutter run
```

### Validasi & Build Release APK
```bash
# Cek analisis lint & tipe
flutter analyze

# Jalankan unit & widget tests
flutter test

# Build APK release untuk Android
flutter build apk --release
```

File APK hasil build akan tersedia di:
`build/app/outputs/flutter-apk/app-release.apk`
