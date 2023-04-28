import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../app_logic/auth.dart';
import 'custom_form_field.dart';

class CreateGoalForm extends StatefulWidget {
  final double width;

  CreateGoalForm({super.key, required this.width});

  @override
  State<CreateGoalForm> createState() => _CreateGoalFormState();
}

class _CreateGoalFormState extends State<CreateGoalForm> {
  late TextEditingController _targetValueController;
  late String? _type = "distanceGoal";
  late bool? _isMin = true;

  @override
  void initState() {
    super.initState();
    _targetValueController = TextEditingController();
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
              const ListTile(
                title: Text("Goal type"),
              ),
              RadioListTile(
                title: const Text("Distance goal"),
                value: "distanceGoal",
                groupValue: _type,
                onChanged: (String? value) {
                  setState(() {
                    _type = value;
                  });
                },
              ),
              RadioListTile(
                title: const Text("Time goal"),
                value: "timeGoal",
                groupValue: _type,
                onChanged: (String? value) {
                  setState(() {
                    _type = value;
                  });
                },
              ),
              const SizedBox(
                height: 8,
              ),
              const ListTile(
                title: Text("Target type"),
              ),
              RadioListTile(
                title: const Text("Run for at least..."),
                value: true,
                groupValue: _isMin,
                onChanged: (bool? value) {
                  setState(() {
                    _isMin = value;
                  });
                },
              ),
              RadioListTile(
                title: const Text("Run for at most..."),
                value: false,
                groupValue: _isMin,
                onChanged: (bool? value) {
                  setState(() {
                    _isMin = value;
                  });
                },
              ),
              const SizedBox(
                height: 8,
              ),
              CustomFormField(
                // TODO: Modify CustomFormField so that it can set the field to be numeric only (keyboardType: TextInputType.number)
                text: 'Target value',
                width: widget.width,
                controller: _targetValueController,
              ),
              const SizedBox(
                height: 8,
              ),
              const SizedBox(
                height: 6,
              ),
              ElevatedButton(
                onPressed: () {
                  createGoal();
                },
                child: const Text('SAVE'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /*void createGoal() async {
    final uid = Auth().currentUser?.uid;
    final docUser = FirebaseFirestore.instance.collection('users').doc(uid);
  }*/

  void createGoal() async {
    try {
      final uid = Auth().currentUser?.uid;
      final docUser = FirebaseFirestore.instance.collection('users').doc(uid);
      final data = {
        "completed": false,
        "currentValue": 0,
        "targetValue": int.parse(_targetValueController.text),
        "isMin": _isMin,
        "type": _type,
        "userID": docUser, // TODO: When writing Firestore rules, remember to check that this docUser.id is equal to the actual user
      };
      await FirebaseFirestore.instance.collection("goals").add(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Goal created!"),
        ),
      );
      Navigator.of(context).pop();
    } on Error {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Please try again."),
        ),
      );
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Please try again."),
        ),
      );
    }
  }
}
