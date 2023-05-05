import 'package:flutter/material.dart';
import 'package:progetto/pages/account_page.dart';

import '../model/place.dart';
import '../model/user.dart';
import '../pages/place_page.dart';

class Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Function? callback;

  const Tile(
      {super.key,
      required this.icon,
      required this.title,
      this.subtitle,
      required this.callback});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ListTile(
          //TODO: make size dependent from screen width
          leading: Icon(icon, size: 60),
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle!) : const Text(""),
          onTap: () {
            callback!();
          }
        ),
        const Divider(),
      ],
    );
  }
}

class UserTile extends Tile {
  UserTile(
      {super.key,
      required super.icon,
      required super.title,
      super.subtitle,
      required super.callback});

  static Tile fromUser(User user, BuildContext context) {
    return Tile(
      icon: Icons.account_circle,
      title: "${user.name} ${user.surname}",
      callback: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AccountPage(uid: user.uid),
        ),
      ),
    );
  }
}

class PlaceTile extends Tile {
  PlaceTile(
      {super.key,
      required super.icon,
      required super.title,
      required super.subtitle,
      required super.callback});

  static Tile fromPlace(Place place, BuildContext context) {
    return Tile(
      icon: Icons.place,
      title: place.name,
      subtitle: "${place.city != null ? "${place.city}, " : ""}"
          "${place.state != null ? "${place.state}, " : ""}"
          "${place.country != null ? "${place.country}" : ""}",
      callback: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PlacePage(place: place),
        ),
      ),
    );
  }
}
