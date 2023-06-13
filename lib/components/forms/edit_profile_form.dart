import 'dart:io';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app_logic/auth.dart';
import '../../app_logic/database.dart';
import '../../app_logic/exceptions.dart';
import '../../app_logic/storage.dart';
import '../../model/user.dart';
import 'custom_form_field.dart';

class EditProfileForm extends StatefulWidget {
  final double width;
  final User user;

  const EditProfileForm({super.key, required this.width, required this.user});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _birthdayController;
  Image? _image;
  String? _imagePath;

  // TODO: handle case of user with no picture

  @override
  void initState() {
    super.initState();
    String date = widget.user.birthday == null
        ? ''
        : DateFormat.yMd().format(widget.user.birthday!);
    _nameController = TextEditingController(text: widget.user.name);
    _surnameController = TextEditingController(text: widget.user.surname);
    _birthdayController = TextEditingController(text: date);
  }

  @override
  Widget build(BuildContext context) {
    String pictureUrl = "profile-pictures/${Auth().currentUser!.uid}";

    return ListView(
      children: [
        Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 4,
              child: _image ??
                  FutureBuilder(
                    future: Storage().downloadURL(pictureUrl),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.network(snapshot.data!);
                      } else {
                        return LayoutBuilder(
                          builder: (context, constraint) {
                            return Icon(
                              Icons.account_circle,
                              size: constraint.biggest.height,
                              color: Colors.grey,
                            );
                          },
                        );
                      }
                    },
                  ),
            ),
            Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      allowMultiple: false,
                      type: FileType.image,
                    );
                    if (result != null) {
                      _imagePath = result.files.single.path!;
                      setState(() {
                        _image = Image.file(File(_imagePath!));
                      });
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No file was selected.'),
                        ),
                      );
                      // User canceled the picker
                    }
                  },
                  child: const Text('Pick picture'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (_imagePath != null) {
                      File file = File(_imagePath!);
                      await Storage().uploadFile(
                          file, pictureUrl);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Profile picture updated successfully.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Save picture'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Form(
              // TODO: add form key
              child: Column(
                children: [
                  CustomFormField(
                    text: 'Name',
                    width: widget.width,
                    controller: _nameController,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  CustomFormField(
                    text: 'Surname',
                    width: widget.width,
                    controller: _surnameController,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  DateTimeField(
                    format: DateFormat.yMd(),
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                          context: context,
                          initialDate: currentValue ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100));
                    },
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
                    controller: _birthdayController,
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  FilledButton(
                    onPressed: () async {
                      try {
                        Database().updateUser(
                          User(
                            name: _nameController.text,
                            surname: _surnameController.text,
                            birthday: DateFormat.yMd()
                                .parse(_birthdayController.text),
                            uid: Auth().currentUser!.uid,
                          ),
                        );
                        Navigator.pop(context);
                      } on DatabaseException {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('An error occurred during the update.'),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'UPDATE',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
