import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app_logic/database.dart';
import '../../app_logic/exceptions.dart';
import 'custom_form_field.dart';
import 'login_form.dart';

class RegistrationForm extends LoginForm {
  final Database database;

  const RegistrationForm({super.key, required super.toggle, required super.auth, required this.database});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerSurname = TextEditingController();
  final TextEditingController _controllerBirthday = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> createUserWithEmailAndPassword() async {
    try {
      UserCredential credentials = await widget.auth.createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      widget.database.createUser(
        name: _controllerName.text,
        surname: _controllerSurname.text,
        birthday: _controllerBirthday.text == "" ? null : DateFormat.yMd().parse(_controllerBirthday.text),
        uid: credentials.user!.uid,
      );
    } on AuthenticationException catch (ae) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        key: const Key('AuthenticationErrorSnackBar'),
        content: Text(ae.message ?? "An error occurred during authentication."),
      ));
    } on DatabaseException catch (de) {
      try {
        widget.auth.deleteUser();
      } on AuthenticationException {
        // do nothing
      }
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        key: const Key('DatabaseErrorSnackBar'),
        content: Text(de.message ?? "An error occurred when registering personal data."),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        key: const Key('RegistrationFormActualForm'),
        children: [
          CustomFormField(
            key: const Key('RegistrationFormEmailFormField'),
            text: 'Email',
            controller: _controllerEmail,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email field cannot be empty';
              } else if (!value.contains('@')) {
                return 'Illegal value for email field';
              } else {
                return null;
              }
            },
          ),
          const SizedBox(
            height: 8,
          ),
          CustomFormField(
            key: const Key('RegistrationFormPasswordFormField'),
            text: 'Password',
            controller: _controllerPassword,
            obscure: true,
            validator: (value) {
              return (value == null || value.isEmpty) ? 'Password field cannot be empty' : null;
            },
          ),
          const SizedBox(
            height: 8,
          ),
          CustomFormField(
            key: const Key('RegistrationFormNameFormField'),
            text: 'Name',
            controller: _controllerName,
            validator: (value) {
              return (value == null || value.isEmpty) ? 'Name field cannot be empty' : null;
            },
          ),
          const SizedBox(
            height: 8,
          ),
          CustomFormField(
            key: const Key('RegistrationFormSurnameFormField'),
            text: 'Surname',
            controller: _controllerSurname,
            validator: (value) {
              return (value == null || value.isEmpty) ? 'Surname field cannot be empty' : null;
            },
          ),
          const SizedBox(
            height: 8,
          ),
          LayoutBuilder(builder: (context, constraint) {
            return DateTimeField(
              key: const Key('RegistrationFormBirthdayFormField'),
              format: DateFormat.yMd(),
              resetIcon: null,
              onShowPicker: (context, currentValue) => showDatePicker(
                  context: context,
                  initialDate: currentValue ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100)),
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () {
                    _controllerBirthday.text = "";
                  },
                  icon: const Icon(Icons.close),
                ),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: EdgeInsets.all(constraint.maxWidth / 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                hintText: "Birthday",
              ),
              controller: _controllerBirthday,
            );
          }),
          const SizedBox(
            height: 6,
          ),
          FilledButton(
            key: const Key('RegistrationFormButton'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                createUserWithEmailAndPassword();
              }
            },
            child: const Text(
              'REGISTER',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text(
                'Already registered?',
                style: TextStyle(color: Colors.grey[700]),
              ),
              TextButton(
                key: const Key('RegistrationFormToLoginButton'),
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
    );
  }
}
