import 'dart:io';
import 'dart:math';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app_logic/auth.dart';
import '../../app_logic/database.dart';
import '../../app_logic/exceptions.dart';
import '../../app_logic/image_picker.dart';
import '../../app_logic/storage.dart';
import '../../model/user.dart';
import 'custom_form_field.dart';

class EditProfileForm extends StatefulWidget {
  final User user;
  final Auth auth;
  final Storage storage;
  final Database database;
  final ImagePicker imagePicker;
  final Axis direction;

  const EditProfileForm({
    super.key,
    required this.user,
    required this.auth,
    required this.storage,
    required this.database,
    required this.imagePicker,
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
      children: [
        Flexible(
            flex: 1,
            child: LayoutBuilder(
              builder: (context, constraint) {
                return SizedBox(
                  height: constraint.maxHeight,
                  width: constraint.maxWidth,
                  child: _ImageSection(
                    key: const Key('EditProfileImageSection'),
                    storage: widget.storage,
                    database: widget.database,
                    auth: widget.auth,
                    imagePicker: widget.imagePicker,
                  ),
                );
              },
            )),
        Flexible(
          flex: 1,
          child: LayoutBuilder(
            builder: (context, constraint) {
              return SizedBox(
                  height: constraint.maxHeight,
                  width: constraint.maxWidth,
                  child: _DataSection(
                    key: const Key('EditProfileDataSection'),
                    user: widget.user,
                    database: widget.database,
                    auth: widget.auth,
                  ));
            },
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
  final ImagePicker imagePicker;

  const _ImageSection({
    super.key,
    required this.storage,
    required this.database,
    required this.auth,
    required this.imagePicker,
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
              key: const Key('EditProfileFormImageOrAccountIcon'),
              height: min(constraint.maxHeight, constraint.maxWidth),
              child: _image ??
                  FutureBuilder(
                    future: widget.storage.downloadURL(pictureUrl),
                    builder: (context, snapshot) {
                      Icon fallbackIcon = Icon(
                        key: const Key('EditProfileFormAccountIcon'),
                        Icons.account_circle,
                        size: constraint.biggest.height,
                        color: Colors.grey,
                      );
                      if (snapshot.hasData) {
                        return Image.network(
                          snapshot.data!,
                          key: const Key('EditProfileFormProfilePicture'),
                          errorBuilder: (context, exception, stackTrace) {
                            return fallbackIcon;
                          },
                        );
                      } else {
                        return fallbackIcon;
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
            spacing: MediaQuery.of(context).size.shortestSide / 10,
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton(
                key: const Key('EditProfileFormPickPictureButton'),
                onPressed: () async {
                  _imageLocalPath = await widget.imagePicker.pickImage();
                  if (_imageLocalPath != null) {
                    setState(() {
                      _image = Image.file(
                        File(_imageLocalPath!),
                        key: const Key('EditProfileFormLocalImage'),
                      );
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          key: Key('SuccessfulImageSelectionSnackBar'),
                          content: Text('Image selected successfully.'),
                        ),
                      );
                    });
                  } else {
                    if (mounted) {
                      // User canceled the picker
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          key: Key('NoImageSelectedSnackBar'),
                          content: Text('No file was selected.'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Pick picture'),
              ),
              FilledButton(
                key: const Key('EditProfileFormSavePictureButton'),
                onPressed: () async {
                  if (_imageLocalPath != null) {
                    try {
                      File file = File(_imageLocalPath!);
                      await widget.storage.uploadFile(file, pictureUrl);
                      if (mounted) {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            key: Key('SuccessfullySavedImageSnackBar'),
                            content: Text('Profile picture updated successfully.'),
                          ),
                        );
                      }
                    } on Exception {
                      if (mounted) {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            key: Key('ErrorInSavingImageSnackBar'),
                            content: Text('Profile picture updated successfully.'),
                          ),
                        );
                      }
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          key: Key('NotPickedImageSnackBar'),
                          content: Text('Please, pick an image before saving it.'),
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

  const _DataSection({super.key, required this.user, required this.database, required this.auth});

  @override
  State<_DataSection> createState() => _DataSectionState();
}

class _DataSectionState extends State<_DataSection> {
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _birthdayController;
  final _formKey = GlobalKey<FormState>();

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
      key: _formKey,
      child: ListView(
        key: const Key('EditProfileFormDataSectionScrollable'),
        children: [
          CustomFormField(
            key: const Key('EditProfileFormNameField'),
            text: 'Name',
            controller: _nameController,
            validator: (value) {
              return (value == null || value.isEmpty) ? 'Name field cannot be empty.' : null;
            },
          ),
          const SizedBox(
            height: 8,
          ),
          CustomFormField(
            key: const Key('EditProfileFormSurnameField'),
            text: 'Surname',
            controller: _surnameController,
            validator: (value) {
              return (value == null || value.isEmpty) ? 'Surname field cannot be empty.' : null;
            },
          ),
          const SizedBox(
            height: 8,
          ),
          LayoutBuilder(builder: (context, constraint) {
            return DateTimeField(
              key: const Key('EditProfileFormBirthdayField'),
              format: DateFormat.yMd(),
              resetIcon: null,
              onShowPicker: (context, currentValue) {
                return showDatePicker(
                    context: context,
                    initialDate: currentValue ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now());
              },
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () {
                    _birthdayController.text = "";
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
              controller: _birthdayController,
            );
          }),
          const SizedBox(
            height: 6,
          ),
          Column(
            children: [
              FilledButton(
                key: const Key('EditProfileFormUpdateButton'),
                onPressed: () async {
                  try {
                    if (_formKey.currentState!.validate()) {
                      widget.user.name = _nameController.text;
                      widget.user.surname = _nameController.text;
                      widget.user.birthday =
                          _birthdayController.text == "" ? null : DateFormat.yMd().parse(_birthdayController.text);
                      widget.user.uid = widget.auth.currentUser!.uid;
                      widget.database.updateUser(
                        widget.user,
                      );
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          key: Key('SuccessfulUpdateSnackBar'),
                          content: Text('Account information updated successfully.'),
                        ),
                      );
                    }
                  } on DatabaseException {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        key: Key('ErrorInUserUpdateSnackBar'),
                        content: Text('An error occurred during the update.'),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Update',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
