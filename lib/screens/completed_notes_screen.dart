import 'package:flutter/material.dart';

import '../widgets/completed_notes_list.dart';

class CompletedNotesScreen extends StatelessWidget {
  static const routeName = '/completed-notes';

  @override
  Widget build(BuildContext context) {
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
