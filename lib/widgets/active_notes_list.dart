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
  Animation<double> _animation;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // set up a controller for the animation
    _controller = AnimationController(
      duration: Duration(
        milliseconds: 800,
      ),
      vsync: this,
    );
    // set up the animation with a curved animation
    _animation = Tween(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildListCard(int index, DocumentSnapshot note) {
      return AnimatedBuilder(
        builder: (ctx, child) {
          final double deviceWidth = MediaQuery.of(ctx).size.width;

          return Transform.translate(
            offset: Offset(-_animation.value * deviceWidth, 0),
            child: child,
          );
        },
        animation: _animation,
        child: Card(
          margin: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 5,
          ),
          elevation: 5,
          child: ActiveNoteListItem(
            currentItemIndex: index,
            note: note,
            openNoteEditor: widget.openNoteEditor,
          ),
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
