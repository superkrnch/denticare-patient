# DentiCare Patient — Flutter App

Mobile patient portal for **DentiCare**, built to match the HTML patient app (`denticare-patient`). Connects to the same Firebase project (`denticare-app`) as the clinic staff app.

## Features

- **Sign in** with Google or email/password
- **Forgot password** — secure email reset link
- **Onboarding** for new patients (creates `patients` + `patient_accounts`)
- **Home** — next visit, live queue number, quick actions
- **Appointments** — request (regular or urgent), cancel pending/approved
- **Queue** — real-time updates for today's visit
- **Bills** — invoices and balances
- **Profile** — contact info, health notes, treatment plans

## Run locally

```bash
cd c:\Users\Victus\Downloads\denticare_patient
flutter pub get
flutter run
```

### Web (quick test)

```bash
flutter run -d chrome
```

### Android / iOS

1. Install [Flutter](https://docs.flutter.dev/get-started/install)
2. For **Google Sign-In** on Android, add your app's SHA-1 in Firebase Console and download `google-services.json` into `android/app/`
3. For iOS, add `GoogleService-Info.plist` and URL schemes per [Firebase Flutter setup](https://firebase.google.com/docs/flutter/setup)

> Email/password works without extra native config. Google Sign-In needs platform setup.

## Test account

| Email | Password |
|-------|----------|
| `juan.delacruz@email.com` | `Patient123!` |
| `ana.reyes@email.com` | `Patient123!` |

Seed accounts from the clinic app: `npm run setup:patients` in `dcnew`.

## Project structure

```
lib/
  core/           # theme, constants, booking rules, formatters
  models/         # Patient, Appointment, Queue, etc.
  services/       # Firebase auth + Firestore
  providers/      # App state (Provider)
  screens/        # UI screens matching HTML app tabs
  widgets/        # Shared UI pieces
```

## Related projects

| App | Path |
|-----|------|
| Clinic staff (Vue) | `c:\Users\Victus\Downloads\dcnew` |
| Patient web (HTML) | `c:\Users\Victus\Downloads\denticare-patient` (sibling folder name — use `denticare-patient` for web) |
| Patient mobile (Flutter) | **this project** (`denticare_patient`) |
