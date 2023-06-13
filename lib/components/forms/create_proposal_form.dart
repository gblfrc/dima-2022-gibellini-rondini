import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:progetto/app_logic/search_engine.dart';

import '../../app_logic/auth.dart';
import '../../app_logic/database.dart';
import '../../model/place.dart';
import '../../model/proposal.dart';
import '../../model/user.dart';

class CreateProposalForm extends StatefulWidget {
  final Function? propagateLocation;

  const CreateProposalForm({super.key, this.propagateLocation});


  @override
  State<CreateProposalForm> createState() => CreateProposalFormState();
}

class CreateProposalFormState extends State<CreateProposalForm> {
  Place? location;
  late DateTime dateTime;
  String type = 'Public';
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final typeItems = ['Public', 'Friends'];

  CreateProposalFormState();

  @override
  void initState() {
    dateTime = DateTime.now();
    _dateController.text = DateFormat.yMd().format(dateTime).toString();
    _timeController.text = DateFormat.Hm().format(dateTime).toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // define text style for future re-usage
    TextStyle textStyle = TextStyle(
      fontSize: MediaQuery.of(context).textScaleFactor * 17,
    );
    // define decoration of date and time fields
    InputDecoration inputDecoration = InputDecoration(
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          width: 2,
          color: Colors.grey.shade500,
        ),
      ),
    );

    // main return statement
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Set your proposal location:', style: textStyle),
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
            if (widget.propagateLocation != null) widget.propagateLocation!(place);
            location = place;
          },
        ),
        const SizedBox(
          height: 20,
        ),
        Text('Select date and time:', style: textStyle),
        Flex(
          direction: Axis.horizontal,
          children: [
            Flexible(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    0, 0, MediaQuery.of(context).size.width / 80, 0),
                child: DateTimeField(
                  controller: _dateController,
                  format: DateFormat.yMd(),
                  onShowPicker: (context, currentValue) async {
                    // save now dateTime for convenience
                    final now = DateTime.now();
                    // show date picker, available dates: up to a year from now
                    final date = await showDatePicker(
                        context: context,
                        initialDate: dateTime,
                        firstDate: now,
                        lastDate: DateTime(now.year + 1, now.month, now.day));
                    // save chosen date in dateController
                    if (date != null) {
                      dateTime = DateTime(date.year, date.month, date.day,
                          dateTime.hour, dateTime.minute);
                      _dateController.text =
                          DateFormat.yMd().format(dateTime).toString();
                    }
                    return null;
                  },
                  decoration: inputDecoration,
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    MediaQuery.of(context).size.width / 80, 0, 0, 0),
                child: DateTimeField(
                  controller: _timeController,
                  format: DateFormat.Hm(),
                  onShowPicker: (context, currentValue) async {
                    // show time picker
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                          hour: dateTime.hour, minute: dateTime.minute),
                    );
                    // save chosen date in dateController
                    if (time != null) {
                      dateTime = DateTime(dateTime.year, dateTime.month,
                          dateTime.day, time.hour, time.minute);
                      _timeController.text = DateFormat.Hm().format(dateTime);
                    }
                    return null;
                  },
                  decoration: inputDecoration,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            Text(
              'Open to:   ',
              style: textStyle,
            ),
            DropdownButton(
              value: type,
              items: typeItems.map<DropdownMenuItem<String>>((String value) {
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
        Align(
          alignment: Alignment.center,
          child: FilledButton(
            onPressed: () async {
              if (location != null) {
                Proposal? proposal;
                try {
                  User? user =
                      await Database().getUser(Auth().currentUser!.uid).first;
                  proposal = Proposal(
                      dateTime: dateTime,
                      owner: user!,
                      place: location!,
                      participants: [],
                      type: type);
                  Database().createProposal(proposal);
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
                      content:
                          Text('An error occurred while saving your proposal.'),
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
    );
  }
}
