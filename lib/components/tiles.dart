import 'package:flutter/material.dart';

class Tile extends StatelessWidget {
  IconData icon = Icons.account_circle;
  String title = "";
  String subtitle = "";
  void callback;

  Tile(this.icon, this.title, this.subtitle, this.callback, {super.key});

  @override
  Widget build(BuildContext context) {
    Text? subtitleComponent;
    if (subtitle != "") {
      subtitleComponent = Text(subtitle);
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(icon, size: 60),
          title: Text(title),
          subtitle: subtitleComponent,
          onTap: () => callback,
        ),
        const Divider(),
      ],
    );
  }
}
