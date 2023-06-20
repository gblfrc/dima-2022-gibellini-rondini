import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:progetto/app_logic/database.dart';
import 'package:progetto/app_logic/search_engine.dart';
import 'package:progetto/components/custom_small_map.dart';

import '../app_logic/auth.dart';
import '../components/forms/create_proposal_form.dart';
import '../model/place.dart';

class CreateProposalPage extends StatefulWidget {
  const CreateProposalPage({super.key});

  @override
  State<CreateProposalPage> createState() => _CreateProposalPageState();
}

class _CreateProposalPageState extends State<CreateProposalPage> {
  Place? location;
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Proposal"),
      ),
      body: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width / 20),
        child: ListView(
          children: [
            CreateProposalForm(
              propagateLocation: (Place? place) {
                setState(() {
                  location = place;
                  if (location != null) _mapController.move(location!.coords, 15);
                });
              },
              database: Database(),
              auth: Auth(),
              searchEngine: SearchEngine(),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.shortestSide,
              child: location != null
                  ? CustomSmallMap(
                      mapController: _mapController,
                      options: MapOptions(
                        zoom: 15,
                        maxZoom: 18.4,
                        center: location!.coords,
                      ),
                      children: [
                        MarkerLayer(
                          markers: [
                            Marker(
                                point: location!.coords,
                                builder: (context) {
                                  return Icon(
                                    Icons.place,
                                    size: MediaQuery.of(context)
                                            .size
                                            .shortestSide /
                                        12,
                                    color: Theme.of(context).primaryColor,
                                  );
                                })
                          ],
                        )
                      ],
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
