import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/notes.dart';

enum Urgency { Relaxed, GetDone, Urgent, TopPriority }

class NewNote extends StatefulWidget {
  final DocumentSnapshot currentNote;
  final int currentIndex;

  NewNote({
    this.currentNote,
    this.currentIndex,
  });

  @override
  _NewNoteState createState() => _NewNoteState();
}

class _NewNoteState extends State<NewNote> {
  final descriptionFocusNode = FocusNode();
  final titleFocusNode = FocusNode();
  String receivedId;
  String newTitle;
  String newDescription;
  TextEditingController startTitle;
  TextEditingController startDescription;
  AnimationController controller;
  String urgency;
  DateTime pickedDate;
  DateTime pickedTime;
//  DateTime newDueDate;
//  DateTime newReminderDate;

  @override
  void initState() {
    super.initState();
    if (widget.currentNote != null) {
      receivedId = widget.currentNote['id'];
      startTitle = TextEditingController(text: widget.currentNote['title']);
      newTitle = startTitle.text;
      startDescription =
          TextEditingController(text: widget.currentNote['description']);
      newDescription = startDescription.text;
      urgency = widget.currentNote['urgency'].toString();

      // set date and time from a string received from firebase
      pickedDate = DateTime.parse(widget.currentNote['date']);
      pickedTime = DateTime.parse(widget.currentNote['time']);
    } else {
      receivedId = UniqueKey().toString();
      startTitle = TextEditingController(text: '');
      newTitle = startTitle.text;
      startDescription = TextEditingController(text: '');
      newDescription = startDescription.text;
      urgency = null;
      pickedDate = null;
      pickedTime = null;
    }
  }

  @override
  void dispose() {
    titleFocusNode.dispose();
    descriptionFocusNode.dispose();
    super.dispose();
  }

  void _navigateAndSendDataOnPop() {
    if (newTitle.isEmpty ||
        newDescription.isEmpty ||
        pickedDate == null ||
        pickedTime == null) {
      return;
    }

    if (widget.currentNote != null) {
      // edit the live data from server
      Provider.of<Notes>(context).updateNote(
        ctx: context,
        currentNote: widget.currentNote,
        id: receivedId,
        title: newTitle,
        description: newDescription,
        urgency: urgency,
        date: pickedDate,
        time: pickedTime,
      );
    } else {
      // Add to the current collection
      Provider.of<Notes>(context).addNote(
        ctx: context,
        id: receivedId,
        title: newTitle,
        description: newDescription,
        urgency: urgency,
        date: pickedDate,
        time: pickedTime,
      );
    }

    // Vibrate on tap
    HapticFeedback.lightImpact();
    Navigator.pop(context);
  }

  Widget _buildDoneButton(String buttonText) {
    return RaisedButton(
      color: Theme.of(context).primaryColor,
      elevation: 5,
      onPressed: (newTitle.isEmpty ||
              newDescription.isEmpty ||
              pickedDate == null ||
              pickedTime == null)
          ? null
          : _navigateAndSendDataOnPop,
      child: Text(
        buttonText,
        style: Theme.of(context).textTheme.title,
      ),
    );
  }

  Widget _buildCancelButton(String buttonText) {
    return RaisedButton(
      color: Theme.of(context).primaryColor,
      onPressed: () {
        HapticFeedback.selectionClick();
        Navigator.pop(context);
      },
      child: Text(
        buttonText,
        style: Theme.of(context).textTheme.title,
      ),
    );
  }

  Widget _buildDeleteButton(String buttonText) {
    return RaisedButton(
      color: Theme.of(context).errorColor,
      onPressed: () {
        Provider.of<Notes>(context)
            .removeNote(context, widget.currentIndex, widget.currentNote);
        Navigator.pop(context);
      },
      child: Text(
        buttonText,
        style: Theme.of(context).textTheme.title,
      ),
    );
  }

  Widget _buildDynamicTextField({
    String inputName,
    TextEditingController originalText,
    int maxLines,
    Function setNewValue,
    FocusNode focusNode,
    TextInputAction textInputAction,
    Function onSubmit,
  }) {
    return TextField(
      autocorrect: true,
      textInputAction: textInputAction,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: inputName,
        hintText: 'Add a ${inputName.toLowerCase()}',
      ),
      controller: originalText,
      onChanged: setNewValue,
      onSubmitted: onSubmit,
    );
  }

  Column _buildRadioCard(
      String text, Urgency urgencyLevel, Function setUrgency) {
    return Column(
      children: <Widget>[
        Text(text),
        Radio(
          value: urgencyLevel.toString(),
          groupValue: urgency,
          onChanged: setUrgency,
          activeColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  Future<void> _chooseDate(BuildContext ctx) async {
    final date = await showDatePicker(
      context: ctx,
      firstDate: DateTime.now(),
      initialDate: pickedDate != null ? pickedDate : DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    // print(TimeOfDay.fromDateTime(DateTime.now()));
    final time = await showTimePicker(
      context: ctx,
      initialTime: TimeOfDay.fromDateTime(
        pickedTime != null ? pickedTime : DateTime.now(),
      ),
    );
    if (date == null || time == null) {
      return;
    }
    final formattedTime = DateTime(
      date.year,
      date.month,
      date.day,
    ).add(
      Duration(
        hours: time.hour,
        minutes: time.minute,
      ),
    );
    setState(() {
      pickedDate = date;
      pickedTime = formattedTime;
    });
    print(DateTime.parse(formattedTime.toIso8601String()));
    _navigateAndSendDataOnPop();
  }

  Widget _buildBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildDynamicTextField(
                inputName: 'Title',
                originalText: startTitle,
                textInputAction: TextInputAction.next,
                maxLines: 1,
                onSubmit: (val) {
                  FocusScope.of(context).requestFocus(descriptionFocusNode);
                },
                setNewValue: (newValue) => setState(() {
                  newTitle = newValue;
                }),
              ),
              SizedBox(height: 10),
              _buildDynamicTextField(
                inputName: 'Description',
                focusNode: descriptionFocusNode,
                originalText: startDescription,
                maxLines: 1,
                textInputAction: TextInputAction.done,
                setNewValue: (newValue) {
                  setState(() {
                    newDescription = newValue;
                  });
                },
              ),
              SizedBox(height: 15),
              Text(
                'Priority',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _buildRadioCard('Relaxed', Urgency.Relaxed, (val) {
                    setState(() {
                      urgency = val;
                    });
                  }),
                  _buildRadioCard('Get Done', Urgency.GetDone, (val) {
                    setState(() {
                      urgency = val;
                    });
                  }),
                  _buildRadioCard('Urgent', Urgency.Urgent, (val) {
                    setState(() {
                      urgency = val;
                    });
                  }),
                  _buildRadioCard('Top Priority', Urgency.TopPriority, (val) {
                    setState(() {
                      urgency = val;
                    });
                  }),
                ],
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                child: FlatButton.icon(
                  label: (pickedDate != null || pickedTime != null)
                      ? Column(
                          children: <Widget>[
                            Text('${DateFormat.yMMMd().format(pickedDate)}'),
                            Text(
                              '${TimeOfDay.fromDateTime(pickedTime).format(context)}',
                            ),
                          ],
                        )
                      : Text('Choose date and time'),
                  icon: Icon(Icons.date_range),
                  onPressed: () => _chooseDate(context),
                ),
              ),
              Row(
                mainAxisAlignment: widget.currentNote != null
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.end,
                children: <Widget>[
                  if (widget.currentNote != null) _buildDeleteButton('Delete'),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: widget.currentNote != null
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.center,
                      children: <Widget>[
                        _buildCancelButton('Cancel'),
                        SizedBox(
                          width: widget.currentNote != null ? 10 : 50,
                        ),
                        _buildDoneButton('Done'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildBottomSheet(),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
      ),
    );
  }
}
