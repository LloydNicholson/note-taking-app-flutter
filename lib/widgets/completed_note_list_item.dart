import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CompletedNoteListItem extends StatelessWidget {
  final DocumentSnapshot completedNote;

  CompletedNoteListItem(this.completedNote);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(
        left: 0,
        top: 10,
        bottom: 10,
        right: 5,
      ),
      leading: CircleAvatar(
        backgroundColor: Platform.isIOS
            ? CupertinoTheme.of(context).primaryColor
            : Theme.of(context).primaryColor,
        radius: 40,
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
      title: Text(
        completedNote['title'],
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(completedNote['description']),
//            Text(DateFormat.yMEd().format(notes[index].dueDate)
      onTap: null,
    );
  }
}
