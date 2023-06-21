import 'package:flutter/material.dart';
import 'package:progetto/app_logic/auth.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/image_picker.dart';
import 'package:progetto/app_logic/storage.dart';
import '../components/forms/edit_profile_form.dart';
import '../model/user.dart';

class EditProfilePage extends StatelessWidget {
  final Database database;
  final Auth auth;
  final Storage storage;
  final ImagePicker imagePicker;
  final User user;

  const EditProfilePage({
    super.key,
    required this.database,
    required this.auth,
    required this.storage,
    required this.imagePicker,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.shortestSide;
    double padding = width / 20;

    return Scaffold(
      appBar: AppBar(
        key: const Key('EditProfilePageAppBar'),
        title: const Text('Edit profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: OrientationBuilder(
          builder: (context, orientation) {
            return EditProfileForm(
              key: const Key('EditProfilePageForm'),
              // pass user object "by copy" because such object might be modified in
              // the profile form before update on server
              user: User(name: user.name, surname: user.surname, birthday: user.birthday, uid: user.uid),
              auth: auth,
              database: database,
              storage: storage,
              imagePicker: imagePicker,
              direction: orientation == Orientation.landscape ? Axis.horizontal : Axis.vertical,
            );
          },
        ),
      ),
    );
  }
}
