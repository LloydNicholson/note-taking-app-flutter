import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_note_taking_app/providers/auth.dart';
import 'package:new_note_taking_app/screens/auth_screen.dart';
import 'package:provider/provider.dart';

import './screens/active_notes_screen.dart';
import './screens/completed_notes_screen.dart';
import './providers/notes.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Notes(),
        ),
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        StreamProvider<FirebaseUser>.value(
          value: FirebaseAuth.instance.onAuthStateChanged,
        ),
      ],
      child: Consumer<FirebaseUser>(
        builder: (ctx, firebaseUserData, _) {
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
            home: AuthScreen(),
            routes: {
              ActiveNotesScreen.routeName: (ctx) => ActiveNotesScreen(),
              AuthScreen.routeName: (ctx) => AuthScreen(),
              CompletedNotesScreen.routeName: (ctx) => CompletedNotesScreen(),
            },
          );
        },
      ),
    );
  }
}
