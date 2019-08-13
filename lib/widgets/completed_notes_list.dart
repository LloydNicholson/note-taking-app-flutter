import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/completed_note_list_item.dart';

class CompletedNotesList extends StatefulWidget {
  @override
  _CompletedNotesListState createState() => _CompletedNotesListState();
}

class _CompletedNotesListState extends State<CompletedNotesList>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    Widget _buildListCard(int index, DocumentSnapshot note) {
      return Card(
        margin: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 5,
        ),
        elevation: 5,
        child: CompletedNoteListItem(note),
      );
    }

    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('completedNotes').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return snapshot.data.documents.length <= 0
              ? Center(
                  child: Text(
                    'No notes completed',
                    style: TextStyle(fontSize: 24),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (ctx, index) {
                    return _buildListCard(
                      index,
                      snapshot.data.documents[index],
                    );
                  },
                  itemCount: snapshot.data.documents.length,
                );
        },
      ),
    );
  }
}
