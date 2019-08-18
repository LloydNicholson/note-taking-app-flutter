import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/completed_notes_screen.dart';
import '../widgets/active_notes_list.dart';
import '../widgets/new_note.dart';

class ActiveNotesScreen extends StatelessWidget {
  void _openNoteCreator(BuildContext ctx) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: ctx,
      builder: (ctx) {
        return NewNote(
          currentNote: null,
          currentIndex: 0,
        );
      },
    );
  }

  void _openNoteEditor(BuildContext ctx, int index, DocumentSnapshot note) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: ctx,
      builder: (ctx) {
        return NewNote(
          currentNote: note,
          currentIndex: index,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.check_circle,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushNamed(context, CompletedNotesScreen.routeName);
          },
        ),
        actions: <Widget>[
          // Add new action for showing completed notes
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _openNoteCreator(context),
          ),
        ],
        title: Text('Notes'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          ActiveNotesList(
            _openNoteEditor,
          ),
        ],
      ),
      floatingActionButton: Platform.isIOS
          ? null
          : FloatingActionButton(
              child: Icon(Icons.add),
              backgroundColor: Theme.of(context).primaryColor,
              // adding a new note onto the list
              onPressed: () => _openNoteCreator(context),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
