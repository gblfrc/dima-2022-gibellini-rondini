import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/components/custom_small_map.dart';
import 'package:progetto/components/tiles.dart';

import '../app_logic/auth.dart';
import '../app_logic/storage.dart';
import '../model/proposal.dart';

class ProposalPage extends StatefulWidget {
  final Proposal proposal;

  const ProposalPage({super.key, required this.proposal});

  @override
  State<ProposalPage> createState() => _ProposalPageState();
}

class _ProposalPageState extends State<ProposalPage> {
  @override
  Widget build(BuildContext context) {
    // convenience variables
    double padding = MediaQuery.of(context).size.shortestSide / 30;
    TextStyle titleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: MediaQuery.of(context).textScaleFactor * 19,
    );
    TextStyle genericTextStyle = TextStyle(
      fontSize: MediaQuery.of(context).textScaleFactor * 19,
    );
    // variable to determine if current user can join the training
    bool joinable;
    if (!widget.proposal.participants.contains(Auth().currentUser!.uid)) {
      joinable = true;
    } else {
      joinable = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Training',
        ),
        actions: widget.proposal.owner.uid == Auth().currentUser!.uid
            ? [
                IconButton(
                  onPressed: () {
                    try {
                      Database().deleteProposal(widget.proposal);
                      Navigator.pop(context);
                      if (mounted) {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Proposal deleted successfully.'),
                          ),
                        );
                      }
                    } on Exception {
                      if (mounted) {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('An error occurred when deleting the proposal.'),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(MdiIcons.trashCanOutline),
                )
              ]
            : [],
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.longestSide / 3.5,
              child: CustomSmallMap(
                options: MapOptions(center: widget.proposal.place.coords, zoom: 16, maxZoom: 18.4),
                proposalsForMarkers: [widget.proposal],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: padding / 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Scheduled for ',
                        style: titleStyle,
                      ),
                      Text(
                        widget.proposal.dateTime.year == DateTime.now().year
                            ? DateFormat('MMM d, HH:mm').format(widget.proposal.dateTime)
                            : DateFormat('MMM d y, HH:mm').format(widget.proposal.dateTime),
                        style: genericTextStyle,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: padding / 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Open to ',
                        style: titleStyle,
                      ),
                      Text(
                        widget.proposal.type == 'Public'
                            ? 'Everybody'
                            : "${widget.proposal.owner.name} ${widget.proposal.owner.surname}' friends",
                        style: genericTextStyle,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: padding / 4),
                  child: Text(
                    'Location',
                    style: titleStyle,
                  ),
                ),
                PlaceTile.fromPlace(widget.proposal.place, context),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: padding / 4),
                  child: Text(
                    'Organizer',
                    style: titleStyle,
                  ),
                ),
                UserTile.fromUser(widget.proposal.owner, context, Storage()),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: padding / 4),
                  child: Text(
                    'Participants',
                    style: titleStyle,
                  ),
                ),
                widget.proposal.participants.isNotEmpty
                    ? Column(
                        children: widget.proposal.participants.map((uid) {
                          return StreamBuilder(
                              stream: Database().getUser(uid!),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return UserTile.fromUser(snapshot.data!, context, Storage());
                                } else {
                                  return Container();
                                }
                              });
                        }).toList(),
                      )
                    : Text(
                        'No user has already joined the organizer.',
                        style: genericTextStyle,
                      ),
                SizedBox(
                  height: padding,
                ),
                Center(
                  child: FilledButton(
                    onPressed: () {
                      if (joinable) {
                        try {
                          Database().addParticipantToProposal(widget.proposal, Auth().currentUser!.uid);
                          widget.proposal.participants.add(Auth().currentUser!.uid);
                        } on Exception {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("An error occurred. Couldn't join session"),
                            ),
                          );
                        }
                      } else {
                        try {
                          Database().removeParticipantFromProposal(widget.proposal, Auth().currentUser!.uid);
                          widget.proposal.participants.remove(Auth().currentUser!.uid);
                        } on Exception {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("An error occurred. Couldn't leave session"),
                            ),
                          );
                        }
                      }
                      setState(() {});
                    },
                    child: joinable ? const Text("Join") : const Text('Leave'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
