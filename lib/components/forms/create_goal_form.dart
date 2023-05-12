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

  @override
  void initState() {
    super.initState();
    _targetValueController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double padding = width / 20;
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Form(
        // TODO: add form key and form validation (negative values, decimal minutes...)
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
            RadioListTile(
              title: const Text("Speed goal"),
              value: "speedGoal",
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
            Flex(
              direction: Axis.horizontal,
              children: [
                Flexible(
                  flex: 5,
                  child: CustomFormField(
                    text: 'Target value',
                    width: widget.width,
                    controller: _targetValueController,
                    numericOnly: true,
                  ),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Text(
                    _type == "distanceGoal" ? "km" : (_type == "timeGoal" ? "min" : "km/h"),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
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
        "targetValue": double.parse(_targetValueController.text),
        "type": _type,
        "userID": docUser,
        // TODO: When writing Firestore rules, remember to check that this docUser.id is equal to the actual user
      };
      await FirebaseFirestore.instance.collection("goals").add(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          // TODO: Maybe it is better to use behavior: SnackBarBehavior.floating (after having fixed double scaffold problem),
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
