import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:progetto/constants.dart';
import 'package:progetto/pages/account_page.dart';

import '../model/place.dart';
import '../model/proposal.dart';
import '../model/user.dart';
import '../pages/place_page.dart';
import '../app_logic/storage.dart';

class Tile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Function? onTap;

  const Tile(
      {super.key,
      required this.leading,
      required this.title,
      this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return ListTile(
        leading: SizedBox(
          width: constraint.maxWidth / 6,
          height: constraint.maxHeight / 14,
          child: Center(
            child: leading,
          ),
        ),
        title: Text(title),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(color: Colors.grey),
              )
            : null,
        onTap: () {
          if (onTap != null) onTap!();
        },
      );
    });
  }
}

class UserTile extends Tile {
  UserTile(
      {super.key,
      required super.leading,
      required super.title,
      super.subtitle,
      required super.onTap});

  static Tile fromUser(User user, BuildContext context) {
    return Tile(
      leading: FutureBuilder(
          future: Storage.downloadURL(user.uid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return LayoutBuilder(builder: (context, constraint) {
                return CircleAvatar(
                  radius: constraint.maxHeight * 0.48,
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
      onTap: () => Navigator.of(context).push(
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
      required super.leading,
      required super.title,
      required super.subtitle,
      required super.onTap});

  static Tile fromPlace(Place place, BuildContext context) {
    return Tile(
      leading: LayoutBuilder(
        builder: (context, constraint) {
          return Icon(_getIconByPlace(place), size: constraint.maxHeight);
        },
      ),
      title: place.name,
      subtitle: "${place.city != null ? "${place.city}, " : ""}"
          "${place.state != null ? "${place.state}, " : ""}"
          "${place.country != null ? "${place.country}" : ""}",
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PlacePage(place: place),
        ),
      ),
    );
  }

  static IconData _getIconByPlace(Place place) {
    switch (place.type) {
      case 'park':
        return Icons.park;
      case 'nature_reserve':
        return MdiIcons.forest;
      case 'playground':
        return MdiIcons.seesaw;
      case 'village':
        return MdiIcons.homeGroup;
      case 'town':
        return MdiIcons.homeGroup;
      case 'residential':
        return MdiIcons.homeGroup;
      case 'city':
        return Icons.location_city;
      case 'college':
        return Icons.school;
      case 'university':
        return Icons.school;
      case 'school':
        return Icons.school;
      case 'stadium':
        return Icons.stadium;
      case 'pitch':
        return MdiIcons.soccerField;
      case 'sports_centre':
        return Icons.sports;
      case 'hospital':
        return MdiIcons.hospitalBuilding;
      case 'cemetery':
        return MdiIcons.graveStone;
      case 'church':
        return Icons.church;
      case 'place_of_worship':
        return Icons.church;
      case 'airport':
        return MdiIcons.airport;
      case 'aerodrome':
        return MdiIcons.airport;
      case 'bus_stop':
        return MdiIcons.busStop;
      case 'country':
        return MdiIcons.flagVariant;
      case 'attraction':
        return MdiIcons.map;
    }
    return Icons.place;
  }
}

class ProposalTile extends Tile {
  const ProposalTile(
      {super.key,
      required super.leading,
      required super.title,
      required super.subtitle,
      required super.onTap});

  static Tile fromProposal(Proposal proposal, BuildContext context) {
    return Tile(
        leading: FutureBuilder(
          future: rootBundle.loadString(calendarSvgPath),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              String svg = snapshot.data!;
              svg = svg.replaceAll("MONTH", DateFormat("MMM").format(proposal.dateTime).toUpperCase());
              svg = svg.replaceAll("DAY", DateFormat("d").format(proposal.dateTime));
              return SvgPicture.string(svg);
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
        title: proposal.place.name,
        subtitle: "Organizer: ${proposal.owner.name} ${proposal.owner.surname}",
        onTap: null);
  }

}
