import 'package:flutter/material.dart';
import 'package:new_note_taking_app/screens/active_notes_screen.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  FocusNode _passwordNode = FocusNode();
  FocusNode _confirmPasswordNode = FocusNode();
  TextEditingController _confirmPasswordController =
      TextEditingController(text: '');
  var isLoginPage = true;
  var isLoading = false;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  Auth _authProviderData;

  @override
  void initState() {
    super.initState();
    _authProviderData = Provider.of<Auth>(context, listen: false);
  }

  @override
  void dispose() {
    _passwordNode.dispose();
    _confirmPasswordNode.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    setState(() {
      isLoading = true;
    });
    if (!_authProviderData.formKey.currentState.validate()) {
      return;
    }
    _authProviderData.formKey.currentState.save();
    _confirmPasswordController.clear();
    try {
      if (isLoginPage) {
        await _authProviderData.login(
          _authData['email'],
          _authData['password'],
        );
      } else {
        await _authProviderData.signUp(
          _authData['email'],
          _authData['password'],
        );
      }
      setState(() {
        Navigator.pushReplacementNamed(context, ActiveNotesScreen.routeName);
        isLoading = false;
      });
    } catch (error) {
      // do error handling
      print(error);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      width: 300,
      height: isLoginPage ? 300 : 360,
      padding: const EdgeInsets.all(15.0),
      child: Form(
        key: _authProviderData.formKey,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: <Widget>[
                  Text(
                    '${isLoginPage ? 'Login' : 'Sign Up'}',
                    style: TextStyle(fontSize: 20),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Email'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (val) {
                      setState(() {
                        _authData['email'] = val;
                      });
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordNode);
                    },
                    validator: (val) {
                      if (!val.contains('@')) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                    focusNode: _passwordNode,
                    textInputAction: TextInputAction.next,
                    validator: (val) {
                      if (val.length <= 6 || val.isEmpty) {
                        return 'Password is too short!';
                      }
                      return null;
                    },
                    onSaved: (val) {
                      setState(() {
                        _authData['password'] = val;
                      });
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_confirmPasswordNode);
                    },
                  ),
                  isLoginPage
                      ? SizedBox(height: 10)
                      : TextFormField(
                          obscureText: true,
                          controller: _confirmPasswordController,
                          decoration:
                              InputDecoration(labelText: 'Confirm Password'),
                          onFieldSubmitted: isLoginPage
                              ? null
                              : (val) {
                                  if (val != _authData['password']) {
                                    return 'Password doesn\'t match!';
                                  }
                                  return null;
                                }),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                        child: Text(
                          'Switch to ${isLoginPage ? 'Sign Up' : 'Login'}',
                        ),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        onPressed: () {
                          setState(() {
                            isLoginPage = !isLoginPage;
                          });
                        },
                      ),
                      FlatButton(
                        child: Text('${isLoginPage ? 'Login' : 'Sign Up'}'),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        onPressed: _onSubmit,
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
