import 'package:flutter/material.dart';
import 'package:progetto/pages/account_page.dart';

import '../model/place.dart';
import '../model/proposal.dart';
import '../model/user.dart';
import '../pages/place_page.dart';
import '../app_logic/storage.dart';

class Tile extends StatelessWidget {
  final Widget icon;
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
        subtitle != null ?
        ListTile(
            //TODO: make size dependent from screen width
            leading: icon,
            title: Text(title),
            subtitle: subtitle != null ? Text(subtitle!) : const Text(""),
            onTap: () {
              callback!();
            }) : ListTile(
          //TODO: make size dependent from screen width
            leading: icon,
            title: Text(title),
            onTap: () {
              callback!();
            }),
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
      icon: FutureBuilder(
          future: Storage.downloadURL(user.uid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return LayoutBuilder(builder: (context, constraint) {
                return CircleAvatar(
                  radius: constraint.maxHeight * 0.45,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: CircleAvatar(
                    radius: constraint.maxHeight * 0.42,
                    backgroundColor: Colors.white,
                    foregroundImage: NetworkImage(snapshot.data!),
                  ),
                );
              });
            } else {
              return LayoutBuilder(builder: (context, constraint) {
                return Icon(
                  size: constraint.maxHeight,
                  Icons.account_circle,
                  color: Colors.grey.shade500,
                );
              });
            }
          }),
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
  const PlaceTile(
      {super.key,
      required super.icon,
      required super.title,
      required super.subtitle,
      required super.callback});

  static Tile fromPlace(Place place, BuildContext context){
    return Tile(
      icon: LayoutBuilder(
        builder: (context, constraint) {
          return Icon(Icons.place, size: constraint.maxHeight);
        },
      ),
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

class ProposalTile extends Tile {
  const ProposalTile(
      {super.key,
      required super.icon,
      required super.title,
      required super.subtitle,
      required super.callback});

  static Tile fromProposal(Proposal proposal, BuildContext context){
    return Tile(
      icon: LayoutBuilder(
        // TODO: Replace the place icon with calendar with the proposed date
        builder: (context, constraint) {
          return Icon(Icons.place, size: constraint.maxHeight);
        },
      ),
      title: proposal.place.name,
      subtitle: "Organizer: ${proposal.owner.name} ${proposal.owner.surname}",
      callback: null
    );
  }
}
