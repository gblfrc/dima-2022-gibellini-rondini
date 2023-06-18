import 'dart:io';
import 'dart:math';

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
  final Auth auth;
  final Storage storage;
  final Database database;
  final Axis direction;

  const EditProfileForm({
    super.key,
    required this.width,
    required this.user,
    required this.auth,
    required this.storage,
    required this.database,
    this.direction = Axis.vertical,
  });

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  @override
  Widget build(BuildContext context) {
    return Flex(
      key: widget.direction == Axis.vertical
          ? const Key('VerticalEditProfileForm')
          : const Key('HorizontalEditProfileForm'),
      direction: widget.direction,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
          flex: 1,
          child: _ImageSection(
              key: const Key('EditProfileImageSection'),
              storage: widget.storage,
              database: widget.database,
              auth: widget.auth),
        ),
        Flexible(
          flex: 1,
          child: ListView(
            children: [
              _DataSection(
                key: const Key('EditProfileDataSection'),
                user: widget.user,
                database: widget.database,
                auth: widget.auth,
                width: widget.width,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImageSection extends StatefulWidget {
  final Storage storage;
  final Database database;
  final Auth auth;

  const _ImageSection({
    super.key,
    required this.storage,
    required this.database,
    required this.auth,
  });

  @override
  State<_ImageSection> createState() => _ImageSectionState();
}

class _ImageSectionState extends State<_ImageSection> {
  Image? _image;
  String? _imageLocalPath;
  late String pictureUrl = "profile-pictures/${widget.auth.currentUser!.uid}";

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      children: [
        Flexible(
          flex: 4,
          child: LayoutBuilder(builder: (context, constraint) {
            return SizedBox(
              height: min(constraint.maxHeight, constraint.maxWidth),
              child: _image ??
                  FutureBuilder(
                    future: widget.storage.downloadURL(pictureUrl),
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
            );
          }),
        ),
        Flexible(
          flex: 1,
          child: Wrap(
            direction: Axis.horizontal,
            spacing: MediaQuery.of(context).size.shortestSide/10,
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    allowMultiple: false,
                    type: FileType.image,
                  );
                  if (result != null) {
                    _imageLocalPath = result.files.single.path!;
                    setState(() {
                      _image = Image.file(File(_imageLocalPath!));
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
                  if (_imageLocalPath != null) {
                    File file = File(_imageLocalPath!);
                    await widget.storage.uploadFile(file, pictureUrl);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile picture updated successfully.'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Save picture'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DataSection extends StatefulWidget {
  final Database database;
  final Auth auth;
  final User user;
  final double width;

  const _DataSection({super.key, required this.user, required this.database, required this.auth, required this.width});

  @override
  State<_DataSection> createState() => _DataSectionState();
}

class _DataSectionState extends State<_DataSection> {
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _birthdayController;

  @override
  void initState() {
    super.initState();
    String date = widget.user.birthday == null ? '' : DateFormat.yMd().format(widget.user.birthday!);
    _nameController = TextEditingController(text: widget.user.name);
    _surnameController = TextEditingController(text: widget.user.surname);
    _birthdayController = TextEditingController(text: date);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: const Key('EditProfileFormActualForm'),
      child: Column(
        children: [
          CustomFormField(
            text: 'Name',
            controller: _nameController,
          ),
          const SizedBox(
            height: 8,
          ),
          CustomFormField(
            text: 'Surname',
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
                widget.database.updateUser(
                  User(
                    name: _nameController.text,
                    surname: _surnameController.text,
                    birthday: DateFormat.yMd().parse(_birthdayController.text),
                    uid: widget.auth.currentUser!.uid,
                  ),
                );
                Navigator.pop(context);
              } on DatabaseException {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('An error occurred during the update.'),
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
    );
  }
}
