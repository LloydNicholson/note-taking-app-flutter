import 'package:flutter/material.dart';

import '../widgets/completed_notes_list.dart';

class CompletedNotesScreen extends StatelessWidget {
  static const routeName = '/completed-notes';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed Notes'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: CompletedNotesList(),
    );
  }
}
