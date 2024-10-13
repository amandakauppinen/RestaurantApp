import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/application_state.dart';
import 'package:restaurant_app/ui/screens/user_profile_screen.dart';
import 'package:restaurant_app/utils/constants.dart';
import 'package:restaurant_app/utils/populate_data.dart';

/// Builds a customised scaffold with an optional [title]
///
/// [body] is provided by parent widget and [includeDrawer] is set to true by default
/// It is excluded when called from [UserProfileScreen]
class CustomScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final bool? includeDrawer;

  const CustomScaffold({this.title, required this.body, this.includeDrawer = true, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      return Scaffold(
          appBar: AppBar(
            title: title != null ? Text(title!) : null,
          ),
          endDrawer: includeDrawer ?? true
              ? Drawer(
                  child: ListView(children: [
                  if (kDebugMode && appState.user?.email == Constants.adminEmail)
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              PopulateData.populateDataDialog(context);
                            },
                            child: const Text('Populate Database'))),
                  if (appState.loggedIn)
                    ListTile(
                        title: const Text('Profile'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => const UserProfileScreen()));
                        }),
                  appState.getLogInLogOutButton(context)
                ]))
              : null,
          body: body);
    });
  }
}
