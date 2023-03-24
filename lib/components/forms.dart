import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../app_logic/auth.dart';

class LoginForm extends StatefulWidget {
  final double width;
  final Function toggle;

  const LoginForm({super.key, required this.width, required this.toggle});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  String? errorMessage = '';

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      print('C\'è stato un errore');
      print(e.message);
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
                width: widget.width,
                controller: _controllerEmail,
              ),
              const SizedBox(
                height: 8,
              ),
              CustomFormField(
                text: 'Password',
                width: widget.width,
                controller: _controllerPassword,
              ),
              const SizedBox(
                height: 6,
              ),
              ElevatedButton(
                onPressed: signInWithEmailAndPassword,
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
              const Divider(
                thickness: 2,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                child: Text(
                  'Login with:',
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Container(
                height: widget.width / 4,
                width: widget.width / 4,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade400, width: 2),
                ),
                child: IconButton(
                  onPressed: null,
                  icon: Image.asset('./assets/google-logo.png'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RegistrationForm extends LoginForm {
  const RegistrationForm(
      {super.key, required super.width, required super.toggle});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  String? errorMessage = '';

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      // setState(() {
      //   errorMessage = e.message;
      // });
      print('C\'è stato un errore');
      print(e.message);
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
                text: 'Email',
                width: widget.width,
                controller: _controllerEmail,
              ),
              const SizedBox(
                height: 8,
              ),
              CustomFormField(
                text: 'Username',
                width: widget.width,
                controller: null,
              ),
              const SizedBox(
                height: 8,
              ),
              CustomFormField(
                text: 'Password',
                width: widget.width,
                controller: _controllerPassword,
              ),
              const SizedBox(
                height: 8,
              ),
              CustomFormField(
                text: 'Name',
                width: widget.width,
                controller: null,
              ),
              const SizedBox(
                height: 8,
              ),
              CustomFormField(
                text: 'Surname',
                width: widget.width,
                controller: null,
              ),
              const SizedBox(
                height: 8,
              ),
              CustomFormField(
                text: 'Age',
                width: widget.width,
                controller: null,
              ),
              const SizedBox(
                height: 6,
              ),
              ElevatedButton(
                onPressed: createUserWithEmailAndPassword,
                child: const Text(
                  'REGISTER',
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
                    'Already registered?',
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
                      'Log in here!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomFormField extends StatelessWidget {
  final String text;
  final double width;
  // TODO: remove "?" for controller
  final TextEditingController? controller;

  const CustomFormField(
      {super.key,
      required this.text,
      required this.width,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: EdgeInsets.all(width / 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        hintText: text,
      ),
    );
  }
}
