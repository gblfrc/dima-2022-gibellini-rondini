import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final double width;
  final Function toggle;

  const LoginForm({super.key, required this.width, required this.toggle});

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
                width: width,
              ),
              const SizedBox(
                height: 8,
              ),
              CustomFormField(
                text: 'Password',
                width: width,
              ),
              const SizedBox(
                height: 6,
              ),
              const ElevatedButton(
                onPressed: null,
                child: Text(
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
                    onPressed: () {toggle();},
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
                height: width / 4,
                width: width / 4,
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


class RegistrationForm extends LoginForm{
  const RegistrationForm({super.key, required super.width, required super.toggle});

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
                width: width,
              ),
              const SizedBox(
                height: 8,
              ),
              CustomFormField(
                text: 'Username',
                width: width,
              ),
              const SizedBox(
                height: 8,
              ),
              CustomFormField(
                text: 'Password',
                width: width,
              ),
              const SizedBox(
                height: 8,
              ),
              CustomFormField(
                text: 'Name',
                width: width,
              ),
              const SizedBox(
                height: 8,
              ),
              CustomFormField(
                text: 'Surname',
                width: width,
              ),
              const SizedBox(
                height: 8,
              ),
              CustomFormField(
                text: 'Age',
                width: width,
              ),
              const SizedBox(
                height: 6,
              ),
              const ElevatedButton(
                onPressed: null,
                child: Text(
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
                    onPressed: () {toggle();},
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

  const CustomFormField({super.key, required this.text, required this.width});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
