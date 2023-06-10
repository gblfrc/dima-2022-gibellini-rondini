import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app_logic/auth.dart';
import '../../app_logic/database.dart';
import '../../app_logic/exceptions.dart';
import 'custom_form_field.dart';
import 'login_form.dart';
import '../../model/user.dart' as model_user; // use as in import because User is also a class in the firebase auth library

class RegistrationForm extends LoginForm {
  const RegistrationForm(
      {super.key, required super.width, required super.toggle});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerSurname = TextEditingController();
  final TextEditingController _controllerBirthday = TextEditingController();

  Future<void> createUserWithEmailAndPassword() async {
    try {
      UserCredential credentials = await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      Database.createUser(
        model_user.User(
          name: _controllerName.text,
          surname: _controllerSurname.text,
          birthday: DateFormat.yMd().parse(_controllerBirthday.text),
          uid: credentials.user!.uid,
        ),
      );
    }on AuthenticationException catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Authentication exception"),
        ),
      );
    } on DatabaseException catch (e) {
      // TODO: handle case in which a user is created for Firebase Auth but
      // TODO:          it is not created for Firestore
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Database Exception"),
        ),
      );

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
                text: 'Password',
                width: widget.width,
                controller: _controllerPassword,
                obscure: true,
              ),
              const SizedBox(
                height: 8,
              ),
              CustomFormField(
                text: 'Name',
                width: widget.width,
                controller: _controllerName,
              ),
              const SizedBox(
                height: 8,
              ),
              CustomFormField(
                text: 'Surname',
                width: widget.width,
                controller: _controllerSurname,
              ),
              const SizedBox(
                height: 8,
              ),
              DateTimeField(
                format: DateFormat("dd-MM-yyyy"),
                onShowPicker: (context, currentValue) => showDatePicker(
                    context: context,
                    initialDate: currentValue ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: EdgeInsets.all(widget.width / 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  hintText: "Birthday",
                ),
                controller: _controllerBirthday,
              ),
              const SizedBox(
                height: 6,
              ),
              FilledButton(
                onPressed: createUserWithEmailAndPassword,
                child: const Text(
                  'REGISTER',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                // mainAxisSize: MainAxisSize.max,
                // mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
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
