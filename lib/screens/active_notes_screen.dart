import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/completed_notes_screen.dart';
import '../widgets/active_notes_list.dart';
import '../widgets/new_note.dart';

class ActiveNotesScreen extends StatefulWidget {
  @override
  _ActiveNotesScreenState createState() => _ActiveNotesScreenState();
}

class _ActiveNotesScreenState extends State<ActiveNotesScreen>
    with SingleTickerProviderStateMixin {
  var _showCompletedNotes = true;

  void _openNoteCreator() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return NewNote(
          currentNote: null,
        );
      },
    );
  }

  void _deleteNote(int index, DocumentSnapshot note) {
    HapticFeedback.heavyImpact();
    note.reference.delete();
  }

  void _openNoteEditor(int index, DocumentSnapshot note) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return NewNote(currentNote: note);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          // Add new action for showing completed notes
          IconButton(
            icon: Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, CompletedNotesScreen.routeName);
            },
          ),
        ],
        title: Text('Notes'),
      ),
      body: Column(
        children: <Widget>[
          ActiveNotesList(
            _deleteNote,
            _openNoteEditor,
            _showCompletedNotes,
          ),
        ],
      ),
      floatingActionButton: Platform.isIOS
          ? null
          : FloatingActionButton(
              child: Icon(Icons.add),
              backgroundColor: Theme.of(context).primaryColor,
              // adding a new note onto the list
              onPressed: _openNoteCreator,
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
