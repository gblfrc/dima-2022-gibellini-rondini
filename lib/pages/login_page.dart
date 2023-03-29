import 'package:flutter/material.dart';

import '../components/forms.dart';

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
    double formWidth = containerWidth - 2 * padding;

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
                            width: formWidth,
                            toggle: _toggleRegister,
                            //errorCallback: displaySnackBar,
                          )
                        : RegistrationForm(
                            width: formWidth,
                            toggle: _toggleRegister,
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
