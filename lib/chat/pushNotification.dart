import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

class FirebasePushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging();

  Future<void>initialize() {
    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        
      },
    );
  }
}