import 'dart:async';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:progetto/app_logic/search_engine.dart';

import '../../app_logic/auth.dart';
import '../../app_logic/database.dart';
import '../../model/place.dart';
import '../../model/proposal.dart';
import '../../model/user.dart';

class ProposalForm extends StatefulWidget {
  const ProposalForm({super.key});

  @override
  State<ProposalForm> createState() => ProposalFormState();
}

class ProposalFormState extends State<ProposalForm> {
  StreamController<Place> locationStreamController = StreamController<Place>();
  Place? location;
  DateTime? dateTime;
  String type = 'Public';
  final MapController _mapController = MapController();
  final TextEditingController _dateTimeController = TextEditingController();
  final typeItems = ['Public', 'Friends'];

  ProposalFormState();

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      children: [
        Flexible(
          flex: 2,
          child: ListView(
            children: [
              const Text('Set your proposal location: '),
              Autocomplete<Place>(
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<Place>.empty();
                  } else {
                    return SearchEngine.getPlacesByName(textEditingValue.text);
                  }
                },
                displayStringForOption: (Place place) => place.name,
                onSelected: (Place place) {
                  setState(() {
                    location = place;
                    locationStreamController.add(place);
                    _mapController.move(location!.coords, 15);
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              LayoutBuilder(
                builder: (context, constraint) => DateTimeField(
                  format: DateFormat.yMd().add_Hm(),
                  onShowPicker: (context, currentValue) async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: currentValue ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (date != null && mounted) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                            currentValue ?? DateTime.now()),
                      );
                      dateTime = DateTimeField.combine(date, time);
                    } else {
                      dateTime = currentValue;
                    }
                    _dateTimeController.text =
                        DateFormat.yMd().add_Hm().format(dateTime!).toString();
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: EdgeInsets.all(constraint.maxWidth / 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    hintText: "Date and time",
                  ),
                  controller: _dateTimeController,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Text('Open to:     '),
                  DropdownButton(
                    value: type,
                    items:
                        typeItems.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        type = value ?? 'Public';
                      });
                    },
                  )
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  if (dateTime != null && location != null) {
                    Proposal? proposal;
                    try {
                      User? user =
                          await Database.getUser(Auth().currentUser!.uid).first;
                      proposal = Proposal(
                          dateTime: dateTime!,
                          owner: user!,
                          place: location!,
                          participants: [],
                          type: type);
                      Database.createProposal(proposal);
                      if (mounted) {
                        Navigator.pop(context);
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Proposal created successfully'),
                          ),
                        );
                      }
                    } on Exception {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'An error occurred while saving your proposal.'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
        ),
        Flexible(
          flex: 1,
          child: StreamBuilder(
            stream: locationStreamController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: location!.coords,
                    zoom: 15,
                    maxZoom: 18.4,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(markers: [
                      Marker(
                        point: location!.coords,
                        builder: (context) => Icon(
                          Icons.place,
                          color: Colors.red.shade400,
                          size: 35,
                        ),
                      ),
                    ])
                  ],
                );
              } else {
                return LayoutBuilder(
                  builder: (context, constraint) => Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1)),
                    child: const Center(
                      child: Text('Select a place to display it on a map.'),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );

    // place
    //date time --> date time picker
  }
}
