import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_note_taking_app/screens/auth_screen.dart';
import 'package:provider/provider.dart';

import '../screens/completed_notes_screen.dart';
import '../widgets/active_notes_list.dart';
import '../widgets/new_note.dart';
import '../providers/auth.dart';

class ActiveNotesScreen extends StatelessWidget {
  static const routeName = '/active-notes';

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

  void _openNoteEditor(
    BuildContext ctx,
    int index,
    DocumentSnapshot note,
  ) {
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

  Future<void> _signOut(BuildContext ctx) async {
    await Provider.of<Auth>(ctx, listen: false).signOut();
    await Navigator.pushReplacementNamed(ctx, AuthScreen.routeName);
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
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async => await _signOut(context),
          ),
        ],
        title: Text('Active Notes'),
        centerTitle: true,
      ),
      body: ActiveNotesList(_openNoteEditor),
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
