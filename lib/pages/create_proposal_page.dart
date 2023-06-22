import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/search_engine.dart';
import 'package:progetto/components/custom_small_map.dart';

import '../app_logic/auth.dart';
import '../components/forms/create_proposal_form.dart';
import '../model/place.dart';

class CreateProposalPage extends StatefulWidget {
  final Auth auth;
  final Database database;
  final SearchEngine searchEngine;

  const CreateProposalPage({super.key, required this.auth, required this.database, required this.searchEngine});

  @override
  State<CreateProposalPage> createState() => _CreateProposalPageState();
}

class _CreateProposalPageState extends State<CreateProposalPage> {
  Place? location;
  MapController _mapController = MapController();
  bool _isMapControllerInitialized = false;

  void propagateLocation(Place? place) {
    setState(() {
      location = place;
      if (location != null && _isMapControllerInitialized) {
        _mapController.move(location!.coords, 15);
      } else if (location == null) {
        _mapController = MapController();
        location = null;
        _isMapControllerInitialized = false;
      } else {
        _isMapControllerInitialized = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isVertical = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        key: const Key('CreateProposalPageAppBar'),
        title: const Text("Proposal"),
      ),
      body: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width / 20),
        child: isVertical
            ? ListView(
                key: const Key('CreateProposalPageVerticalBody'),
                children: [
                  CreateProposalForm(
                    key: const Key('CreateProposalPageVerticalForm'),
                    propagateLocation: propagateLocation,
                    database: widget.database,
                    auth: widget.auth,
                    searchEngine: widget.searchEngine,
                  ),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 1,
                    childAspectRatio: 1,
                    children: [
                      location != null
                          ? _Map(
                              key: const Key('CreateProposalPageVerticalMap'),
                              location!,
                              _mapController,
                            )
                          : Container()
                    ],
                  ),
                ],
              )
            : Flex(
                key: const Key('CreateProposalPageHorizontalBody'),
                direction: Axis.horizontal,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        CreateProposalForm(
                          key: const Key('CreateProposalPageHorizontalForm'),
                          propagateLocation: propagateLocation,
                          database: widget.database,
                          auth: widget.auth,
                          searchEngine: widget.searchEngine,
                        ),
                      ],
                    ),
                  ),
                  if (location != null)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 40, 0, 0, 0),
                        child: _Map(
                          key: const Key('CreateProposalPageHorizontalMap'),
                          location!,
                          _mapController,
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
  final Place location;
  final MapController mapController;

  const _Map(this.location, this.mapController, {super.key});

  @override
  Widget build(BuildContext context) {
    return CustomSmallMap(
      mapController: mapController,
      options: MapOptions(
        zoom: 15,
        maxZoom: 18.4,
        center: location.coords,
      ),
      children: [
        MarkerLayer(
          markers: [
            Marker(
                point: location.coords,
                builder: (context) {
                  return Icon(
                    Icons.place,
                    size: MediaQuery.of(context).size.shortestSide / 12,
                    color: Theme.of(context).primaryColor,
                  );
                })
          ],
        )
      ],
    );
  }
}
