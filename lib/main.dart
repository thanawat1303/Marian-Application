import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marian/loginPage.dart';
import 'package:marian/reviewUser.dart';
import 'package:marian/signUp.dart';
import 'package:marian/allBody.dart';
import 'package:marian/UserData.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const Index());
}

class Index extends StatelessWidget {
  const Index({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) {
            return UserProvider();
          },
        )
      ],
      child: pageMaterialApp(),
    );
  }

  MaterialApp pageMaterialApp() {
    return MaterialApp(
      title: 'MaRian',
      theme: ThemeData(primaryColor: const Color.fromARGB(255, 148, 72, 105)),
      initialRoute: '/',
      routes: {
        '/': (context) => FirebaseAuth.instance.currentUser == null
            ? const LoginPage()
            : const allBodyMarian(),
        '/signUp': (context) => const signUp(),
        //'/forgotPassword': (context) => ForgotPassword(),
      },
    );
  }
}
