# Flutter Android frontend

Open **this `frontend/` directory** in Android Studio as a Flutter project. See [`../README.md`](../README.md) for the complete assignment overview, backend setup, API contract, JDK configuration, and submission requirements.

## Firebase and Android prerequisites

Use Flutter 3.41.6, Android SDK platform 36, and a **separate JDK 17** for Gradle. Your Android Studio JBR Java 25.0.3 is not the Gradle runtime for this project. Configure Flutter with `flutter config --jdk-dir="<actual JDK 17 directory>"`, select JDK 17 as Android Studio's Gradle JDK, and check `flutter doctor -v`.

Register Android application ID `com.example.mutual_fund_basket` in the **same Firebase project as the backend service account**. Enable Authentication → Email/Password. Download the Android app's real `google-services.json` into:

```text
frontend/android/app/google-services.json
```

The Google Services Gradle plugin is enabled; `flutter build apk --debug` **cannot succeed without that file**. Do not put the backend's private service-account JSON here. Both files are intentionally excluded from the ZIP.

## Run and inspect

```powershell
cd C:\Users\cbec\Desktop\mutual-fund-basket\frontend
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Start the FastAPI backend separately and wait for `Application startup complete`. The Android emulator uses `10.0.2.2` for the host laptop; its `localhost` is not the laptop. For a physical phone on the same Wi-Fi, use `--dart-define=API_BASE_URL=http://<laptop-LAN-IPv4>:8000` and allow inbound port 8000. The default URL in `lib/services/fund_api.dart` is the Android emulator address. In Android Studio, put a custom `--dart-define` in **Run → Edit Configurations → Additional run args**.

`lib/main.dart` chooses login or the fund/basket home according to Firebase auth state. `lib/screens/` contains pages, `lib/models/` the fund model, `lib/services/` Firebase authentication and HTTP access, and `lib/widgets/` the fund card. The app displays loading, empty, and error states, disables the Add action for selected funds, and offers retry and pull to refresh.

The Kotlin 2.0.21 message is a warning about future Flutter support. The concrete failure you reported at `processDebugGoogleServices` is caused by the missing Android Firebase JSON. This environment did not execute a Flutter/Android build; use the commands above to verify the extracted project on your machine.
