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
  final Auth auth;
  final Database database;
  final Storage storage;

  const ProposalPage({
    super.key,
    required this.proposal,
    required this.auth,
    required this.database,
    required this.storage,
  });

  @override
  State<ProposalPage> createState() => _ProposalPageState();
}

class _ProposalPageState extends State<ProposalPage> {
  @override
  Widget build(BuildContext context) {
    // convenience variables
    bool isVertical = (MediaQuery.of(context).orientation == Orientation.portrait);
    bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    double padding = MediaQuery.of(context).size.shortestSide / 30;

    return Scaffold(
      appBar: AppBar(
        key: const Key('ProposalPageAppBar'),
        title: const Text(
          'Training',
        ),
        actions: widget.proposal.owner.uid == widget.auth.currentUser!.uid
            ? [
                IconButton(
                  key: const Key('ProposalPageDeleteIcon'),
                  onPressed: () async {
                    String? action = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            key: const Key('ProposalPageRemovalDialog'),
                            title: const Text('Proposal deletion'),
                            content: const Text('The selected proposal will be deleted. Continue?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, 'No'), child: const Text('No')),
                              TextButton(onPressed: () => Navigator.pop(context, 'Yes'), child: const Text('Yes')),
                            ],
                          );
                        });
                    if (action != null && action == 'Yes') {
                      try {
                        widget.database.deleteProposal(widget.proposal);
                        if (mounted) {
                          Navigator.pop(context);
                        }
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
                    }
                  },
                  icon: const Icon(MdiIcons.trashCanOutline),
                )
              ]
            : [],
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: isVertical
            ? ListView(
                key: const Key('ProposalPageVerticalBody'),
                shrinkWrap: true,
                children: [
                  SizedBox(
                    key: const Key('ProposalPageVerticalMapSection'),
                    height: isTablet
                        ? MediaQuery.of(context).size.longestSide / 2.85
                        : MediaQuery.of(context).size.longestSide / 3.5,
                    child: _Map(widget.proposal),
                  ),
                  Padding(
                    key: const Key('ProposalPageVerticalInfoSection'),
                    padding: EdgeInsets.symmetric(vertical: padding),
                    child: _Info(
                      proposal: widget.proposal,
                      auth: widget.auth,
                      database: widget.database,
                      storage: widget.storage,
                      columns: isTablet ? 2 : 1,
                    ),
                  ),
                ],
              )
            : Flex(
                key: const Key('ProposalPageHorizontalBody'),
                direction: Axis.horizontal,
                children: [
                  Expanded(
                    key: const Key('ProposalPageHorizontalMapSection'),
                    flex: 5,
                    child: _Map(widget.proposal),
                  ),
                  Expanded(
                    key: const Key('ProposalPageHorizontalInfoSection'),
                    flex: isTablet ? 5 : 6,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding * 1.5),
                      child: ListView(
                        key: const Key('ProposalPageHorizontalInfoScrollable'),
                        children: [
                          _Info(
                            proposal: widget.proposal,
                            auth: widget.auth,
                            database: widget.database,
                            storage: widget.storage,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Map extends StatelessWidget {
  final Proposal proposal;

  const _Map(this.proposal);

  @override
  Widget build(BuildContext context) {
    return CustomSmallMap(
      mapController: MapController(),
      options: MapOptions(center: proposal.place.coords, zoom: 16, maxZoom: 18.4),
      proposalsForMarkers: [proposal],
    );
  }
}

class _Info extends StatefulWidget {
  final Proposal proposal;
  final Auth auth;
  final Database database;
  final Storage storage;
  final int columns;

  const _Info(
      {required this.proposal, required this.auth, required this.database, required this.storage, this.columns = 1});

  @override
  State<_Info> createState() => _InfoState();
}

class _InfoState extends State<_Info> {
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
    if (!widget.proposal.participants.contains(widget.auth.currentUser!.uid)) {
      joinable = true;
    } else {
      joinable = false;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: padding / 4),
          child: Wrap(
            direction: Axis.horizontal,
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
          child: Wrap(
            direction: Axis.horizontal,
            children: [
              Text(
                'Open to ',
                style: titleStyle,
              ),
              Text(
                widget.proposal.type == 'Public'
                    ? 'Everybody'
                    : "${widget.proposal.owner.name} ${widget.proposal.owner.surname}'s friends",
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
        PlaceTile.fromPlace(
          key: const Key('ProposalPageLocationTile'),
          place: widget.proposal.place,
          context: context,
          auth: widget.auth,
          database: widget.database,
          storage: widget.storage,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: padding / 4),
          child: Text(
            'Organizer',
            style: titleStyle,
          ),
        ),
        UserTile.fromUser(
          widget.proposal.owner,
          context,
          widget.storage,
          widget.database,
          widget.auth,
          key: const Key('ProposalPageOwnerTile'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: padding / 4),
          child: Text(
            'Participants',
            style: titleStyle,
          ),
        ),
        widget.proposal.participants.isNotEmpty
            // ? Column(
            ? GridView.count(
                key: const Key('ProposalPageParticipantGrid'),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: widget.columns,
                childAspectRatio: 5.75,
                children: widget.proposal.participants.map((uid) {
                  return StreamBuilder(
                      stream: widget.database.getUser(uid!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return UserTile.fromUser(
                            snapshot.data!,
                            context,
                            widget.storage,
                            widget.database,
                            widget.auth,
                            key: Key('ProposalPageParticipantTile_${snapshot.data!.uid}'),
                          );
                        } else {
                          return Container();
                        }
                      });
                }).toList(),
              )
            : Text(
                'No user has already joined the training.',
                style: genericTextStyle,
              ),
        SizedBox(
          height: padding,
        ),
        if (widget.proposal.owner.uid != widget.auth.currentUser!.uid &&
            widget.proposal.dateTime.isAfter(DateTime.now()))
          Center(
            child: FilledButton(
              key: joinable ? const Key('ProposalPageJoinButton') : const Key('ProposalPageLeaveButton'),
              onPressed: () {
                if (joinable) {
                  try {
                    widget.database.addParticipantToProposal(widget.proposal, widget.auth.currentUser!.uid);
                    widget.proposal.participants.add(widget.auth.currentUser!.uid);
                  } on Exception {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("An error occurred. Couldn't join session"),
                      ),
                    );
                  }
                } else {
                  try {
                    widget.database.removeParticipantFromProposal(widget.proposal, widget.auth.currentUser!.uid);
                    widget.proposal.participants.remove(widget.auth.currentUser!.uid);
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
    );
  }
}
