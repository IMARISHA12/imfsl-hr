# CLAUDE.md - AI Assistant Guide for IMFSL Staff

## Project Overview

**IMFSL Staff** (`i_m_f_s_l_staff`) is a cross-platform staff management application for the IMFSL (Imarisha Maisha) microfinance institution. It is built with **Flutter** using **FlutterFlow** (a low-code UI builder) and targets iOS, Android, and Web.

- **Version:** 1.0.0+1
- **Dart SDK:** >=3.0.0 <4.0.0
- **Flutter channel:** stable
- **Backend:** Supabase (PostgreSQL, Auth, Storage, Realtime) + Firebase (Dynamic Links, Cloud Functions)
- **Package name:** `i_m_f_s_l_staff`

## Repository Structure

```
imfsl-hr/
├── lib/                          # Dart application source code
│   ├── main.dart                 # App entry point — initializes Firebase, Supabase, theme
│   ├── index.dart                # Page exports
│   ├── auth/                     # Authentication layer
│   │   ├── auth_manager.dart     # Abstract auth interface
│   │   ├── base_auth_user_provider.dart
│   │   └── supabase_auth/        # Supabase auth implementation
│   │       ├── supabase_auth_manager.dart
│   │       ├── supabase_user_provider.dart
│   │       ├── auth_util.dart    # JWT token management, auth helpers
│   │       └── email_auth.dart   # Email sign-in implementation
│   ├── backend/                  # Backend service integrations
│   │   ├── firebase/             # Firebase config
│   │   ├── firebase_dynamic_links/
│   │   └── supabase/             # Supabase client & database layer
│   │       └── database/
│   │           ├── database.dart # Main DB exports
│   │           ├── row.dart      # Base row class
│   │           ├── table.dart    # Base table class
│   │           └── tables/       # ~431 auto-generated table definitions
│   ├── flutter_flow/             # FlutterFlow framework utilities
│   │   ├── flutter_flow_theme.dart    # Theme config (light/dark)
│   │   ├── flutter_flow_util.dart     # Utility functions
│   │   ├── flutter_flow_widgets.dart  # Custom widget library
│   │   ├── flutter_flow_model.dart    # Base model class
│   │   ├── flutter_flow_animations.dart
│   │   └── nav/                  # GoRouter navigation setup
│   │       ├── nav.dart          # Route definitions, AppStateNotifier
│   │       └── serialization_util.dart
│   ├── login_page/               # Login screen
│   │   ├── login_page_widget.dart
│   │   └── login_page_model.dart
│   └── homepagestaff/            # Staff dashboard screen
│       ├── homepagestaff_widget.dart
│       └── homepagestaff_model.dart
├── test/                         # Flutter tests
│   └── widget_test.dart          # Basic widget smoke test
├── firebase/                     # Firebase project config
│   ├── firebase.json             # Deployment config (Firestore, Functions, Storage, Hosting)
│   ├── storage.rules             # Storage security rules
│   └── functions/                # Cloud Functions (Node.js 20)
│       ├── package.json
│       ├── index.js
│       └── api_manager.js
├── android/                      # Android platform code
├── ios/                          # iOS platform code (min iOS 14.0)
├── web/                          # Web platform (Flutter web)
├── assets/                       # Static assets
│   ├── images/, fonts/, videos/, audios/
│   ├── rive_animations/, pdfs/, jsons/
├── pubspec.yaml                  # Flutter dependencies
├── analysis_options.yaml         # Dart analyzer config
└── .mcp.json                     # Supabase MCP server config
```

## Key Technology Stack

| Layer | Technology |
|-------|-----------|
| UI Framework | Flutter + FlutterFlow |
| Language | Dart 3.x |
| State Management | Provider + ChangeNotifier (AppStateNotifier) |
| Routing | GoRouter 12.1.3 |
| Database | Supabase PostgreSQL (~431 tables) |
| Authentication | Supabase Auth (email/password, JWT) |
| File Storage | Supabase Storage |
| Realtime | Supabase Realtime Client |
| Cloud Functions | Firebase Functions (Node.js 20) |
| Dynamic Links | Firebase Dynamic Links |
| Local Storage | SharedPreferences, Hive, SQLite |
| AI/ML (server-side) | LangChain (OpenAI, Anthropic, Google GenAI) |
| Payments (server-side) | Stripe, Braintree, Razorpay |

## Build & Run Commands

### Flutter App

```bash
# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build for Android
flutter build apk

# Build for iOS
flutter build ios

# Build for Web
flutter build web
```

### Firebase Cloud Functions

```bash
cd firebase/functions

# Install dependencies
npm install

# Lint
npm run lint

# Local emulator
npm run serve

# Interactive shell
npm run shell

# View logs
npm run logs
```

### Tests

```bash
# Run Flutter tests
flutter test
```

### Static Analysis

```bash
# Run Dart analyzer
flutter analyze
```

## Architecture & Patterns

### FlutterFlow Code Generation

This project uses **FlutterFlow** for UI development. Key implications:

- Most UI code in `lib/` is **auto-generated** by FlutterFlow
- Each page has a `*_widget.dart` (UI) and `*_model.dart` (state) pair
- The `lib/flutter_flow/` directory contains the FlutterFlow runtime framework — do not modify directly
- Custom code goes in `lib/custom_code/` (excluded from Dart analysis)
- `lib/flutter_flow/custom_functions.dart` is also excluded from analysis

### Authentication Flow

1. App initializes Firebase and Supabase in `main.dart`
2. `SupabaseUserProvider` streams auth state changes
3. `AppStateNotifier` manages global auth state via ChangeNotifier
4. GoRouter redirects unauthenticated users to `/loginPage`
5. Authenticated users see `HomepagestaffWidget` at `/homepagestaff`
6. JWT tokens are managed automatically via `auth_util.dart`

### Navigation (Routes)

Defined in `lib/flutter_flow/nav/nav.dart`:

| Route | Path | Widget | Auth Required |
|-------|------|--------|--------------|
| `_initialize` | `/` | LoginPage or Homepagestaff | No |
| `loginPage` | `/loginPage` | LoginPageWidget | No |
| `Homepagestaff` | `/homepagestaff` | HomepagestaffWidget | Yes |

### Database Schema

The Supabase database has **~431 tables** covering:

- **HR & Attendance:** `attendance`, `attendance_logs`, `attendance_v2`, `staff_performance`
- **Payroll:** `allowance_daily`, `allowance_policy`, `petty_cash_transactions`
- **Leave Management:** `leave_requests`, `leave_types`, `leave_approval_matrix`
- **Finance:** `accounts_payable`, `accounts_receivable`, `bank_accounts`, `journal_entry_lines_readonly`
- **Loans:** `loans`, `loan_assignments`, `loan_collateral`, `credit_score_history`
- **AI/Analytics:** `ai_chat_sessions`, `ai_decisions`, `ai_insights`, `ai_fraud_detection`
- **Security/Audit:** `access_logs`, `security_audit_logs`, `role_permissions`, `audit_logs`
- **Collections:** `collections`, `collection_cases`, `promise_to_pay`
- **Alerts:** `alert_rules`, `alert_logs`, `alert_notifications`
- **Archives:** `z_archive_*` tables for historical data
- **Views:** `mv_*` (materialized views), `v_*` (views)

Table definitions are auto-generated in `lib/backend/supabase/database/tables/`.

### Theme System

- Light and dark mode support via `FlutterFlowTheme`
- Theme persisted to SharedPreferences
- Primary color: `#1E3A8A` (blue)
- Toggle via `_MyAppState.setThemeMode()`

## Configuration

### Supabase

- **API URL:** `https://api.admin-imarishamaisha.co.tz`
- Client initialized in `lib/backend/supabase/supabase.dart` via `SupaFlow.initialize()`

### Firebase

- Config in `lib/backend/firebase/firebase_config.dart`
- Deployment rules in `firebase/firebase.json`
- Storage rules in `firebase/storage.rules`

### MCP (Model Context Protocol)

`.mcp.json` configures a Supabase MCP server for AI-assisted development:
```json
{
  "mcpServers": {
    "supabase": {
      "type": "http",
      "url": "https://mcp.supabase.com/mcp?project_ref=lzyixazjquouicfsfzzu"
    }
  }
}
```

## Linting & Code Quality

- **Dart linting:** `flutter_lints` 4.0.0 + `lints` 4.0.0
- **Analyzer exclusions** (in `analysis_options.yaml`):
  - `lib/custom_code/**`
  - `lib/flutter_flow/custom_functions.dart`
- **Firebase Functions:** ESLint with `--max-warnings=0` (strict)

## Platform Requirements

| Platform | Minimum Version |
|----------|----------------|
| iOS | 14.0 |
| Android | Compile SDK 35, Java 1.8 |
| Web | Flutter web with path URL strategy |
| Node.js (Functions) | 20 |

## Conventions for AI Assistants

### Do

- Read existing code before making changes — the FlutterFlow patterns must be followed
- Follow the widget/model pair pattern (`*_widget.dart` + `*_model.dart`) for new pages
- Use `SupaFlow.client` for database access (the Supabase singleton)
- Use `FlutterFlowTheme.of(context)` for theming
- Use `GoRouter` for navigation; add new routes in `lib/flutter_flow/nav/nav.dart`
- Use `safeSetState()` instead of raw `setState()` (FlutterFlow convention)
- Place custom code in `lib/custom_code/` to keep it separate from generated code
- Run `flutter analyze` before committing to check for lint issues

### Do Not

- Do not modify files in `lib/flutter_flow/` directly — these are FlutterFlow framework files
- Do not manually edit auto-generated table files in `lib/backend/supabase/database/tables/`
- Do not hardcode new credentials — follow the existing pattern in `supabase.dart`
- Do not add dependencies without checking version compatibility with the existing `pubspec.yaml`
- Do not remove the `dependency_overrides` section — it resolves version conflicts

### Git Workflow

- **Main branch:** `master`
- **FlutterFlow output:** `flutterflow` branch (source of generated code)
- Commit messages should be descriptive of the change
- No CI/CD pipelines are currently configured

### Dependency Overrides

The project uses overrides to resolve version conflicts — do not remove:

```yaml
dependency_overrides:
  http: 1.4.0
  rxdart: 0.27.7
  uuid: ^4.0.0
```
