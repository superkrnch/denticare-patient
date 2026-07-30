# Deploy Flutter PWA to Firebase Hosting

Patient app only — **Flutter web** deployed as an installable PWA.

**Live URL:** `https://denticare-patient.web.app`

## One-time setup

```bash
cd c:\Users\Victus\Downloads\denticare_patient
npx -y firebase-tools@latest login
npx -y firebase-tools@latest use denticare-app
npx -y firebase-tools@latest hosting:sites:create denticare-patient
```

Skip `hosting:sites:create` if the site already exists.

In [Firebase Console → Authentication → Authorized domains](https://console.firebase.google.com/project/denticare-app/authentication/settings), add:

- `denticare-patient.web.app`
- `denticare-patient.firebaseapp.com`

## Build & deploy

```bash
cd c:\Users\Victus\Downloads\denticare_patient
flutter build web --release
npx -y firebase-tools@latest deploy --only hosting
```

Or use the npm script from the clinic repo root:

```bash
cd c:\Users\Victus\Downloads\denticare_patient
npm run deploy
```

## Install on your phone

1. Open `https://denticare-patient.web.app` on your phone
2. **Android (Chrome):** Menu → **Install app** / **Add to Home screen**
3. **iPhone (Safari):** Share → **Add to Home Screen**

The app opens full-screen like a native app. Firebase Auth and Firestore work over HTTPS.

## Preview before production

```bash
npx -y firebase-tools@latest hosting:channel:deploy preview --expires 7d
```

Test the preview URL on your phone before running a full deploy.
