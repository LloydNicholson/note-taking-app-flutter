import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum Urgency { Relaxed, GetDone, Urgent, TopPriority }

class ActiveNoteListItem extends StatelessWidget {
  final DocumentSnapshot note;
  final int currentItemIndex;
  final Function openNoteEditor;

  ActiveNoteListItem({
    this.note,
    this.currentItemIndex,
    this.openNoteEditor,
  });

  @override
  Widget build(BuildContext context) {
    void _addNoteToCompleted(DocumentSnapshot note) {
      note.reference.delete();
      Firestore.instance.collection('completedNotes').add(note.data);
    }

    return Dismissible(
      key: ValueKey(note['id']),
      direction: DismissDirection.startToEnd,
      onDismissed: (dir) => _addNoteToCompleted(note),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(
          right: 20,
          left: 20,
        ),
        color: Colors.green,
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.only(
          left: 5,
          top: 10,
          bottom: 10,
          right: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 40,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (note['urgency'] == Urgency.TopPriority.toString())
                Icon(
                  Icons.error,
                  color: Colors.red,
                ),
              if (note['urgency'] == Urgency.Urgent.toString())
                Icon(
                  Icons.watch_later,
                  color: Colors.redAccent,
                ),
              if (note['urgency'] == Urgency.GetDone.toString())
                Icon(
                  Icons.trending_up,
                  color: Colors.greenAccent,
                ),
              if (note['urgency'] == Urgency.Relaxed.toString())
                Icon(
                  Icons.filter_hdr,
                  color: Colors.green,
                ),
            ],
          ),
        ),
        title: Text(
          note['title'],
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          note['description'],
          style: TextStyle(fontSize: 16),
        ),
//            Text(DateFormat.yMEd().format(notes[index].dueDate)
        onTap: () => openNoteEditor(currentItemIndex, note),
      ),
    );
  }
}
