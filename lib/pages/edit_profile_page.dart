import 'package:flutter/material.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/image_picker.dart';
import 'package:progetto/app_logic/storage.dart';
import '../components/forms/edit_profile_form.dart';
import '../model/user.dart';

class EditProfilePage extends StatelessWidget {
  static const routeName = '/edit_profile';

  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.shortestSide;
    double padding = width / 20;
    final user = ModalRoute.of(context)!.settings.arguments as User;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: EditProfileForm(
          // pass user object "by copy" because such object might be modified in
          // the profile form before update on server
          user: User(
            name: user.name,
            surname: user.surname,
            birthday: user.birthday,
            uid: user.uid
          ),
          auth: Auth(),
          database: Database(),
          storage: Storage(),
          imagePicker: ImagePicker(),
        ),
      ),
    );
  }
}