import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/active_note_list_item.dart';

class Notes extends ChangeNotifier {
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  GlobalKey<AnimatedListState> get listKey {
    return _listKey;
  }

  Future<void> removeNote(
    BuildContext ctx,
    int index,
    DocumentSnapshot currentNote,
  ) async {
    _listKey.currentState.removeItem(
      index,
      (ctx, animation) {
        return ActiveNoteListItem(
          currentItemIndex: index,
          note: currentNote,
          animation: animation,
        );
      },
      duration: Duration(milliseconds: 400),
    );
    await currentNote.reference.delete();
    notifyListeners();
  }

  Future<void> addNote(
    String id,
    String title,
    String description,
    String urgency,
  ) async {
    _listKey.currentState.insertItem(
      0,
      duration: Duration(milliseconds: 400),
    );
    await Firestore.instance.collection('currentNotes').add({
      'id': id,
      'title': title,
      'description': description,
      'urgency': urgency,
    });
    notifyListeners();
  }

  Future<void> updateNote(
    DocumentSnapshot currentNote,
    String id,
    String title,
    String description,
    String urgency,
  ) async {
    Firestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnap = await transaction.get(currentNote.reference);
      await transaction.update(freshSnap.reference, {
        'id': id,
        'title': title,
        'description': description,
        'urgency': urgency,
      });
    });
    notifyListeners();
  }
}
