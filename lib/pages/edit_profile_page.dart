import 'package:flutter/material.dart';
import '../components/forms/edit_profile_form.dart';
import '../model/user.dart';

class EditProfilePage extends StatelessWidget {
  static const routeName = '/edit_profile';

  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double padding = width / 20;
    final user = ModalRoute.of(context)!.settings.arguments as User;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: EditProfileForm(
          width: width - 2 * padding,
          user: user,
        ),
      ),
    );
  }
}