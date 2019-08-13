import 'package:flutter/material.dart';

import './screens/active_notes_screen.dart';
import './screens/completed_notes_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Note Taking App',
      theme: ThemeData(
        primaryColor: Colors.purple,
        textTheme: TextTheme(
          title: TextStyle(
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
      routes: {
        '/': (ctx) => ActiveNotesScreen(),
        CompletedNotesScreen.routeName: (ctx) => CompletedNotesScreen(),
      },
    );
  }
}
