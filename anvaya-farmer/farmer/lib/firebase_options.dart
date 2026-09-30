// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD9ZWhm1g3XTTkom2V98E8oMLFoJWOgr4o',
    appId: '1:36104314118:web:anvaya-farmer',
    messagingSenderId: '36104314118',
    projectId: 'anvaya-38c1f',
    authDomain: 'anvaya-38c1f.firebaseapp.com',
    storageBucket: 'anvaya-38c1f.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD9ZWhm1g3XTTkom2V98E8oMLFoJWOgr4o',
    appId: '1:36104314118:android:f7f1ee344d853e61d15287',
    messagingSenderId: '36104314118',
    projectId: 'anvaya-38c1f',
    storageBucket: 'anvaya-38c1f.firebasestorage.app',
  );
}
