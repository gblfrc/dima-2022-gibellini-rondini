import 'package:flutter/material.dart';
import 'package:progetto/pages/main_screens.dart';
import '../pages/account_page.dart';
import '../pages/friends_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/search_page.dart';
import 'auth.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  // const _WidgetTreeState({super.key});


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Auth().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const MainScreens();
          } else {
            return const LoginPage();
          }
        });
  }
}
