# IMFSL Staff - HR Management App

## Project Overview

IMFSL Staff is a Flutter mobile application for staff management at IMFSL (Imarisha Microfinance). It provides HR, attendance tracking, and leave management for microfinance staff in Tanzania. Built with FlutterFlow, the UI is primarily in Swahili.

## Tech Stack

- **Framework**: Flutter (Dart SDK >=3.0.0 <4.0.0)
- **Backend**: Supabase (auth, database, storage, realtime)
- **State Management**: Provider
- **Navigation**: GoRouter v12.1.3
- **AI**: Google Generative AI (Gemini 1.5 Pro/Flash)
- **Secondary**: Firebase (performance monitoring)

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── index.dart                   # Barrel file exporting all pages
├── auth/                        # Authentication (Supabase email auth)
│   └── supabase_auth/           # Supabase-specific auth implementation
├── backend/
│   ├── api_requests/            # API manager and endpoint definitions
│   ├── gemini/                  # Google Generative AI integration
│   └── supabase/
│       ├── database/tables/     # 427 generated Supabase table classes
│       └── storage/             # File storage operations
├── flutter_flow/                # FlutterFlow framework utilities
│   └── nav/                     # Router configuration
└── [page_name]/                 # Each page: *_widget.dart + *_model.dart
    ├── splash/                  # Splash screen
    ├── login_page/              # Login
    ├── signup_signup/           # Multi-step registration
    ├── homepagestaff/           # Main dashboard
    ├── historiaya_mahudhurio/   # Attendance history
    ├── leavepage/               # Leave requests
    ├── profile/                 # Staff profile
    ├── usajili/                 # Profile completion form
    └── msaada/                  # Help/Support
```

## Key Conventions

- **Page pattern**: Each page has a `*_widget.dart` (UI) and `*_model.dart` (state/logic) pair
- **FlutterFlow generated**: Most code follows FlutterFlow patterns — avoid restructuring generated code
- **Swahili UI**: Labels and text are in Swahili (e.g., "Mahudhurio" = Attendance, "Likizo" = Leave)
- **Supabase tables**: Auto-generated table classes in `lib/backend/supabase/database/tables/`

## Build & Test

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze
```

## API Endpoints

- Base URL: `https://api.admin-imarishamaisha.co.tz`
- Auth: Supabase JWT tokens
- Key RPCs: `fn_submit_leave_request`, `fn_get_staff_monthly_stats`

## Important Notes

- The `analysis_options.yaml` excludes `lib/custom_code/**` and `lib/flutter_flow/custom_functions.dart` from analysis
- Material Design 3 is disabled (`useMaterial3: false`)
- MCP integration with Supabase is configured in `.mcp.json`
