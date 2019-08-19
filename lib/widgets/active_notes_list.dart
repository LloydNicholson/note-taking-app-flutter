import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_note_taking_app/providers/auth.dart';
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
  FirebaseUser _userData;
  Notes _notesData;

  @override
  void initState() {
    super.initState();
    _userData = Provider.of<FirebaseUser>(context, listen: false);
    _notesData = Provider.of<Notes>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
        // order your stream as you see fit with where, orderBY etc... so happy!!
        stream: _notesData.currentNotes
            .where('userId', isEqualTo: _userData.uid)
            .orderBy('time')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          return (_userData == null || snapshot.data.documents.length <= 0)
              ? Center(
                  child: Text(
                    'No notes added',
                    style: TextStyle(fontSize: 24),
                  ),
                )
              : AnimatedList(
                  key: _notesData.listKey,
                  initialItemCount:
                      _userData != null ? snapshot.data.documents.length : 0,
                  itemBuilder: (ctx, index, animation) {
                    return ActiveNoteListItem(
                      currentItemIndex: index,
                      note: _userData != null
                          ? snapshot.data.documents[index]
                          : null,
                      openNoteEditor: widget.openNoteEditor,
                      animation: animation,
                    );
                  },
                );
        },
      ),
    );
  }
}
