# 🎨 PANOR Portal — Flutter Frontend Suite

Welcome to the frontend suite of **PANOR (Patient-Augmented Network for Operational Reasoning)**. This directory contains the high-fidelity, cross-platform Flutter application built to provide premium clinical workspaces matching Figma-level medical quality.

---

## 📂 Frontend Directory Structure

```txt
flutter_app/
├── lib/
│   ├── main.py              # Application entryway & global Material 3 theme configuration
│   ├── core/                # Business logic, API communication services, and global state
│   │   └── auth_service.dart # Local/Network JWT authentication & backend routing settings
│   ├── theme/               # Core design tokens
│   │   └── app_colors.dart  # Clinical Precision theme palette and shadow vectors
│   ├── widgets/             # Reusable UI widgets
│   │   └── custom_buttons.dart # Glassmorphic cards, flat primary, and semantic action controls
│   └── screens/             # Modular operational clinical workspaces
│       ├── auth/            # Gateway views (Splash, Role Selection, Login, OTP verification)
│       ├── doctor/          # Clinical Copilot Dashboard (SOAP notes, Agentic reasoning trace)
│       ├── patient/         # Health Portal (Ledger timeline, Vitals, Urdu AI translator)
│       ├── lab/             # Specimen Accessioning Priority Queue Workspace
│       └── admin/           # Control Center spatial outbreak map & cluster latency telemetry
└── pubspec.yaml             # Dart packages, assets registration, and Google Fonts dependencies
```

---

## ⚡ Zero-to-Live Frontend Quickstart Guide (Non-Tech & Tech)

Follow these simple steps to run the interactive frontend portal on your web browser or test it live on a physical mobile phone.

### 1. Prerequisite Installations
Make sure your computer has the following tools installed:
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.12.0 or higher is recommended)
*   [Python](https://www.python.org/downloads/) (to serve compiled static files)

### 2. Fetch Packages & Dependencies
Open a **new, separate terminal window** and run these commands to fetch all libraries (like Google Fonts, HTTP network clients, Shared Preferences):
```bash
cd d:\PANOR\PANOR-APP\flutter_app
flutter pub get
```

### 3. Build the Premium Production Web Bundle
Pre-compile the application into highly optimized web files:
```bash
flutter build web --release
```
*(This process takes about 60-90 seconds. Once complete, it outputs the static production assets directly to the `build/web/` directory!)*

### 4. Serve the Portal Locally
Spin up a lightweight static files server on port `8081` pointing to the pre-compiled build:
```bash
python -m http.server 8081 --directory build/web
```
*(The local static server is now live at `http://localhost:8081`!)*

### 5. Open Your Browser
Open your browser and navigate directly to:
**[http://localhost:8081](http://localhost:8081)**

---

## 📱 Physical Mobile Phone Wi-Fi Testing Guide

To experience the system like a real-world medical professional on a physical smartphone, follow these easy steps:

1.  **Shared Network Connection**: Make sure your physical smartphone (Android or iOS) is connected to the **same Wi-Fi network** as your computer.
2.  **Locate PC Local IP**: Your host computer is pre-routed and mapped on the LAN at IP:
    ```txt
    192.168.100.183
    ```
3.  **Navigate on the Phone**: Open the web browser (Safari or Chrome) on your mobile phone and type:
    ```txt
    http://192.168.100.183:8081
    ```
4.  **Login and Interact**: The high-fidelity portal will render seamlessly with responsive mobile scaling. Tap on any role, log in with pre-seeded accounts, and experience synchronized real-time data flow with the FastAPI server running on your computer!

---

## 🎨 Customizing the Design System Theme

All visual styles (Corporate Indigo `#312E81`, AI Purple `#7C3AED`, Emergency Red `#DC2626`, Success Emerald `#059669`) are configured inside a single core theme file.

To update, adjust, or completely revamp the color palette, open:
`lib/theme/app_colors.dart`

Modify the hex codes inside class variables. All UI panels, glassmorphic dashboards, buttons, and status grids will dynamically adapt across all 15+ screens upon your next compile!
