import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notes.dart';

import '../widgets/completed_note_list_item.dart';

class CompletedNotesList extends StatefulWidget {
  @override
  _CompletedNotesListState createState() => _CompletedNotesListState();
}

class _CompletedNotesListState extends State<CompletedNotesList>
    with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<Notes>(
      builder: (ctx, notesData, _) {
        return Container(
          child: StreamBuilder<QuerySnapshot>(
            stream: notesData.completedNotes.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              return snapshot.data.documents.length <= 0
                  ? Center(
                      child: Text(
                        'No notes completed',
                        style: TextStyle(fontSize: 24),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (ctx, index) {
                        return _buildListCard(
                          index,
                          snapshot.data.documents[index],
                        );
                      },
                    );
            },
          ),
        );
      },
    );
  }
}
