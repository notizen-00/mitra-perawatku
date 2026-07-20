import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'app.dart';
import 'core/di/injection_container.dart';
import 'core/services/fcm_push_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  await sl<FcmPushService>().initialize();
  final fcmToken = await sl<FcmPushService>().getToken();
  developer.log('FCM TOKEN: $fcmToken', name: 'token fcm');
  runApp(const App());
}
