# AGENTS — Engineering & Coding Guidelines for Larisch (`larisch_app`)

Aturan wajib untuk setiap AI agent atau developer yang berkontribusi pada project Flutter **`larisch_app`**.

---

## 1. Sumber Kebenaran (Read Before Coding)

Sebelum menulis atau mengubah kode, selalu rujuk dokumen berikut:
1. `PRD.md` — Aturan bisnis & lingkup fitur MVP.
2. `DESIGN.md` — Design tokens, arah visual, dan peta 24 screen dari `c:\MCP-FigGravity\Mobile Apps Finance.figcraft`.
3. `ARCHITECTURE.md` — Struktur folder, skema SQLite (Drift), rumus perhitungan, dan format backup JSON.
4. `TASKS.md` — Cek milestone aktif dan tandai tugas yang selesai setelah terverifikasi.

---

## 2. Aturan Bisnis & Keuangan (Non-Negotiable)

- **100% Offline-First:** Jangan menambahkan Firebase, Supabase, REST API backend, autentikasi cloud, atau layanan sinkronisasi online pada fase MVP.
- **Total Saldo Kas != Laba Bersih:** Jangan pernah menyamakan atau menukar kedua metrik ini di UI maupun di layer logika.
- **3 Akun Kas Manual:** `Tunai`, `QRIS`, dan `Rekening Bank` adalah pencatatan manual (bukan integrasi real-time). Jangan menulis copy yang menyiratkan sinkronisasi otomatis bank/QRIS.
- **Nominal Wajib `int`:** Seluruh nominal Rupiah wajib bertipe `int` (tidak boleh `double` untuk penyimpanan atau penjumlahan uang).
- **Validasi Input:** Transaksi dengan nominal `<= 0` harus diblokir di UI dan di repository/database layer.
- **Empty State Wajib:** Jangan menanamkan data dummy ke database produksi pengguna baru.

---

## 3. Standar UI & Design Token

- **Gunakan Design Tokens:** Semua warna, tipografi, spasi, dan radius **wajib** mengambil dari `lib/core/theme/` (`AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`). Dilarang hardcode hex color acak di dalam screen.
- **Tabular Figures:** Semua widget yang menampilkan nominal Rupiah atau persentase wajib memakai `FontFeature.tabularFigures()`.
- **Logo Resmi:** Gunakan `assets/logo/larisch.png` (didaftarkan di `pubspec.yaml`).
  - **Splash Screen:** Hanya logo `assets/logo/larisch.png` di tengah layar berlatar `#000000`, tanpa teks/wordmark/tagline.
- **Anti-Slop UI:** Ikuti proporsi, kontras, dan hierarki bersih dari FigCraft. Hindari card bertumpuk tidak perlu, animasi berlebihan, atau teks panjang yang memenuhi layar.
- **Bahasa UI:** Seluruh label, tombol, pesan validasi, dan empty state menggunakan **Bahasa Indonesia** yang jelas, ringkas, dan natural bagi pemilik UMKM.

---

## 4. Standar Kode Flutter & Dart

- Ikuti struktur feature-first di `ARCHITECTURE.md`.
- Pisahkan UI widget dari logika database: UI membaca/menulis lewat **Riverpod providers/controllers**, bukan memanggil query SQL langsung di `build()`.
- Setelah mengubah tabel Drift, wajib jalankan `dart run build_runner build --delete-conflicting-outputs`.
- Pastikan tidak ada lint warning: jalankan `flutter analyze` dan `flutter test` setelah perubahan signifikan.
- Hindari meninggalkan kode dead/unused, komentar generik yang hanya mengulang kode, atau placeholder `TODO` pada fitur yang sudah ditandai selesai.

---

## 5. Fokus Prioritas Pengerjaan

- **Prioritas Utama:** Selesaikan aplikasi mobile Flutter (`larisch_app`) secara bertahap sesuai urutan di `TASKS.md` sampai lulus test dan bisa di-build APK.
- **Tahap Terakhir:** Website Marketing Landing Page (Page 3 FigCraft) dikerjakan terpisah **hanya setelah** aplikasi mobile selesai.
