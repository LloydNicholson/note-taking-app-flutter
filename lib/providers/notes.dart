import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

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
    FirebaseUser userData = Provider.of<FirebaseUser>(ctx, listen: false);
    if (_listKey.currentState != null && userData != null) {
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
    FirebaseUser userData = Provider.of<FirebaseUser>(ctx, listen: false);
    if (userData != null) {
      await _currentNotes.add({
        'userId': userData.uid,
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
    FirebaseUser userData = Provider.of<FirebaseUser>(ctx, listen: false);
    _isLoading = true;
    notifyListeners();
    if (userData != null) {
      Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot freshSnap =
            await transaction.get(currentNote.reference);
        await transaction.update(freshSnap.reference, {
          'userId': userData.uid,
          'title': title,
          'description': description,
          'urgency': urgency,
          'date': date.toIso8601String(),
          'time': time.toIso8601String(),
        }).then((_) {
          _isLoading = false;
          notifyListeners();
        });
      });
    }
  }

  // Future<List<QuerySnapshot>> fetchCurrentNotes() async {
  //   return _currentNotes.snapshots().toList();
  // }

  // Future<List<QuerySnapshot>> fetchCompletedNotes() async {
  //   return _completedNotes.snapshots().toList();
  // }
}
