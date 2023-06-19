import 'package:flutter/material.dart';
import 'package:progetto/app_logic/database.dart';

import '../app_logic/auth.dart';
import '../components/forms/login_form.dart';
import '../components/forms/registration_form.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLogin = true;

  // void displaySnackBar(String errorMessage) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(errorMessage),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width * 2 / 3;
    double padding = containerWidth / 15;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
        child: SafeArea(
          child: Center(
            child: Material(
              elevation: 15,
              child: Container(
                width: containerWidth,
                decoration: BoxDecoration(
                  //TODO: find a better color
                  color: Colors.yellow[100],
                ),
                child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: _isLogin
                        ? LoginForm(
                            toggle: _toggleRegister,
                            auth: Auth(),
                            //errorCallback: displaySnackBar,
                          )
                        : RegistrationForm(
                            toggle: _toggleRegister,
                            auth: Auth(),
                            database: Database(),
                            //errorCallback: displaySnackBar,
                          )),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleRegister() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }
}
