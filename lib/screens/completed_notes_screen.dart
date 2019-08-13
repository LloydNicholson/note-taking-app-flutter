import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/completed_notes_list.dart';

class CompletedNotesScreen extends StatelessWidget {
  static const routeName = '/completed-notes';

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: CompletedNotesList(),
            navigationBar: CupertinoNavigationBar(
              middle: Text(
                'Completed Notes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              backgroundColor: CupertinoTheme.of(context).primaryColor,
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text('Completed Notes'),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            body: CompletedNotesList(),
          );
  }
}
