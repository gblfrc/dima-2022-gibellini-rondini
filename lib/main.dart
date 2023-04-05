import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:progetto/app_logic/widget_tree.dart';
import 'package:progetto/pages/edit_profile_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      routes: {
        EditProfilePage.routeName: (context) => const EditProfilePage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // elevatedButtonTheme: ElevatedButtonThemeData(
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: Theme.of(context).primaryColor,
        //     disabledBackgroundColor: Theme.of(context).primaryColor,
        //   ),
        // ),
      ),
      home: const WidgetTree(),
    );
  }
}

