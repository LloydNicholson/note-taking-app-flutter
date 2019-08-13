import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './active_note_list_item.dart';

class ActiveNotesList extends StatefulWidget {
  final Function deleteNote;
  final Function openNoteEditor;
  final bool showCompleted;

  ActiveNotesList(
    this.deleteNote,
    this.openNoteEditor,
    this.showCompleted,
  );

  @override
  _ActiveNotesListState createState() => _ActiveNotesListState();
}

class _ActiveNotesListState extends State<ActiveNotesList>
    with SingleTickerProviderStateMixin {
  Animation<Offset> _animation;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // set up a controller for the animation
    _controller = AnimationController(
      duration: Duration(
        milliseconds: 300,
      ),
      vsync: this,
    );
    // set up the animation with a curved animation
    _animation = Tween<Offset>(begin: Offset(1.0, 0), end: Offset(0.0, 0)).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
    // _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildListCard(int index, DocumentSnapshot note) {
      return AnimatedList(
        builder: (ctx, child) {
          return Card(
          margin: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 5,
          ),
          elevation: 5,
          child: ActiveNoteListItem(
            currentItemIndex: index,
            note: note,
            openNoteEditor: widget.openNoteEditor,
          );
          
        },
        animation: _animation,
        ),
      );
    }

    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('currentNotes').snapshots(),
        builder: (context, snapshot) {
          // var currentIndex = -1;
          if (!snapshot.hasData) return CircularProgressIndicator();
          return snapshot.data.documents.length <= 0
              ? Center(
                  child: Text(
                    'No notes added',
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
