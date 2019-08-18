import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import './active_note_list_item.dart';
import '../providers/notes.dart';

class ActiveNotesList extends StatefulWidget {
  final Function openNoteEditor;

  ActiveNotesList(
    this.openNoteEditor,
  );

  @override
  _ActiveNotesListState createState() => _ActiveNotesListState();
}

class _ActiveNotesListState extends State<ActiveNotesList>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer<Notes>(
      builder: (ctx, notesData, _) {
        return Container(
          child: StreamBuilder<QuerySnapshot>(
            stream: notesData.currentNotes.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) notesData.currentNotes.orderBy('title');
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(child: CircularProgressIndicator());
              return Expanded(
                child: snapshot.data.documents.length <= 0
                    ? Center(
                        child: Text(
                          'No notes added',
                          style: TextStyle(fontSize: 24),
                        ),
                      )
                    : AnimatedList(
                        key: notesData.listKey,
                        initialItemCount: snapshot.data.documents.length,
                        shrinkWrap: true,
                        itemBuilder: (ctx, index, animation) {
                          return ActiveNoteListItem(
                            currentItemIndex: index,
                            note: snapshot.data.documents[index],
                            openNoteEditor: widget.openNoteEditor,
                            animation: animation,
                          );
                        },
                      ),
              );
            },
          ),
        );
      },
    );
  }
}
