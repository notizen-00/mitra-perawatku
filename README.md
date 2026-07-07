# 🩺 Perawatku.app Mitra

> **Professional Healthcare Partner Application**
> Modern, fast, and reliable mobile application for healthcare professionals.

---

<p align="center">

<img src="./assets/images/logo.png" width="140"/>

</p>

<p align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.x-blue.svg)
![Material3](https://img.shields.io/badge/Material%203-Enabled-success.svg)
![Bloc](https://img.shields.io/badge/State%20Management-flutter_bloc-blueviolet.svg)
![License](https://img.shields.io/badge/license-Private-red.svg)

</p>

---

# Overview

**Perawatku.app Mitra** merupakan aplikasi mobile yang dirancang khusus untuk tenaga kesehatan profesional agar dapat menerima layanan kesehatan secara digital.

Aplikasi ini memungkinkan tenaga kesehatan untuk menerima permintaan layanan dari pasien secara realtime, melakukan navigasi menuju lokasi pasien, menjalankan proses pelayanan, hingga menerima pembayaran secara aman.

Perawatku.app berfokus pada pengalaman penggunaan yang cepat, sederhana, dan profesional sehingga tenaga kesehatan dapat lebih fokus memberikan pelayanan terbaik kepada pasien.

---

# Vision

Membangun platform layanan kesehatan digital yang mampu menghubungkan pasien dengan tenaga kesehatan profesional secara cepat, aman, dan terpercaya.

---

# Mission

- Mempermudah tenaga kesehatan menerima layanan.
- Memberikan pengalaman kerja yang efisien.
- Mengurangi proses administrasi manual.
- Menyediakan sistem pendapatan yang transparan.
- Mengintegrasikan seluruh proses pelayanan dalam satu aplikasi.

---

# Supported Healthcare Professionals

Perawatku.app Mitra mendukung berbagai jenis tenaga kesehatan.

- 👨‍⚕️ Registered Nurse
- 👩‍⚕️ Doctor
- ❤️ Caregiver
- 👶 Midwife
- 🦴 Physiotherapist
- 💉 Home Care Nurse
- 🏥 Medical Assistant
- 🚑 Emergency Response Team

---

# Core Features

## Authentication

- Login
- Register
- OTP Verification
- Forgot Password
- Session Management
- Secure Authentication

---

## Dashboard

Dashboard dirancang agar seluruh informasi penting dapat dilihat dalam satu layar.

Menampilkan:

- Availability Status
- Today's Income
- Today's Orders
- Active Service
- Upcoming Schedule
- Recent Activities
- Notification Summary
- Performance Overview

---

## Smart Matchmaking

Sistem akan mencari tenaga kesehatan berdasarkan berbagai parameter.

Matching mempertimbangkan:

- Radius
- Distance
- Estimated Arrival
- Professional Category
- Availability
- Service Area
- Professional Rating
- Priority Score

---

## Order Management

Mengelola seluruh proses layanan.

Status order:

```
Requested

↓

Searching Partner

↓

Matched

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

↓

Rated
```

---

## Live Tracking

Fitur tracking realtime.

Mendukung:

- Live Location
- ETA
- Navigation
- Route Information
- Distance Calculation

---

## Medical Service

Mitra dapat melakukan:

- Start Treatment
- Update Service Progress
- Upload Documentation
- Complete Service
- Treatment Notes

---

## Wallet

Financial management.

Fitur:

- Balance
- Income
- Pending Income
- Withdraw
- Transaction History
- Monthly Summary

---

## Schedule

Mengatur:

- Working Hours
- Available Days
- Break Time
- Holiday Schedule

---

## Profile

Data profesional.

Meliputi:

- Personal Information
- Medical License
- STR / SIP
- Practice Certificate
- Education
- Experience
- Bank Account
- Emergency Contact

---

## Notification

Realtime notification.

Jenis notifikasi:

- Incoming Order
- Chat
- Payment
- Verification
- System

---

# Application Flow

```
Splash

↓

Authentication

↓

Dashboard

↓

Incoming Match

↓

Accept Order

↓

Navigate

↓

Arrived

↓

Treatment

↓

Complete

↓

Payment

↓

Wallet
```

---

# Technology Stack

## Mobile

- Flutter
- Dart

## State Management

- flutter_bloc

## Dependency Injection

- get_it

## Networking

- Dio

## Local Storage

- SharedPreferences
- Flutter Secure Storage

## Realtime

- Laravel Reverb
- WebSocket

## Maps

- flutter_map

## Push Notification

- Firebase Cloud Messaging

---

# Project Architecture

Project menggunakan pendekatan **Feature First Architecture** dengan prinsip **Clean Architecture**.

```
lib/

core/

config/

services/

theme/

shared/

features/

auth/

dashboard/

orders/

tracking/

wallet/

profile/

notifications/

schedule/

settings/
```

---

# Design Principles

Perawatku.app Mitra dibangun berdasarkan prinsip:

- Professional
- Clean
- Medical Grade
- Fast
- Accessible
- Minimal
- Consistent
- Human Centered

---

# Design Documentation

Dokumentasi desain tersedia pada folder:

```
docs/
```

| Document           | Description                          |
| ------------------ | ------------------------------------ |
| DESIGN_SYSTEM.md   | Design language dan visual guideline |
| THEME_GUIDE.md     | Implementasi tema Flutter Material 3 |
| COMPONENT_GUIDE.md | Seluruh reusable component           |
| SCREEN_FLOW.md     | Alur seluruh screen                  |
| MATCHMAKING.md     | Dokumentasi Smart Matchmaking        |
| BOOKING_FLOW.md    | Alur booking layanan                 |
| ORDER_LIFECYCLE.md | Siklus hidup order                   |

---

# Backend Integration

Aplikasi Mitra terhubung dengan backend **Perawatku.app** menggunakan REST API dan WebSocket.

Integrasi mencakup:

- Authentication
- Booking
- Smart Matchmaking
- Wallet
- Notification
- Maps
- Chat
- Medical Records

---

# Security

Seluruh komunikasi dilakukan menggunakan HTTPS.

Fitur keamanan:

- JWT Authentication
- Token Refresh
- Secure Storage
- API Authorization
- Request Validation
- SSL/TLS Encryption

---

# Performance Goals

Target performa aplikasi:

- Startup < 2 detik
- Screen Transition < 300 ms
- API Response < 500 ms (normal)
- Smooth Animation 60 FPS
- Low Memory Consumption

---

# Roadmap

## Phase 1

- Authentication
- Dashboard
- Booking
- Tracking
- Wallet

## Phase 2

- Schedule
- Chat
- Notification
- Medical Notes

## Phase 3

- AI Matchmaking
- Offline Mode
- Voice Assistant
- Analytics Dashboard

---

# Documentation

Seluruh dokumentasi teknis tersedia pada folder **docs/** dan menjadi acuan utama pengembangan aplikasi.

Dokumentasi mencakup:

- Design System
- Theme Guide
- Component Guide
- Screen Flow
- State Management
- API Mapping
- Coding Style
- Animation Guide

---

# License

Private Repository

Copyright © Perawatku.app.

All Rights Reserved.
