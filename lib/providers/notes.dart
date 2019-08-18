import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/active_note_list_item.dart';

class Notes extends ChangeNotifier {
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  var _isLoading = false;
  CollectionReference _currentNotes =
      Firestore.instance.collection('currentNotes');
  CollectionReference _completedNotes =
      Firestore.instance.collection('completedNotes');

  GlobalKey<AnimatedListState> get listKey {
    return _listKey;
  }

  bool get isLoading {
    return _isLoading;
  }

  CollectionReference get currentNotes {
    return _currentNotes;
  }

  CollectionReference get completedNotes {
    return _completedNotes;
  }

  Future<void> removeNote(
    BuildContext ctx,
    int index,
    DocumentSnapshot currentNote,
  ) async {
    if (_listKey.currentState != null) {
      _listKey.currentState.removeItem(
        index,
        (ctx, animation) {
          return ActiveNoteListItem(
            key: ValueKey(currentNote['id']),
            currentItemIndex: index,
            note: currentNote,
            animation: animation,
          );
        },
        duration: Duration(milliseconds: 400),
      );
    }
    await currentNote.reference.delete();
    notifyListeners();
  }

  Future<void> addNote({
    BuildContext ctx,
    String id,
    String title,
    String description,
    String urgency,
    DateTime date,
    DateTime time,
  }) async {
    await _currentNotes.add({
      'id': id,
      'title': title,
      'description': description,
      'urgency': urgency,
      'date': date.toIso8601String(),
      'time': time.toIso8601String(),
    });
    _listKey.currentState.insertItem(
      0,
      duration: Duration(milliseconds: 400),
    );
    notifyListeners();
  }

  Future<void> updateNote({
    BuildContext ctx,
    DocumentSnapshot currentNote,
    String id,
    String title,
    String description,
    String urgency,
    DateTime date,
    DateTime time,
  }) async {
    _isLoading = true;
    Firestore.instance.runTransaction((transaction) async {
      try {
        DocumentSnapshot freshSnap = await transaction.get(currentNote.reference);
        await transaction.update(freshSnap.reference, {
          'id': id,
          'title': title,
          'description': description,
          'urgency': urgency,
          'date': date.toIso8601String(),
          'time': time.toIso8601String(),
        });
      } catch (error) {
        print(error);
      }
    }).then((_) {
      // updated our data and loading is now false
      _isLoading = false;
    });
    notifyListeners();
  }
}
