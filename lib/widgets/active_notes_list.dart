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
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('currentNotes').snapshots(),
        builder: (context, snapshot) {
          // var currentIndex = -1;
          if (snapshot.connectionState == ConnectionState.waiting)
            return CircularProgressIndicator();
          return Consumer<Notes>(
            builder: (ctx, animationData, _) {
              return snapshot.data.documents.length <= 0
                  ? Center(
                      child: Text(
                        'No notes added',
                        style: TextStyle(fontSize: 24),
                      ),
                    )
                  : AnimatedList(
                      key: animationData.listKey,
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
                    );
            },
          );
        },
      ),
    );
  }
}
