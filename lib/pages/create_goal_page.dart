import 'package:flutter/material.dart';
import 'package:progetto/components/forms/create_goal_form.dart';

import '../app_logic/auth.dart';
import '../app_logic/database.dart';

class CreateGoalPage extends StatelessWidget {

  const CreateGoalPage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double padding = width / 20;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create goal'),
      ),
      body: ListView(
        children: [
          CreateGoalForm(width: width - 2 * padding, database: Database(), auth: Auth()),
        ],
      )
    );
  }
}