import 'package:flutter/material.dart';

import '../components/forms/proposal_form.dart';

class ProposalPage extends StatelessWidget {
  const ProposalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Proposal"),
      ),
      body: LayoutBuilder(
        builder: (context, constraint) => Container(
          height: constraint.maxHeight,
          padding: EdgeInsets.all(MediaQuery.of(context).size.width / 20),
          child: const ProposalForm(),
        ),
      ),
    );
  }
}
