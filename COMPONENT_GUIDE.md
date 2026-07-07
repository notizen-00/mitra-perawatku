# 🧩 COMPONENT_GUIDE.md

> **Perawatku.app Mitra Component Library**
>
> Reusable UI Components & Design Standards

---

# Overview

Seluruh UI pada aplikasi **Perawatku.app Mitra** dibangun menggunakan reusable component.

Tujuan utama:

- Konsisten
- Mudah dirawat
- Mudah diuji
- Mudah dikembangkan
- Mengurangi duplikasi kode

Setiap screen harus dibangun dari kombinasi component yang tersedia pada dokumen ini.

---

# Component Architecture

Menggunakan pendekatan **Atomic Design**.

```text
Screen

↓

Section

↓

Component

↓

Primitive Widget
```

Contoh:

```text
Dashboard Screen

↓

Today's Income Section

↓

Wallet Balance Card

↓

Container
Text
Icon
Button
```

---

# Folder Structure

```text
lib/shared/widgets/

buttons/
cards/
chips/
dialogs/
bottom_sheet/
inputs/
loaders/
avatars/
badges/
timeline/
navigation/
map/
wallet/
orders/
profile/
common/
```

Component khusus fitur disimpan di dalam folder feature masing-masing.

Contoh:

```text
features/orders/widgets/

incoming_order_card.dart

order_status_chip.dart

order_action_sheet.dart
```

---

# Naming Convention

Gunakan suffix sesuai fungsi.

```text
MedicalCard

WalletCard

OrderCard

ProfileCard

PrimaryButton

StatusChip

RatingChip

MedicalAvatar

LoadingSkeleton

AppDialog

BottomActionBar
```

Hindari nama seperti:

```text
Card1

WidgetBaru

ContainerCustom
```

---

# Buttons

## PrimaryButton

Digunakan untuk aksi utama.

Contoh:

- Accept Order
- Save
- Continue
- Login
- Withdraw

---

## SecondaryButton

Digunakan untuk aksi kedua.

Contoh:

- Edit
- View Detail
- Change Schedule

---

## OutlinedButton

Digunakan ketika aksi tidak terlalu dominan.

---

## GhostButton

Background transparan.

Digunakan untuk:

- Skip
- Later
- Cancel

---

## DangerButton

Untuk aksi destruktif.

Contoh:

- Reject Order
- Logout
- Delete

---

## IconButton

Ukuran:

48 x 48

Contoh:

- Call
- Chat
- Maps
- Refresh

---

# Cards

## MedicalCard

Card dasar seluruh aplikasi.

Properti:

- Radius 16
- Padding 16
- Border Outline
- Elevation rendah

Semua card mewarisi komponen ini.

---

## WalletCard

Menampilkan:

- Balance
- Income
- Pending
- Withdraw CTA

---

## OrderCard

Menampilkan:

- Patient
- Service
- Distance
- ETA
- Price
- Status

Digunakan di:

- Dashboard
- Orders
- History

---

## PatientCard

Menampilkan informasi pasien.

- Avatar
- Name
- Age
- Gender
- Address

---

## StatisticsCard

Untuk dashboard.

Contoh:

Today's Income

Today's Orders

Completed

Rating

---

## NotificationCard

Menampilkan notifikasi sistem.

---

# Status Components

## StatusChip

Status:

- Requested
- Searching
- Accepted
- On The Way
- Arrived
- Treatment
- Completed
- Cancelled

Menggunakan warna berdasarkan status.

---

## AvailabilityChip

Status:

🟢 Available

🟡 Busy

🔴 Offline

---

## RatingChip

Menampilkan rating.

Contoh:

⭐ 4.9

---

## DistanceChip

Contoh:

2.4 km

---

## ETAChip

Contoh:

12 Minutes

---

# Avatar

## MedicalAvatar

Menampilkan foto tenaga kesehatan.

Support:

- Online Indicator
- Verification Badge
- Placeholder

Ukuran:

40

48

56

72

96

---

# Badge

Badge digunakan untuk:

- Verified
- New
- Emergency
- Priority

---

# Inputs

## AppTextField

Input standar.

Support:

- Prefix Icon
- Suffix Icon
- Validation
- Error Text

---

## SearchField

Digunakan pada:

Orders

Patients

History

Wallet

---

## OTPField

Input OTP.

---

## PhoneField

Nomor telepon.

---

## CurrencyField

Input nominal.

---

# Timeline

## OrderTimeline

Menampilkan progress order.

Status:

Requested

↓

Accepted

↓

On The Way

↓

Arrived

↓

Treatment

↓

Completed

---

## ActivityTimeline

Riwayat aktivitas.

---

# Map Components

## MiniMapCard

Map kecil pada dashboard.

---

## TrackingMap

Digunakan pada halaman tracking.

Support:

- Patient Marker
- Mitra Marker
- Route
- ETA

---

## RouteInformationCard

Menampilkan:

Distance

Duration

Arrival Time

---

# Wallet Components

## WalletBalanceCard

Menampilkan saldo.

---

## IncomeCard

Pendapatan.

---

## TransactionCard

Riwayat transaksi.

---

## WithdrawCard

Informasi withdraw.

---

# Dashboard Components

Dashboard dibangun dari:

- GreetingHeader
- AvailabilitySwitch
- Today'sIncomeCard
- Today'sOrderCard
- ActiveServiceCard
- UpcomingScheduleCard
- QuickActionGrid
- RecentActivitySection

---

# Matchmaking Components

## IncomingOrderSheet

Bottom Sheet ketika mendapat order.

Menampilkan:

Patient

Distance

ETA

Service

Countdown

Accept

Reject

---

## MatchScoreCard

Menampilkan skor matching.

---

## CountdownWidget

Countdown menerima order.

---

# Tracking Components

## CurrentJobCard

Status pekerjaan.

---

## PatientInformationCard

Data pasien.

---

## MedicalNotesCard

Catatan pelayanan.

---

## RouteCard

Informasi rute.

---

## ActionBottomBar

Berisi tombol:

Navigate

Chat

Call

Complete

---

# Profile Components

## ProfileHeader

Foto

Nama

Profesi

Rating

---

## LicenseCard

STR

SIP

Dokumen

---

## BankInformationCard

Informasi rekening.

---

## ServiceSettingsCard

Harga layanan.

---

# Notification Components

## NotificationItem

Item notifikasi.

---

## NotificationGroup

Pengelompokan notifikasi.

---

# Loaders

Seluruh loading menggunakan Skeleton.

Komponen:

- Card Skeleton
- List Skeleton
- Profile Skeleton
- Wallet Skeleton
- Dashboard Skeleton

Hindari Full Screen Spinner.

---

# Empty States

Semua halaman harus memiliki Empty State.

Terdiri dari:

- Illustration
- Title
- Description
- CTA

---

# Error Components

Gunakan ErrorCard.

Berisi:

- Icon
- Message
- Retry Button

---

# Dialog Components

- ConfirmationDialog
- SuccessDialog
- ErrorDialog
- PermissionDialog

---

# Bottom Sheet Components

Gunakan Bottom Sheet untuk:

- Accept Order
- Reject Order
- Withdraw
- Filter
- Rating
- Select Service

Semua menggunakan drag handle dan tinggi adaptif.

---

# Reusability Rules

Component wajib:

- Stateless jika memungkinkan.
- Tidak melakukan request API.
- Tidak menyimpan business logic.
- Mudah diuji (testable).
- Mendukung ThemeData.
- Mendukung Light & Dark Theme.

---

# Development Rules

Developer tidak diperbolehkan:

- Membuat warna baru di widget.
- Mengatur radius manual.
- Mengatur padding manual di luar design token.
- Menggandakan component yang sudah tersedia.

Jika membutuhkan UI baru, lakukan evaluasi apakah component dapat diperluas sebelum membuat component baru.

---

# Future Component Library

Rencana penambahan:

- AI Recommendation Card
- Emergency Banner
- Medical Certificate Viewer
- Shift Calendar
- Earnings Chart
- Heatmap Order
- Dynamic Filter Chips
- Voice Command Button
- Offline Sync Banner

---

Dengan pendekatan ini, seluruh screen Perawatku.app Mitra akan dibangun dari kumpulan komponen yang konsisten, mudah dipelihara, dan siap berkembang seiring bertambahnya fitur tanpa mengorbankan kualitas maupun performa aplikasi.
