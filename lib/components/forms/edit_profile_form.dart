import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app_logic/auth.dart';
import 'custom_form_field.dart';

class EditProfileForm extends StatefulWidget {
  final double width;
  String? initialName;
  String? initialSurname;
  DateTime? initialBirthday;

  EditProfileForm({super.key, required this.width, this.initialName, this.initialSurname, this.initialBirthday});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {

  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _birthdayController;

  @override
  void initState(){
    super.initState();
    String date = widget.initialBirthday == null ? '' : DateFormat('dd-MM-yyyy').format(widget.initialBirthday!);
    _nameController = TextEditingController(text: widget.initialName);
    _surnameController = TextEditingController(text: widget.initialSurname);
    _birthdayController = TextEditingController(text: date);
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
                controller: _birthdayController,
              ),
              const SizedBox(
                height: 6,
              ),
              ElevatedButton(
                onPressed: () {
                  updateUser();
                  Navigator.pop(context);},
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
    );
  }

  void updateUser() async {
    final uid = Auth().currentUser?.uid;
    final docUser = FirebaseFirestore.instance.collection('users').doc(uid);
    await docUser.update({
      'name':_nameController.text,
      'surname':_surnameController.text,
      'birthday':DateFormat("dd-MM-yyyy").parse(_birthdayController.text)
    });

  }


}
