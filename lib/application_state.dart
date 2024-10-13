// ignore_for_file: unnecessary_getters_setters

import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_app/ui/screens/restaurant_list.dart';
import 'package:restaurant_app/ui/shared/custom_form.dart';
import 'package:restaurant_app/utils/constants.dart';
import 'package:restaurant_app/utils/containers.dart';
import 'firebase_options.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

/// Handles application state with regards to a specific [_user] and their
/// [_loggedIn] status, otherwise app is used anonymously without user interactions
class ApplicationState extends ChangeNotifier {
  AppUser? _user;
  bool _loggedIn = false;

  bool get loggedIn => _loggedIn;
  AppUser? get user => _user;
  set user(AppUser? user) => _user = user;

  ApplicationState() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseUIAuth.configureProviders([EmailAuthProvider()]);

    // Listen to user changes
    auth.FirebaseAuth.instance.userChanges().listen((user) async {
      if (user == null) {
        _user = null;
        _loggedIn = false;
        notifyListeners();
      } else {
        try {
          final userQuery = (await FirebaseFirestore.instance
                  .collection(Constants.usersKey)
                  .where(Constants.authKey, isEqualTo: user.uid)
                  .get())
              .docs
              .first;
          _user = AppUser.fromJson(userQuery.data(), userQuery.id);
          _loggedIn = true;
          notifyListeners();
        } catch (error) {
          log('Error retrieving user', error: error, name: 'ApplicationState.init');
          if (kDebugMode) {
            print(error);
          }
        }
      }
    });
  }

  /// Returns a sign-in screen
  Widget appSignIn() {
    return SignInScreen(
      providers: [EmailAuthProvider()],
      actions: [
        AuthStateChangeAction((context, state) async {
          final userRef = FirebaseFirestore.instance.collection('users');
          if (state is SignedIn || state is UserCreated) {
            List<Future> futures = [];

            // Set user
            var user = (state is SignedIn) ? state.user : (state as UserCreated).credential.user;
            if (user == null) {
              return;
            }
            if (state is UserCreated) {
              user.updateDisplayName(user.email!.split('@')[0]);
              _user = AppUser(
                  authId: user.uid,
                  email: user.email,
                  dateJoined: DateTime.now().toLocal().toIso8601String());
              futures.add(userRef.add(_user!.toJson()));
            }
            _loggedIn = true;
            Future.wait(futures).then((value) {
              userRef.where(Constants.emailKey, isEqualTo: user.email).get().then((returnedUser) {
                try {
                  _user =
                      AppUser.fromJson(returnedUser.docs.first.data(), returnedUser.docs.first.id);
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => const RestaurantWidget()));
                } catch (error) {
                  log('Error retrieving user', error: error, name: 'ApplicationState.appSignIn');
                  if (kDebugMode) {
                    print(error);
                  }
                }
              });
            });
          }
        }),
      ],
    );
  }

  /// Signs out a user
  Future<void> signOut() async {
    await auth.FirebaseAuth.instance.signOut();
    notifyListeners();
  }

  /// Returns a button either for logging in or out
  Widget getLogInLogOutButton(BuildContext context) {
    return ListTile(
        title: Text(loggedIn ? 'Log out' : 'Log in'),
        onTap: () async {
          Navigator.pop(context);
          if (loggedIn) {
            await signOut();
          } else {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => appSignIn()));
          }
        });
  }

  /// Builds a dialog used to enter user information if not previously saved
  Widget userInfoDialogForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String firstName = '', lastName = '';

    return AlertDialog(
        title: const Text('Enter details'),
        actions: [
          ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _user!.firstName = firstName;
                  _user!.lastName = lastName;
                  final user = _user!;
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.id)
                      .update({'firstName': user.firstName, 'lastName': user.lastName});
                  Navigator.pop(context);
                  notifyListeners();
                }
              },
              child: const Text('Submit'))
        ],
        content: Scaffold(
            body: Form(
                key: formKey,
                child: ListView(children: [
                  CustomForm(hint: 'First Name', onChanged: (value) => firstName = value),
                  CustomForm(hint: 'Last Name', onChanged: (value) => lastName = value),
                  CustomForm(hint: _user!.email!, enabled: false)
                ]))));
  }
}
