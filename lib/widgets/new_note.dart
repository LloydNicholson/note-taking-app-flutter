import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Urgency { Relaxed, GetDone, Urgent, TopPriority }

class NewNote extends StatefulWidget {
  final DocumentSnapshot currentNote;

  NewNote({
    this.currentNote,
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

  @override
  Widget build(BuildContext context) {
    void _navigateAndSendDataOnPop() {
      if (newTitle.isEmpty || newDescription.isEmpty) {
        return;
      }

      if (widget.currentNote != null) {
        // edit the live data from server
        Firestore.instance.runTransaction((transaction) async {
          DocumentSnapshot freshSnap =
              await transaction.get(widget.currentNote.reference);
          await transaction.update(freshSnap.reference, {
            'id': receivedId,
            'title': newTitle,
            'description': newDescription,
            'urgency': urgency,
          });
        });
      } else {
        // Add to the current collection
        Firestore.instance.collection('currentNotes').add({
          'id': receivedId,
          'title': newTitle,
          'description': newDescription,
          'urgency': urgency,
        });
      }

      // Vibrate on tap
      HapticFeedback.lightImpact();
      Navigator.of(context).pop();
    }

    Widget _buildDoneButton(String buttonText) {
      return Platform.isIOS
          ? CupertinoButton(
              child: Text(buttonText),
              onPressed: _navigateAndSendDataOnPop,
            )
          : RaisedButton(
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
      return Platform.isIOS
          ? CupertinoButton(
              child: Text(buttonText),
              onPressed: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).pop();
              },
            )
          : RaisedButton(
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

    _buildDeleteButton(String buttonText) {
      return Platform.isIOS
          ? CupertinoButton(
              child: Text(buttonText),
              onPressed: () {
                HapticFeedback.selectionClick();
                widget.currentNote.reference.delete();
                Navigator.of(context).pop();
              },
            )
          : RaisedButton(
              color: Theme.of(context).errorColor,
              onPressed: () {
                HapticFeedback.selectionClick();
                widget.currentNote.reference.delete();
                Navigator.of(context).pop();
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
      return Platform.isIOS
          ? CupertinoTextField(
              autocorrect: true,
              placeholder: inputName,
              maxLines: maxLines,
              controller: originalText,
              onChanged: setNewValue,
            )
          : TextField(
              autocorrect: true,
              decoration: InputDecoration(labelText: inputName),
              controller: originalText,
              onChanged: setNewValue,
            );
    }

    Column _buildCupertinoSelector() {
      return Column(
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
            maxLines: 3,
            setNewValue: (newValue) {
              setState(() {
                newDescription = newValue;
              });
            },
          ),
          CupertinoButton(
            onPressed: () => showCupertinoModalPopup(
                context: context,
                builder: (ctx) {
                  return Container(
                    height: 200,
                    child: CupertinoPicker(
                      itemExtent: 35.0,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          urgency = Urgency.values[index].toString();
                        });
                      },
                      children: <Widget>[
                        Text('Relaxed'),
                        Text('Get Done'),
                        Text('Urgent'),
                        Text('Top Priority'),
                      ],
                    ),
                  );
                }),
            child: urgency == null ? Text('Choose Urgency Level') : Text(urgency.substring(8)),
          ),
        ],
      );
    }

    Widget _buildCupertinoDialog() {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 10,
        ),
        child: CupertinoAlertDialog(
          actions: <Widget>[
            if (widget.currentNote == null)
              CupertinoDialogAction(
                child: _buildCancelButton('Cancel'),
              ),
            if (widget.currentNote != null)
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: _buildDeleteButton('Delete'),
              ),
            CupertinoDialogAction(
              child: _buildDoneButton('Done'),
              isDefaultAction: true,
            ),
          ],
          content: SingleChildScrollView(
            child: _buildCupertinoSelector(),
          ),
        ),
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
                    if (widget.currentNote != null)
                      _buildDeleteButton('Delete'),
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

    return Platform.isIOS
        ? _buildCupertinoDialog()
        : _buildAndroidBottomSheet();
  }
}
