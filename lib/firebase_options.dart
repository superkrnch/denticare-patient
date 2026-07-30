import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError('DentiCare patient app is not supported on this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB6_GATiB_GJEytbjYSn8knspQvZsEiwVM',
    appId: '1:798359367441:web:7101b335760119d7f766b0',
    messagingSenderId: '798359367441',
    projectId: 'denticare-app',
    authDomain: 'denticare-app.firebaseapp.com',
    storageBucket: 'denticare-app.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC0fcnotMLhd4F8OVn-hCXxnGX_su7w6l4',
    appId: '1:798359367441:android:71f7ef6ecbb7e1ebf766b0',
    messagingSenderId: '798359367441',
    projectId: 'denticare-app',
    storageBucket: 'denticare-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB6_GATiB_GJEytbjYSn8knspQvZsEiwVM',
    appId: '1:798359367441:ios:0000000000000000000000',
    messagingSenderId: '798359367441',
    projectId: 'denticare-app',
    storageBucket: 'denticare-app.firebasestorage.app',
    iosBundleId: 'com.denticare.denticarePatient',
  );

  static const FirebaseOptions macos = ios;
  static const FirebaseOptions windows = web;
}
