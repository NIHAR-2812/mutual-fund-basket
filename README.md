# Mutual Fund Basket

A small Flutter full-stack take-home assignment. A user signs up or signs in, explores 12 fictional mutual funds, and adds or removes funds from a personal basket. The basket is stored in SQLite and belongs to the Firebase-authenticated user. **This is a consideration list, not an investment or transaction app.**

## Assignment scope

| Requirement | Implementation |
| --- | --- |
| 10–12 static funds with category, 3-year return, expense ratio, risk | 12 fictional records in `backend/app/funds.json`, seeded into SQLite at first startup |
| `GET /funds`, `POST /basket`, `GET /basket`, `DELETE /basket/{fund_id}` | `backend/app/routers.py` |
| Firebase Authentication | Android email/password sign-up and sign-in; Firebase ID token sent with every API request |
| Basket per user | Backend verifies token and uses its `uid` for basket operations |
| Funds/basket screens, add/remove, loading/error | Flutter screens in `frontend/lib/screens/` |
| Persistence and duplicate handling | SQLite basket table with unique `(user_id, fund_id)` key; duplicate returns HTTP 409 |

## Stack and architecture

Flutter 3.41.6 / Dart 3.11.4; `firebase_core`, `firebase_auth`, `http`; FastAPI / Pydantic; Firebase Admin; SQLite. Flutter state is handled locally with `setState`. No separate state-management package is required for two screens.

```text
Flutter Android app  -- Firebase ID token -->  FastAPI  -->  SQLite
      |                                    verifies token       |-- funds
      +---- Firebase email/password login                     +-- user baskets
```

The app obtains an ID token from Firebase Auth and sends `Authorization: Bearer <token>` to the backend. The backend verifies it with Firebase Admin and uses the verified `uid`; clients cannot select another user's basket by supplying a user ID. The two Firebase configuration files below must refer to the **same Firebase project**.

```text
mutual-fund-basket/
├── README.md
├── backend/
│   ├── app/{main.py,auth.py,database.py,routers.py,schemas.py,funds.json}
│   ├── tests/test_api.py
│   ├── requirements.txt
│   └── .env.example
└── frontend/
    ├── lib/{main.dart,models/,screens/,services/,widgets/}
    ├── android/                Android Studio and Gradle project
    ├── test/
    ├── pubspec.yaml
    └── analysis_options.yaml
```

See [backend/README.md](backend/README.md) and [frontend/README.md](frontend/README.md) for detailed component setup and troubleshooting.

## Prerequisites and Android compatibility

- Windows 11 with Android Studio and the Flutter/Dart plugins; Flutter SDK at `C:\flutter` (your installed Flutter 3.41.6); Android SDK platform 36; an Android emulator or USB device.
- **Install a separate JDK 17** for Android Gradle builds. Your Android Studio bundled JBR is Java 25.0.3. Gradle 8.11.1 in this project is not intended to run on Java 25.
- Python 3.11 or 3.12 is the recommended backend environment, plus a Firebase project. You have Python 3.14; if dependencies install and tests run there, it may work, but the README does not claim 3.14 was verified.

| Build setting | Value in project |
| --- | --- |
| Gradle wrapper | 8.11.1 |
| Android Gradle Plugin | 8.10.1 |
| Kotlin Gradle Plugin | 2.0.21 (Flutter may warn that 2.1+ will be required later) |
| Google Services Gradle plugin | 4.4.2 |
| Java/Kotlin bytecode target | 17 |
| Android SDK | `compileSdk 36`, `targetSdk 35`, `minSdk 23` |
| Android application ID | `com.example.mutual_fund_basket` |

AGP 8.10.x supports API 36 and requires at least Gradle 8.11.1 and JDK 17. The previous Java 25 build error concerned the Gradle runtime. The Kotlin 2.0.21 warning does **not** cause the missing Firebase JSON build failure; upgrade Kotlin only after testing compatibility, not as a workaround for that error.

In PowerShell, replace this example directory with your **actual** JDK 17 folder:

```powershell
$jdk17 = 'C:\Program Files\Eclipse Adoptium\jdk-17.0.XX-hotspot'
& "$jdk17\bin\java.exe" -version
flutter config --jdk-dir="$jdk17"
flutter doctor -v
```

In Android Studio, select the same folder under **Settings → Build, Execution, Deployment → Build Tools → Gradle → Gradle JDK**. If you previously added `org.gradle.java.home` pointing at Android Studio's Java 25 JBR in a local/project/user `gradle.properties`, remove or update that override. No machine-specific JDK path is shipped in this project.

## Firebase setup: two different JSON files

1. In [Firebase Console](https://console.firebase.google.com/), create or select a project. Enable **Authentication → Sign-in method → Email/Password**.
2. Under Project settings, register an Android app with the exact package `com.example.mutual_fund_basket`. Download **`google-services.json`** and put it at `frontend/android/app/google-services.json`. The Android Gradle build **will fail** at `processDebugGoogleServices` until this file is present; it is intentionally absent from the ZIP. Ensure Windows did not add `.txt` to its name.
3. Under **Project settings → Service accounts**, generate a service-account private key JSON for the **same project**. Keep it outside the repository, for example `C:\Users\cbec\firebase-private\service-account.json`. Set `GOOGLE_APPLICATION_CREDENTIALS` to that file for the backend. **Never put this private key in `frontend/`, GitHub, or the ZIP.**

`google-services.json` configures the Android Firebase client; the service-account JSON lets the backend verify Firebase ID tokens. One cannot replace the other. Do not copy an arbitrary example Firebase file.

## Run locally on Windows

Extract the ZIP. Open **two PowerShell terminals**. Paths below assume `C:\Users\cbec\Desktop\mutual-fund-basket`.

**Terminal 1 — backend:**

```powershell
cd C:\Users\cbec\Desktop\mutual-fund-basket\backend
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
$env:GOOGLE_APPLICATION_CREDENTIALS = 'C:\Users\cbec\firebase-private\service-account.json'
Test-Path $env:GOOGLE_APPLICATION_CREDENTIALS
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Install Python 3.12 if `py -3.12` is unavailable; with a suitable existing Python, use `py -3` instead. `Test-Path` **must return `True`**. Set the variable in the same terminal that starts Uvicorn. Wait for **`Application startup complete`**; merely seeing “Uvicorn running” does not establish that the backend started successfully. The server creates `backend/basket.sqlite3` and seeds funds on first startup. Optional `DATABASE_PATH` is documented in `backend/.env.example` and must be set before startup. No `.env` file is auto-loaded.

**Terminal 2 — frontend:**

```powershell
cd C:\Users\cbec\Desktop\mutual-fund-basket\frontend
flutter doctor -v
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
flutter devices
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

The real `google-services.json` and a correctly selected JDK must be in place before `flutter build apk --debug` or `flutter run`. In Android Studio, **File → Open → `frontend`**, select the emulator and run `lib/main.dart`; the emulator API address `http://10.0.2.2:8000` is the app default. Set a different URL using **Run → Edit Configurations → Additional run args** with `--dart-define=API_BASE_URL=...`.

| Where Flutter runs | API base URL |
| --- | --- |
| Android emulator | `http://10.0.2.2:8000` (host laptop) |
| Physical phone on same Wi-Fi | `http://<laptop-LAN-IPv4>:8000`; allow inbound TCP 8000 in Windows Firewall |
| Windows desktop, if desktop support is generated separately | `http://127.0.0.1:8000` |
| Browser on laptop, for backend docs | `http://127.0.0.1:8000/docs` |

`localhost` inside an Android emulator/phone refers to that device, not your laptop. This ZIP only includes Android platform scaffolding; it does not claim Windows desktop support. Development HTTP is permitted by the Android manifest; use HTTPS for a deployed app.

## API contract

**Authentication:** all four endpoints require `Authorization: Bearer <Firebase ID token>`. The app gets this token from its signed-in user. No user ID is accepted in the request body or URL; the backend derives it from the verified token. Invalid/missing token gives HTTP `401` with a `detail` message.

| Request | Success | Relevant errors |
| --- | --- | --- |
| `GET /funds` | `200` list of 12 fund objects | `401` |
| `GET /basket` | `200` list of the current user's fund objects, or `[]` | `401` |
| `POST /basket` with JSON `{"fundId": 1}` | `201` added fund object | `401`, `404` unknown fund, `409` duplicate, `422` invalid input |
| `DELETE /basket/1` | `204` with empty response body | `401`, `404` fund absent from **this user's** basket, `422` invalid path parameter |

Example fund: `{"id":1,"name":"Cedar Growth Equity Fund","category":"Equity","three_year_return":14.5,"expense_ratio":0.65,"risk_level":"High"}`. Error example: `{"detail":"Fund is already in your basket"}`. Returns and ratios are stored as percentages, e.g. `14.5` means 14.5%. The API uses the field `risk_level` for risk. After obtaining a genuine ID token from Firebase Auth, a sample PowerShell request is:

```powershell
$token = '<Firebase ID token from an authenticated client>'
Invoke-RestMethod -Uri 'http://127.0.0.1:8000/funds' -Headers @{ Authorization = "Bearer $token" }
```

## Tests and walkthrough

```powershell
cd C:\Users\cbec\Desktop\mutual-fund-basket\backend
.\.venv\Scripts\Activate.ps1
python -m pytest -q
python -m compileall -q app tests
```

The backend test mocks Firebase verification to check fund count, basket isolation, duplicate add, missing fund, and removal. On the emulator with a real Firebase project and running backend, check registration, login, listing, adding, disabled duplicate action, basket state, removal, empty basket, log out and back in, persistence, and offline/retry behavior. For the assignment submission, create a **public or access-granted GitHub repository** with a few real incremental commits and record a **1–2 minute walkthrough**. This ZIP does not contain a Git history or a recording.

## Troubleshooting

- **Backend: `Set GOOGLE_APPLICATION_CREDENTIALS...`** — obtain the Firebase service-account private key, set its absolute path in the Uvicorn terminal, confirm `Test-Path` is `True`, and restart. Keep the key outside the repository.
- **Android: `google-services.json is missing`** — download the Android configuration for the exact application ID and place it in `frontend/android/app/`; the backend key is not a substitute.
- **Gradle: `IllegalArgumentException: 25.0.3`** — check `flutter doctor -v`, `flutter config --jdk-dir`, Android Studio Gradle JDK, and any `org.gradle.java.home` override. Gradle should run on JDK 17.
- **Kotlin 2.0.21 warning** — it is a forward-looking warning; no forced version change is made here without an Android build verification.
- **API unavailable** — wait for backend `Application startup complete`, use `10.0.2.2` on the emulator, and verify Windows Firewall for physical devices.
- **HTTP 401** — sign in and confirm the Android app and backend key use the same Firebase project.
- **Unexpected old seed data** — seed JSON loads only when the `funds` table is empty. Do not delete `basket.sqlite3` if you need its basket history.

## Assumptions Made

- Twelve fictional funds and illustrative historical returns are hardcoded; no NAV feed or external fund API.
- A basket is unique per Firebase user and fund. Removing a basket item does not remove the fund from the catalog.
- Basic Firebase email/password authentication is sufficient. There are no purchases, payments, SIP execution, KYC, identity checks, or investment advice.
- Local SQLite and development HTTP are appropriate for an assignment demonstration.

## What Would Be Done Differently With More Time

Add live data, pagination/search, fund details and charts, more UI/integration tests, production HTTPS and deployment, stronger credential management, observability, and optional admin tooling. The backend already verifies Firebase tokens; improvements would concern production operation, not replacing token verification that is already implemented.

## Known limitations and verification

The backend tests ran successfully here, and Python source compilation, seed JSON, Dart relative imports, Gradle wrapper archive, and project file references were checked. **Flutter and Android Studio were unavailable in this environment, so `flutter pub get`, `flutter analyze`, `flutter build apk --debug`, and a real emulator run were not executed here. An APK build is not claimed to have passed.** Your previous run reached `processDebugGoogleServices` and failed because `google-services.json` was absent; add your file and run the commands above to establish the current build result.

This assignment implementation does not include production deployment, published credentials, a GitHub repository, or the submission recording. Firebase setup and machine-specific JDK configuration must be done locally.
