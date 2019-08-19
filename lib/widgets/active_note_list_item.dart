import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/notes.dart';

enum Urgency { Relaxed, GetDone, Urgent, TopPriority }

class ActiveNoteListItem extends StatelessWidget {
  final DocumentSnapshot note;
  final int currentItemIndex;
  final Function openNoteEditor;
  final Animation<double> animation;
  final Key key;

  ActiveNoteListItem({
    this.key,
    this.note,
    this.currentItemIndex,
    this.openNoteEditor,
    this.animation,
  }) : super(key: key);

  void _addNoteToCompleted(BuildContext ctx) {
    final notesData = Provider.of<Notes>(ctx, listen: false);
    notesData.removeNote(ctx, currentItemIndex, note);
    notesData.completedNotes.add(note.data);
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(
          begin: Offset(1.0, 0),
          end: Offset(0.0, 0),
        ),
      ),
      child: Card(
        margin: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 5,
        ),
        elevation: 5,
        child: Dismissible(
          key: ValueKey(note['id']),
          direction: DismissDirection.startToEnd,
          onDismissed: (dir) => _addNoteToCompleted(context),
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
              right: 15,
            ),
            leading: Consumer<Notes>(
              builder: (ctx, notesData, _) {
                return CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 30,
                  child: note != null && notesData.isLoading
                      ? CircularProgressIndicator()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            if (note['urgency'] ==
                                Urgency.TopPriority.toString())
                              Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                            if (note['urgency'] == Urgency.Urgent.toString())
                              Icon(
                                Icons.watch_later,
                                color: Colors.orangeAccent,
                              ),
                            if (note['urgency'] == Urgency.GetDone.toString())
                              Icon(
                                Icons.trending_up,
                                color: Colors.green,
                              ),
                            if (note['urgency'] == Urgency.Relaxed.toString())
                              Icon(
                                Icons.filter_hdr,
                                color: Colors.greenAccent,
                              ),
                          ],
                        ),
                );
              },
            ),
            title: Text(
              note['title'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              note['description'],
              style: TextStyle(fontSize: 14),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  DateFormat.MMMd().format(
                    DateTime.parse(note['date']),
                  ),
                ),
                Text(
                  TimeOfDay.fromDateTime(
                    DateTime.parse(note['time']),
                  ).format(context),
                ),
              ],
            ),
            onTap: () => openNoteEditor(context, currentItemIndex, note),
          ),
        ),
      ),
    );
  }
}
