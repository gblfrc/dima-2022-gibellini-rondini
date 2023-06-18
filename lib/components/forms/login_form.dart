import 'package:flutter/material.dart';
import 'package:progetto/app_logic/exceptions.dart';
import '../../app_logic/auth.dart';
import 'custom_form_field.dart';

class LoginForm extends StatefulWidget {
  final double width;
  final Function toggle;

  //final Function errorCallback;

  const LoginForm({super.key, required this.width, required this.toggle});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword(BuildContext context) async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on AuthenticationException catch (e) {
      //widget.errorCallback(e.message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Something went wrong. Please try again."),
        ),
      );
      // print('ERROR: $e.message');
      // setState(() {
      //   errorMessage = e.message;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Form(
          // TODO: add form key
          child: Column(
            children: [
              CustomFormField(
                text: 'Username',
                controller: _controllerEmail,
              ),
              const SizedBox(
                height: 8,
              ),
              CustomFormField(
                text: 'Password',
                controller: _controllerPassword,
                obscure: true,
              ),
              const SizedBox(
                height: 6,
              ),
              FilledButton(
                onPressed: () {
                  signInWithEmailAndPassword(context);
                },
                child: const Text(
                  'LOGIN',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'New to this app?',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.toggle();
                    },
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.all(5),
                    ),
                    child: const Text(
                      'Register here!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  )
                ],
              ),
              // section for Google login
              // (keep commented until Google sign in is not implemented)
              // const Divider(
              //   thickness: 2,
              // ),
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
              //   child: Text(
              //     'Login with:',
              //     style: TextStyle(
              //       color: Colors.grey[700],
              //     ),
              //   ),
              // ),
              // Container(
              //   height: widget.width / 4,
              //   width: widget.width / 4,
              //   padding: EdgeInsets.zero,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(4),
              //     border: Border.all(color: Colors.grey.shade400, width: 2),
              //   ),
              //   child: IconButton(
              //     onPressed: null,
              //     icon: Image.asset('./assets/google-logo.png'),
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }
}
