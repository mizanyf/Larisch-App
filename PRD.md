# PRD — Larisch (Aplikasi Pembukuan Keuangan UMKM)

**Versi Dokumen:** 1.0 (MVP)  
**Nama Produk:** Larisch  
**Nama Package Flutter:** `larisch_app`  
**Platform Utama:** Mobile Application (Flutter — Android & iOS)  
**Model Penyimpanan:** 100% Offline-First, Local Device Storage (SQLite / Drift)

---

## 1. Ringkasan Produk

**Larisch** adalah aplikasi pembukuan keuangan harian untuk pemilik **UMKM Indonesia** (kedai kopi, warung, toko retail, jasa, kuliner, dll.) yang membutuhkan pencatatan pemasukan, pengeluaran, saldo kas per metode pembayaran, dan laporan laba rugi sederhana **tanpa latar belakang akuntansi**.

Fokus utama MVP:
- Cepat dipakai mencatat transaksi harian (target < 10 detik per transaksi).
- Bekerja **100% offline** tanpa login, tanpa server, tanpa cloud sync, dan tanpa biaya langganan backend.
- Memisahkan dengan tegas konsep **Total Saldo Kas** (uang yang tersedia) dan **Laba Bersih** (kinerja profit periode).

---

## 2. Target Pengguna

- **Persona Utama:** Pemilik UMKM mikro & kecil di Indonesia (contoh: Budi, pemilik Kedai Kopi).
- **Kebutuhan Utama:**
  - Mencatat uang masuk & uang keluar harian dari HP.
  - Mengetahui sisa uang di **Tunai**, **QRIS**, dan **Rekening Bank** secara terpisah.
  - Mengetahui apakah usaha bulan ini untung atau rugi (**Laba Bersih** & **Margin**).
  - Menjaga privasi data keuangan tetap di perangkat sendiri dengan opsi backup manual.

---

## 3. Prinsip & Aturan Bisnis Wajib (Source of Truth)

1. **Offline-First & Local Only (MVP):**
   - Tidak ada autentikasi akun cloud, tidak ada remote API, tidak ada sinkronisasi server pada versi MVP.
   - Semua data tersimpan di database SQLite lokal perangkat.
2. **Pemisahan Total Saldo Kas vs Laba Bersih:**
   - **Total Saldo Kas** = `Saldo Tunai + Saldo QRIS + Saldo Rekening Bank` (akumulasi saldo awal + seluruh pemasukan - seluruh pengeluaran sepanjang waktu).
   - **Laba Bersih (Periode)** = `Total Pemasukan Periode - Total Pengeluaran Periode` (Harian / Mingguan / Bulanan).
   - **Margin (%)** = `(Laba Bersih / Total Pemasukan Periode) × 100%` (jika pemasukan > 0, selain itu `0%`).
   - Kedua angka ini **tidak boleh** dicampuradukkan.
3. **3 Akun Kas Manual (Metode Pembayaran):**
   - `Tunai`
   - `QRIS`
   - `Rekening Bank`
   - Saldo ketiga akun adalah hasil **pencatatan manual pengguna**, bukan integrasi API real-time dengan bank atau penyedia QRIS. Wajib tampilkan keterangan halus seperti `"Saldo tercatat manual"` di dashboard.
4. **Akurasi Nominal Rupiah:**
   - Semua nominal uang disimpan sebagai bilangan bulat (`int`, satuan Rupiah tanpa desimal).
   - Transaksi dengan nominal `<= 0` **wajib ditolak** dengan pesan validasi yang jelas.
5. **Backup & Restore Lokal:**
   - Menggunakan file lokal (`.json`) yang di-export/import langsung dari penyimpanan perangkat pengguna — **tanpa cloud**.
6. **Empty State Pengguna Baru:**
   - Pengguna baru yang belum mencatat transaksi wajib melihat *empty state* yang ramah dengan CTA langsung untuk mencatat transaksi pertama (bukan data dummy).

---

## 4. Lingkup Fitur MVP (In-Scope)

### 4.1 Onboarding & Setup Awal (New User Flow)
- **Splash Screen:** Tampilan logo-only Larisch (`assets/logo/larisch.png`) di latar hitam `#000000`, otomatis memeriksa apakah profil usaha sudah tersimpan.
- **Welcome Screen:** Pengenalan singkat nilai utama Larisch + tombol mulai.
- **Setup Profil Usaha:** Input nama usaha (wajib) dan jenis/kategori usaha (opsional).
- **Setup Saldo Awal Manual:** Input saldo awal (default `Rp 0`) untuk `Tunai`, `QRIS`, dan `Rekening Bank`.
- **Onboarding Success:** Konfirmasi siap digunakan -> masuk ke **Beranda**.

### 4.2 Beranda (Dashboard)
- Header gelap menampilkan logo + wordmark **Larisch**, nama usaha, selector periode (`Nov 2026`), dan label `"Saldo tercatat manual"`.
- **Kartu Total Saldo Kas:** Nominal total gabungan + breakdown 3 akun (`Tunai`, `QRIS`, `Rekening Bank`).
- **Kartu Laba Bersih (Periode):** Nominal Laba Bersih (hijau jika positif, merah jika rugi) + ringkasan `Pemasukan` & `Pengeluaran` periode terpilih.
- **Quick Actions:** Tombol cepat `+ Pemasukan` dan `- Pengeluaran`.
- **Transaksi Terbaru:** Maksimal 5 transaksi terbaru + tautan `Lihat semua` ke tab Transaksi.
- **Empty State:** Tampilan khusus jika belum ada transaksi.

### 4.3 Pencatatan Transaksi (Catat Pemasukan & Pengeluaran)
- Toggle jenis transaksi: **Pemasukan** (aksen hijau) vs **Pengeluaran** (aksen merah).
- Input nominal besar (format otomatis pemisah ribuan `Rp`).
- Validasi inline jika nominal `0` / kosong (`"Masukkan nominal lebih dari Rp 0 sebelum menyimpan"`).
- Pilih **Akun Pembayaran** (`Tunai`, `QRIS`, `Rekening Bank`).
- Pilih **Kategori** sesuai jenis transaksi:
  - *Default Pemasukan:* Penjualan Tunai, Penjualan QRIS/Transfer, Pesanan/Katering, Pemasukan Lainnya.
  - *Default Pengeluaran:* Bahan Baku, Gaji Karyawan, Sewa & Listrik, Kemasan, Transportasi, Operasional Lainnya.
- Input **Tanggal & Waktu** (default: sekarang) dan **Catatan** (opsional).
- Feedback konfirmasi sukses setelah transaksi tersimpan.

### 4.4 Riwayat Transaksi, Detail, Edit & Hapus
- Daftar transaksi dikelompokkan berdasarkan tanggal (`Hari ini`, `Kemarin`, tanggal spesifik).
- Pencarian berdasarkan catatan/kategori.
- Filter berdasarkan: **Jenis** (`Semua`, `Pemasukan`, `Pengeluaran`), **Akun Kas** (`Semua Akun`, `Tunai`, `QRIS`, `Rekening Bank`), dan **Periode**.
- Ringkasan cepat pemasukan vs pengeluaran sesuai filter aktif.
- **Detail Transaksi:** Menampilkan seluruh informasi transaksi + tombol **Edit** dan **Hapus**.
- **Edit Transaksi:** Membuka form pre-filled dan memperbarui saldo akun secara otomatis.
- **Hapus Transaksi:** Wajib melalui dialog konfirmasi; saldo akun otomatis terkoreksi.

### 4.5 Laporan Keuangan
- Filter periode: **Harian**, **Mingguan**, **Bulanan** + pemilih bulan/rentang.
- Ringkasan **Laba Bersih**, **Margin (%)**, **Total Pemasukan**, dan **Total Pengeluaran**.
- Grafik tren arus kas (Pemasukan vs Pengeluaran) pada periode terpilih.
- **Breakdown Pengeluaran per Kategori** (nominal & persentase terhadap total pengeluaran) dengan progress bar rapi.
- Empty state jika periode terpilih belum memiliki transaksi.

### 4.6 Profil & Pengaturan
- **Profil Usaha:** Lihat & edit nama usaha dan jenis usaha.
- **Kelola Kategori:** Tambah, edit, dan hapus kategori pemasukan/pengeluaran kustom (kategori bawaan atau yang sudah dipakai transaksi ditangani dengan aman).
- **Backup Data Lokal:** Export seluruh data (profil, akun, kategori, transaksi) ke file `.json` lokal.
- **Restore Data Lokal:** Import file `.json` backup dengan pratinjau/konfirmasi sebelum menimpa data saat ini.
- **Reset Data:** Hapus seluruh data lokal (dengan konfirmasi ganda) untuk memulai ulang dari awal.

---

## 5. Di Luar Lingkup MVP (Out of Scope — Fase Berikutnya)

- Login / registrasi akun, sinkronisasi cloud, dan multi-device sync.
- Integrasi real-time mutasi bank / payment gateway QRIS.
- Manajemen stok barang (inventory), kasir POS cetak struk, piutang/utang kompleks, dan multi-user/karyawan.
- Website Marketing Landing Page (dikerjakan **terakhir** setelah aplikasi mobile MVP selesai).

---

## 6. Kriteria Selesai MVP (Definition of Done)

- Seluruh 24 layar di `Mobile App Larisch` pada file FigCraft terimplementasi konsisten dengan Design System.
- Perhitungan Saldo Kas (per akun & gabungan) serta Laba Bersih lolos unit test pada skenario tambah, edit, hapus, dan pindah akun pembayaran.
- Backup & Restore file JSON lokal teruji memulihkan data secara utuh tanpa duplikasi/korupsi.
- Aplikasi berjalan mulus secara offline (mode pesawat aktif) dan berhasil di-build menjadi APK release Android.
