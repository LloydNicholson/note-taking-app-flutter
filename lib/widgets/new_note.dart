import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../providers/notes.dart';

enum Urgency { Relaxed, GetDone, Urgent, TopPriority }

class NewNote extends StatefulWidget {
  final DocumentSnapshot currentNote;
  final int currentIndex;
  final GlobalKey<AnimatedListState> listKey;

  NewNote({
    this.currentNote,
    this.currentIndex,
    this.listKey,
  });

  @override
  _NewNoteState createState() => _NewNoteState();
}

class _NewNoteState extends State<NewNote> {
  String receivedId;
  String newTitle;
  String newDescription;
  DateTime newDueDate;
  DateTime newReminderDate;
  TextEditingController startTitle;
  TextEditingController startDescription;
  AnimationController controller;
  String urgency;

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
    } else {
      receivedId = UniqueKey().toString();
      startTitle = TextEditingController(text: '');
      newTitle = startTitle.text;
      startDescription = TextEditingController(text: '');
      newDescription = startDescription.text;
      urgency = null;
    }
  }

  void _navigateAndSendDataOnPop() {
    if (newTitle.isEmpty || newDescription.isEmpty) {
      return;
    }

    if (widget.currentNote != null) {
      // edit the live data from server
      Provider.of<Notes>(context).updateNote(
        widget.currentNote,
        receivedId,
        newTitle,
        newDescription,
        urgency,
      );
    } else {
      // Add to the current collection
      if (widget.currentIndex >= 0) {
        Provider.of<Notes>(context).addNote(
          receivedId,
          newTitle,
          newDescription,
          urgency,
        );
      }
    }

    // Vibrate on tap
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  Widget _buildDoneButton(String buttonText) {
    return RaisedButton(
      color: Theme.of(context).primaryColor,
      elevation: 5,
      onPressed: _navigateAndSendDataOnPop,
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
        Navigator.of(context).pop();
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
        print(widget.currentIndex);
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
  }) {
    return TextField(
      autocorrect: true,
      decoration: InputDecoration(labelText: inputName),
      controller: originalText,
      onChanged: setNewValue,
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
        ),
      ],
    );
  }

  Widget _buildAndroidBottomSheet() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 10),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildDynamicTextField(
              inputName: 'Title',
              originalText: startTitle,
              maxLines: 1,
              setNewValue: (newValue) {
                setState(() {
                  newTitle = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            _buildDynamicTextField(
              inputName: 'Description',
              originalText: startDescription,
              maxLines: 1,
              setNewValue: (newValue) {
                setState(() {
                  newDescription = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'Priority',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(
                mainAxisAlignment: widget.currentNote != null
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.end,
                children: <Widget>[
                  if (widget.currentNote != null) _buildDeleteButton('Delete'),
                  ButtonBar(
                    children: <Widget>[
                      _buildCancelButton('Cancel'),
                      _buildDoneButton('Done'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildAndroidBottomSheet();
  }
}
