import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/completed_notes_list.dart';
import '../providers/notes.dart';

class CompletedNotesScreen extends StatelessWidget {
  static const routeName = '/completed-notes';

  @override
  Widget build(BuildContext context) {
    List<DocumentSnapshot> completedNotes = [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Completed Notes'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(300, 50, 0, 0),
                items: [
                  PopupMenuItem(
                    child: FlatButton(
                      child: Text('Order by Title'),
                      onPressed: () {
                        // order documents by title
                        // Provider.of<Notes>(context)
                        //     .completedNotes
                        //     .orderBy('title');
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: FlatButton(
                      child: Text('Order by Description'),
                      onPressed: () {
                        // order docs by description
                        // Provider.of<Notes>(context)
                        //     .completedNotes
                        //     .orderBy('description');
                      },
                    ),
                  ),
                ],
              );
            },
          )
        ],
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: CompletedNotesList(),
    );
  }
}
