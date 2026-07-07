# 🎨 THEME_GUIDE.md

> **Perawatku.app Mitra Theme Guide**
> Flutter Material 3 Theme Implementation Guide

---

# Purpose

Dokumen ini menjelaskan implementasi tema Flutter untuk aplikasi **Perawatku.app Mitra**.

Seluruh tampilan aplikasi wajib menggunakan `ThemeData` yang didefinisikan secara global. Hindari penggunaan warna, ukuran font, radius, atau shadow secara langsung di dalam widget.

Seluruh design token berasal dari `DESIGN_SYSTEM.md`.

---

# Theme Architecture

```text
ThemeData
│
├── ColorScheme
├── Typography
├── Shapes
├── Component Themes
├── Extensions
└── Design Tokens
```

Seluruh halaman menggunakan satu sumber tema sehingga perubahan visual dapat dilakukan secara terpusat.

---

# Folder Structure

```text
lib/core/theme/
│
├── app_theme.dart
├── app_colors.dart
├── app_text_theme.dart
├── app_spacing.dart
├── app_radius.dart
├── app_elevation.dart
├── app_icons.dart
├── app_motion.dart
├── app_extensions.dart
└── theme_extensions/
```

Tidak diperbolehkan mendefinisikan warna baru di luar folder ini.

---

# Theme Mode

Aplikasi mendukung:

- Light Theme
- Dark Theme (future ready)

Seluruh widget wajib kompatibel dengan kedua mode.

---

# ColorScheme

Menggunakan `ColorScheme.fromSeed` sebagai dasar, kemudian dioverride sesuai identitas Perawatku.

### Primary

Medical Green

```text
#006C49
```

### Secondary

Trust Blue

```text
#0066CC
```

### Tertiary

Healthcare Cyan

```text
#00B8D9
```

### Error

```text
#BA1A1A
```

### Surface

```text
#FFFFFF
```

### Background

```text
#F8FAFC
```

### Outline

```text
#D7DEE4
```

---

# Typography

Menggunakan:

- Plus Jakarta Sans (Heading)
- Inter (Body)

Hierarchy:

| Style           | Size | Weight   |
| --------------- | ---: | -------- |
| Display Large   |   40 | Bold     |
| Display Medium  |   36 | Bold     |
| Headline Large  |   32 | Bold     |
| Headline Medium |   24 | SemiBold |
| Title Large     |   20 | SemiBold |
| Title Medium    |   18 | Medium   |
| Body Large      |   16 | Regular  |
| Body Medium     |   14 | Regular  |
| Body Small      |   12 | Regular  |
| Label           |   12 | Medium   |

Semua angka (saldo, tarif, ETA, jarak) menggunakan `FontFeature.tabularFigures()` agar lebih mudah dipindai.

---

# Shape System

Semua komponen mengikuti radius global.

| Token | Radius |
| ----- | ------ |
| xs    | 4      |
| sm    | 8      |
| md    | 12     |
| lg    | 16     |
| xl    | 20     |
| full  | 999    |

Gunakan token, jangan angka literal.

---

# Spacing Tokens

Base Grid = **4 px**

| Token | Value |
| ----- | ----: |
| xs    |     4 |
| sm    |     8 |
| md    |    12 |
| lg    |    16 |
| xl    |    24 |
| xxl   |    32 |
| xxxl  |    48 |
| huge  |    64 |

Semua padding dan margin menggunakan token ini.

---

# Elevation

Gunakan elevasi seminimal mungkin.

| Level | Penggunaan    |
| ----- | ------------- |
| 0     | Surface       |
| 1     | Card          |
| 2     | Floating Card |
| 3     | Bottom Sheet  |
| 4     | Dialog        |

Prioritaskan border dibanding shadow.

---

# Button Theme

Jenis tombol:

- Primary
- Secondary
- Outlined
- Ghost
- Danger
- Icon Button
- Floating Action Button

Aturan:

- Tinggi minimum 48 px
- Radius 16 px
- Font SemiBold
- Ikon 20–24 px

---

# Input Theme

Semua input menggunakan gaya yang konsisten.

Komponen:

- Filled TextField
- Search Field
- Password Field
- Phone Input
- OTP Input

Aturan:

- Radius 16 px
- Tinggi minimum 56 px
- Prefix icon opsional
- Helper text di bawah field
- Error mengikuti warna Error Theme

---

# Card Theme

Semua card menggunakan:

- Surface Color
- Radius 16
- Border Outline
- Padding 16
- Elevation rendah

Jenis card:

- Dashboard Card
- Order Card
- Patient Card
- Wallet Card
- Statistic Card
- Medical Card

---

# AppBar Theme

Standar AppBar:

- Background mengikuti Surface
- Tanpa shadow
- Title rata kiri
- Ikon kembali 24 px
- Tinggi mengikuti Material 3

---

# Bottom Navigation

Menggunakan Material 3 Navigation Bar.

Menu utama:

1. Dashboard
2. Orders
3. Wallet
4. Notifications
5. Profile

Ikon aktif menggunakan warna Primary.

---

# Bottom Sheet Theme

Bottom Sheet adalah komponen utama untuk aksi operasional.

Contoh:

- Accept Order
- Reject Order
- Withdraw
- Filter
- Rating

Standar:

- Radius atas 24 px
- Drag Handle aktif
- Tinggi adaptif
- Scrollable

---

# Dialog Theme

Dialog hanya digunakan untuk konfirmasi penting.

Contoh:

- Logout
- Cancel Order
- Delete Data

Gunakan maksimal dua tombol aksi.

---

# Snackbar Theme

Gunakan snackbar untuk feedback singkat.

Jenis:

- Success
- Warning
- Error
- Information

Durasi tampil:

- 2–3 detik

---

# Chip Theme

Chip digunakan untuk:

- Availability
- Order Status
- Rating
- Distance
- Category

Semua chip memiliki radius penuh (`full`).

---

# Icon Theme

Menggunakan:

- Material Symbols Rounded

Ukuran standar:

| Token | Size |
| ----- | ---: |
| xs    |   16 |
| sm    |   20 |
| md    |   24 |
| lg    |   32 |
| xl    |   40 |

Hindari mencampur berbagai gaya ikon.

---

# Animation Theme

Durasi standar:

| Token  | Duration |
| ------ | -------: |
| fast   |   200 ms |
| normal |   300 ms |
| slow   |   400 ms |

Kurva:

- easeOutCubic
- easeInOutCubic

Animasi yang diperbolehkan:

- Fade
- Slide
- Scale
- Hero
- Ripple
- Skeleton
- Pulse

Hindari animasi yang berlebihan.

---

# Theme Extensions

Gunakan `ThemeExtension` untuk token yang tidak tersedia di Material 3, misalnya:

- Medical Status Colors
- Wallet Colors
- Order Status Colors
- Matchmaking Priority Colors
- Gradient Collections

Dengan pendekatan ini, perubahan branding dapat dilakukan tanpa mengubah widget satu per satu.

---

# Accessibility

Standar minimum:

- Touch target 48×48 px
- Kontras mengikuti WCAG AA
- Font minimum 12 px
- Fokus keyboard tetap terlihat
- Mendukung Dynamic Text Scale

---

# Best Practices

- Jangan gunakan `Color(...)` langsung di widget.
- Jangan gunakan `TextStyle(...)` secara manual jika sudah tersedia di tema.
- Jangan gunakan angka radius atau padding literal.
- Semua komponen harus mengambil nilai dari `Theme.of(context)` atau design token.
- Semua screen wajib konsisten dengan Material 3 dan Design System.

---

# Future Enhancements

- Dynamic Color (Android 12+)
- AMOLED Dark Theme
- High Contrast Theme
- Seasonal Theme
- Brand Theme Variants

---

Dengan mengikuti panduan ini, seluruh tampilan aplikasi Mitra akan memiliki konsistensi visual, mudah dirawat, dan siap berkembang seiring bertambahnya fitur tanpa mengorbankan kualitas desain.
