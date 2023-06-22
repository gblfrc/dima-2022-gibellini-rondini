import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progetto/pages/login_page.dart';
import 'package:progetto/pages/main_screens.dart';

import 'app_logic/auth.dart';
import 'app_logic/storage.dart';
import 'app_logic/database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomApp(
      onLogged: const MainScreens(),
      onNotLogged: LoginPage(database: Database(), auth: Auth()),
      auth: Auth(),
      storage: Storage(),
      database: Database(),
    );
  }
}

class CustomApp extends StatelessWidget {
  final Widget onLogged;
  final Widget onNotLogged;
  final Auth auth;
  final Storage storage;
  final Database database;

  const CustomApp({
    super.key,
    required this.onLogged,
    required this.onNotLogged,
    required this.auth,
    required this.storage,
    required this.database,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
          fontFamily: "Montserrat",
          snackBarTheme: const SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
          )),
      home: StreamBuilder(
          stream: auth.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return onLogged;
            } else {
              return onNotLogged;
            }
          }),
    );
  }
}
