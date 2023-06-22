import 'dart:math';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:progetto/app_logic/search_engine.dart';

import '../../app_logic/auth.dart';
import '../../app_logic/database.dart';
import '../../model/place.dart';

class CreateProposalForm extends StatefulWidget {
  final Database database;
  final Auth auth;
  final SearchEngine searchEngine;
  final Function(Place?)? propagateLocation;

  const CreateProposalForm({
    super.key,
    this.propagateLocation,
    required this.auth,
    required this.database,
    required this.searchEngine,
  });

  @override
  State<CreateProposalForm> createState() => CreateProposalFormState();
}

class CreateProposalFormState extends State<CreateProposalForm> {
  Place? location;
  late DateTime dateTime = DateTime.now();
  String type = 'Public';
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final typeItems = ['Public', 'Friends'];
  final _formKey = GlobalKey<FormState>();

  CreateProposalFormState();

  @override
  Widget build(BuildContext context) {
    // define text style for future re-usage
    TextStyle textStyle = TextStyle(
      fontSize: MediaQuery.of(context).textScaleFactor * 17,
    );
    // define enabled border for reusage
    UnderlineInputBorder uib = UnderlineInputBorder(
      borderSide: BorderSide(
        width: 2,
        color: Colors.grey.shade500,
      ),
    );

    // main return statement
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(key: const Key('CreateProposalFormSetLocationText'), 'Set your proposal location:', style: textStyle),
          LayoutBuilder(builder: (context, constraint) {
            return TypeAheadFormField<Place>(
              key: const Key('CreateProposalFormLocationField'),
              textFieldConfiguration: TextFieldConfiguration(
                controller: _placeController,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      _placeController.text = "";
                      location = null;
                      if (widget.propagateLocation != null) {
                        widget.propagateLocation!(null);
                      }
                    },
                    icon: const Icon(Icons.close),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  hintText: 'Location',
                ),
              ),
              onSuggestionSelected: (place) {
                _placeController.text = place.name;
                location = place;
                if (widget.propagateLocation != null) {
                  widget.propagateLocation!(place);
                }
              },
              itemBuilder: (context, place) {
                return ListTile(
                  key: Key('LocationListTile_${place.name}'),
                  title: Text(
                    place.name,
                  ),
                );
              },
              suggestionsCallback: (value) {
                if (value == '') {
                  return const Iterable<Place>.empty();
                } else {
                  return widget.searchEngine.getPlacesByName(value).then((list) {
                    return list.sublist(0, min(list.length, 5));
                  });
                }
              },
              validator: (value) {
                return (value == null || value.isEmpty) ? 'Please, propose a location' : null;
              },
              suggestionsBoxDecoration: const SuggestionsBoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
            );
          }),
          const SizedBox(
            height: 20,
          ),
          Text(key: const Key('CreateProposalFormSetDateTimeText'), 'Select date and time:', style: textStyle),
          Flex(
            direction: Axis.horizontal,
            children: [
              Flexible(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, MediaQuery.of(context).size.width / 80, 0),
                  child: DateTimeField(
                    key: const Key('CreateProposalFormDateField'),
                    controller: _dateController,
                    format: DateFormat.yMd(),
                    onShowPicker: (context, currentValue) async {
                      // save now dateTime for convenience
                      final now = DateTime.now();
                      // show date picker, available dates: up to a year from now
                      final date = await showDatePicker(
                          context: context,
                          initialDate: currentValue ?? now,
                          firstDate: now,
                          lastDate: DateTime(now.year + 1, now.month, now.day));
                      // save chosen date in dateController
                      if (date != null) {
                        dateTime = DateTime(date.year, date.month, date.day, dateTime.hour, dateTime.minute);
                        _dateController.text = DateFormat.yMd().format(dateTime).toString();
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      enabledBorder: uib,
                      hintText: 'Date',
                      suffixIcon: IconButton(
                        onPressed: () {
                          _dateController.text = "";
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ),
                    validator: (value) {
                      return (_dateController.text.isEmpty) ? 'Please, enter a date' : null;
                    },
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 80, 0, 0, 0),
                  child: DateTimeField(
                    key: const Key('CreateProposalFormTimeField'),
                    controller: _timeController,
                    format: DateFormat.Hm(),
                    onShowPicker: (context, currentValue) async {
                      // show time picker
                      TimeOfDay? currentTimeValue = currentValue != null ? TimeOfDay.fromDateTime(currentValue) : null;
                      final time = await showTimePicker(
                        context: context,
                        initialTime: currentTimeValue ?? TimeOfDay.fromDateTime(DateTime.now()),
                      );
                      // save chosen date in dateController
                      if (time != null) {
                        dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day, time.hour, time.minute);
                        _timeController.text = DateFormat.Hm().format(dateTime);
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      enabledBorder: uib,
                      hintText: 'Time',
                      suffixIcon: IconButton(
                        onPressed: () {
                          _timeController.text = "";
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ),
                    validator: (value) {
                      return (_timeController.text.isEmpty) ? 'Please, enter a time' : null;
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Wrap(
            direction: Axis.horizontal,
            children: [
              Text(
                key: const Key('CreateProposalFormOpenToText'),
                'Open to:   ',
                style: textStyle,
              ),
              DropdownButton(
                key: const Key('CreateProposalFormPrivacyField'),
                value: type,
                items: typeItems.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    key: Key('DropdownItem$value'),
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
          Align(
            alignment: Alignment.center,
            child: FilledButton(
              key: const Key('CreateProposalFormCreationButton'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    widget.database.createProposal(
                        dateTime: dateTime,
                        ownerId: widget.auth.currentUser!.uid,
                        placeLatitude: location!.coords.latitude,
                        placeLongitude: location!.coords.longitude,
                        placeId: location!.id,
                        placeName: location!.name,
                        placeCity: location!.city,
                        placeState: location!.state,
                        placeCountry: location!.country,
                        placeType: location!.type,
                        type: type);
                    if (mounted) {
                      Navigator.pop(context);
                    }
                    if (mounted) {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          key: Key('SuccessfulProposalCreationSnackBar'),
                          content: Text('Proposal created successfully'),
                        ),
                      );
                    }
                  } on Exception {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        key: Key('ErrorInProposalCreationSnackBar'),
                        content: Text('An error occurred while saving your proposal.'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
