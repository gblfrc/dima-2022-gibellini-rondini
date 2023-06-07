import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:progetto/components/profile_picture.dart';
import 'package:progetto/constants.dart';
import 'package:progetto/pages/account_page.dart';
import 'package:progetto/pages/proposal_page.dart';

import '../model/place.dart';
import '../model/proposal.dart';
import '../model/user.dart';
import '../pages/place_page.dart';
import '../pages/session_page.dart';

class Tile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Function? onTap;
  final Widget? trailing;

  const Tile(
      {super.key,
      required this.leading,
      required this.title,
      this.subtitle,
      required this.onTap,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return ListTile(
        contentPadding: EdgeInsets.all(MediaQuery.of(context).size.shortestSide / 50),
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
          style: const TextStyle(color: Colors.grey),
        )
            : null,
        onTap: () {
          if (onTap != null) onTap!();
        },
        trailing: SizedBox(
          width: constraint.maxWidth / 5,
          height: constraint.maxHeight / 14,
          child: Center(
            child: trailing,
          ),
        ),
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
      required super.onTap,
      super.trailing});

  static UserTile fromUser(User user, BuildContext context) {
    return UserTile(
      leading: ProfilePicture(uid: user.uid),
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
      required super.onTap,
      super.trailing});

  static PlaceTile fromPlace(Place place, BuildContext context) {
    return PlaceTile(
      leading: LayoutBuilder(
        builder: (context, constraint) {
          return Icon(_getIconByPlace(place), size: constraint.maxHeight);
        },
      ),
      title: place.name,
      subtitle:
          place.city != null || place.state != null || place.country != null
              ? "${place.city != null ? "${place.city}, " : ""}"
                  "${place.state != null ? "${place.state}, " : ""}"
                  "${place.country != null ? "${place.country}" : ""}"
              : null,
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
      super.subtitle,
      required super.onTap,
      super.trailing});

  static ProposalTile fromProposal(Proposal proposal, BuildContext context, {startable = false}) {
    return ProposalTile(
      leading: FutureBuilder(
        future: rootBundle.loadString(calendarSvgPath),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            String svg = snapshot.data!;
            svg = svg.replaceAll("MONTH",
                DateFormat("MMM").format(proposal.dateTime).toUpperCase());
            svg = svg.replaceAll(
                "DAY", DateFormat("d").format(proposal.dateTime));
            return SvgPicture.string(svg);
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
      title: proposal.place.name,
      subtitle: "Organizer: ${proposal.owner.name} ${proposal.owner.surname}",
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProposalPage(proposal: proposal)));
      },
      trailing: LayoutBuilder(
        builder: (context, constraint) {
          if (!startable){
            if (proposal.type == 'Public') {
              return Icon(
                MdiIcons.lockOpen,
                size: constraint.maxHeight,
                color: Colors.green,
              );
            } else {
              return Icon(
                Icons.lock,
                size: constraint.maxHeight,
                color: Colors.yellow.shade600,
              );
            }
          } else {
            return FilledButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) =>
                          SessionPage(proposal: proposal))),
              child: const Text("Start"),
            );
          }
        },
      ),
    );
  }
}
