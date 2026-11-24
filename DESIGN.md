# DESIGN — Larisch Design System & UI Specification

**Sumber Desain Resmi (FigCraft):** `c:\MCP-FigGravity\Mobile Apps Finance.figcraft`  
- **Page 1:** `Design System`  
- **Page 2:** `Mobile App Larisch` (24 screens — fokus utama fase ini)  
- **Page 3:** `🌐 Website — Larisch Landing Page` (dikerjakan terakhir setelah aplikasi mobile selesai)

**Asset Logo Resmi:** `assets/logo/larisch.png`

---

## 1. Arah Visual (Design Direction)

- **Gaya:** Premium minimalist fintech — bersih, kontras tinggi, tipografi presisi, dan ruang putih (*negative space*) yang lega.
- **Fondasi Warna:** Monokrom hitam-putih (`#0B0D10` dark header + `#FFFFFF` clean content surface) dengan warna aksen fungsional yang disiplin:
  - **Biru (`#2563EB`)** -> Primary CTA, FAB `+`, link aksi.
  - **Hijau (`#16A34A` / `#22C55E`)** -> Pemasukan & Laba Bersih positif.
  - **Merah (`#DC2626` / `#EF4444`)** -> Pengeluaran, rugi, validasi error, aksi hapus.
- **Anti-Slop Rules:**
  - Jangan menumpuk kartu di dalam kartu secara berlebihan.
  - Jangan memakai gradient warna-warni generik atau shadow tebal berlebihan.
  - Semua angka Rupiah **wajib** memakai `FontFeature.tabularFigures()` (`tnum`) agar digit sejajar vertikal.

---

## 2. Design Tokens (Referensi Implementasi `lib/core/theme/`)

### 2.1 Color Palette (`app_colors.dart`)

| Token Dart | Hex | Penggunaan |
| :--- | :--- | :--- |
| `splashBlack` | `#000000` | Latar Splash Screen (logo-only) & background icon logo |
| `darkBase` | `#0B0D10` | Dark header Beranda, Laporan, Catat Transaksi, Floating Bottom Nav |
| `darkCard` | `#161B22` | Kartu gelap pada dark header (Total Saldo Kas, segmented control gelap) |
| `darkBorder` | `#262D37` | Border tipis `1px` pada komponen dark surface |
| `surfaceWhite` | `#FFFFFF` | Permukaan konten utama (light sheet, list, form body) |
| `surfaceMuted` | `#F6F7F9` | Latar kartu sekunder (Laba Bersih card, input field, chip non-aktif) |
| `borderLight` | `#EAECF0` | Divider `1px` & border kartu di area terang |
| `textPrimary` | `#111827` | Teks utama & nominal di area terang |
| `textSecondary` | `#6B7280` | Label, subjudul, tanggal, metadata di area terang |
| `textOnDark` | `#FFFFFF` | Teks utama & nominal di area gelap |
| `textOnDarkMuted` | `#9CA3AF` | Label & keterangan sekunder di area gelap |
| `accentBlue` | `#2563EB` | Primary action button, FAB `+`, tautan `Lihat semua` |
| `incomeGreen` | `#16A34A` | Nominal pemasukan & laba positif di area terang |
| `incomeGreenLight` | `#22C55E` | Nominal laba/margin positif di area gelap |
| `expenseRed` | `#DC2626` | Nominal pengeluaran, tombol hapus, status rugi |
| `dangerSurface` | `#FEF2F2` | Latar banner error / peringatan |
| `dangerBorder` | `#FECACA` | Border banner error / peringatan |

### 2.2 Typography (`app_typography.dart`)
- **Font Family:** `Inter` (via `google_fonts` atau bundled font asset di `assets/fonts/`).
- **Wajib Tabular Numbers** untuk semua angka uang & persentase: `fontFeatures: [FontFeature.tabularFigures()]`.

| Gaya | Ukuran | Weight | Line Height | Letter Spacing | Penggunaan |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `displayBalance` | `32 px` | Bold (`700`) | `38 px` | `-0.8` | Total Saldo Kas & Nominal Input |
| `headlineLarge` | `24 px` | Bold (`700`) | `30 px` | `-0.5` | Judul Onboarding, Laba Bersih Hero |
| `pageTitle` | `20 px` | Bold (`700`) | `26 px` | `-0.3` | Header halaman (Transaksi, Laporan, Profil) |
| `sectionHeading` | `16 px` | SemiBold (`600`) | `22 px` | `-0.2` | Judul seksi (`Transaksi Terbaru`, `Pengeluaran per Kategori`) |
| `cardMetric` | `18 px` | Bold (`700`) | `24 px` | `-0.2` | Nominal Pemasukan/Pengeluaran pada kartu |
| `bodyMedium` | `14 px` | Medium (`500`) | `20 px` | `0` | Item daftar transaksi, isi form, tombol |
| `bodyRegular` | `14 px` | Regular (`400`) | `20 px` | `0` | Deskripsi & catatan |
| `caption` | `12 px` | Regular (`400`) | `16 px` | `0` | Tanggal, metode pembayaran, helper text |
| `labelSmall` | `11 px` | Medium (`500`) | `14 px` | `0.2` | Badge kecil & label akun kas |

### 2.3 Spacing & Radius (`app_spacing.dart`, `app_radius.dart`)
- **Skala Spasi (Kelipatan 4px):** `xs = 4`, `sm = 8`, `md = 12`, `lg = 16`, `xl = 20`, `xxl = 24`, `xxxl = 32`.
- **Horizontal Screen Padding:** `20 px`.
- **Corner Radius:**
  - `sheetTop = 28 px` (transisi dark header ke white content sheet)
  - `cardLarge = 20 px` (kartu saldo utama)
  - `card = 16 px` (kartu metrik & daftar)
  - `button = 12 px` (tombol utama & input field)
  - `chip = 8 px` / `pill = 999 px` (filter chips & floating bottom nav)

---

## 3. Komponen Global Reusable (`lib/core/widgets/`)

1. **`LarischLogoBadge`:** Kontainer `32×32` (`cornerRadius: 8`, fill `#000000`, border `white 15%`) menampilkan `assets/logo/larisch.png` untuk header Beranda & Profil. Khusus **Splash Screen**, tampilkan `assets/logo/larisch.png` `160×160` langsung di latar `#000000` tanpa kotak/border dan tanpa teks.
2. **`FloatingBottomNav`:** Pill gelap melayang (`#0B0D10`, radius `999px`) berisi 4 tab (`Beranda`, `Transaksi`, `Laporan`, `Profil`) + tombol **FAB `+`** bulat biru (`#2563EB`) terpisah di sisi kanan untuk langsung membuka modal/halaman Catat Transaksi.
3. **`TransactionListTile`:** Baris transaksi konsisten (judul/kategori, metadata `Akun · Waktu`, nominal berwarna hijau `+ Rp ...` atau gelap/merah `- Rp ...`).
4. **`AccountSelectorChips`:** Pilihan 3 akun kas manual (`Tunai`, `QRIS`, `Rekening Bank`) dengan state terpilih yang jelas.
5. **`EmptyStateView`:** Komponen empty state bersih dengan ikon minimalis, judul, deskripsi singkat, dan tombol aksi primer.

---

## 4. Peta 24 Layar Aplikasi Mobile (Referensi Page 2 FigCraft)

| Kelompok | Layar | Catatan Implementasi |
| :--- | :--- | :--- |
| **Core Tabs** | `Screen 1 - Beranda` | Dark header + Total Saldo Kas (3 akun) + White sheet Laba Bersih + Quick Actions + Transaksi Terbaru |
| | `Screen 2 - Transaksi` | Search, filter jenis/akun/periode, ringkasan periode, list grouped by date |
| | `Screen 3 - Catat Transaksi` | Mode Pemasukan & Pengeluaran, nominal besar, akun kas, kategori, tanggal, catatan |
| | `Screen 4 - Laporan` | Harian/Mingguan/Bulanan, Laba Bersih & Margin, chart tren, breakdown kategori |
| | `Screen 5 - Profil` | Kartu identitas usaha + menu Kelola Kategori, Backup/Restore Lokal, Reset Data |
| **Transaksi Flows** | `Catat Pemasukan`, `Catat Pengeluaran`, `Validasi Nominal Rp 0`, `Detail Transaksi`, `Edit Transaksi`, `Konfirmasi Hapus`, `Sukses Simpan` | Validasi inline wajib aktif; hapus wajib dialog konfirmasi |
| **Onboarding** | `00 - Splash Screen` (logo only), `01 - Welcome`, `02 - Setup Profil Usaha`, `03 - Setup Saldo Awal`, `04 - Onboarding Success` | Hanya muncul sekali saat profil usaha belum ada |
| **Empty & Modals** | `Empty State Beranda`, `Empty State Transaksi`, `Empty State Laporan`, `Filter Transaksi Sheet`, `Kelola Kategori`, `Backup & Restore Lokal`, `Konfirmasi Reset Data` | Seluruh state kosong & modal harus fungsional |

---

## 5. Referensi Data Dummy (Hanya untuk Preview/Test)

Saat membuat unit test atau widget test, gunakan data contoh yang konsisten dengan FigCraft (**Kedai Kopi Budi**):
- **Total Saldo Kas:** `Rp 23.500.000` (`Tunai Rp 8.450.000`, `QRIS Rp 6.050.000`, `Rekening Bank Rp 9.000.000`)
- **Laba Bersih (Nov 2026):** `+ Rp 6.200.000` (`Pemasukan Rp 16.000.000`, `Pengeluaran Rp 9.800.000`, `Margin 38,7%`)

> **Catatan:** Data dummy **tidak boleh** di-prepopulate otomatis ke database produksi pengguna baru. Pengguna baru harus mulai dari `Rp 0` melalui flow Onboarding.
