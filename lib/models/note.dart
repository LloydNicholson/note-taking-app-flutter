import 'package:flutter/foundation.dart';

enum Urgency { Relaxed, GetDone, Urgent, TopPriority }

class Note {
  final String id;
  final String title;
  final String description;
  final String dueDate;
  final String reminderDate;
  final Urgency urgency;

  Note({
    @required this.id,
    this.title = '',
    this.description = '',
    this.dueDate = '27/07/2019',
    this.reminderDate = '26/07/2019',
    this.urgency = Urgency.Relaxed,
  });
}
