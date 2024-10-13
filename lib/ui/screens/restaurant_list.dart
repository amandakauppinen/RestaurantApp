import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/app_theme.dart';
import 'package:restaurant_app/application_state.dart';
import 'package:restaurant_app/ui/screens/restaurant_screen.dart';
import 'package:restaurant_app/ui/shared/favourites_star.dart';
import 'package:restaurant_app/utils/constants.dart';
import 'package:restaurant_app/utils/containers.dart';
import 'package:restaurant_app/ui/shared/custom_scaffold.dart';
import 'package:restaurant_app/utils/functions.dart';

/// Larger container for a list [restaurants] to display in a list
///
/// The [title] and [description] fields are optional to override
class RestaurantWidget extends StatelessWidget {
  final List<Restaurant>? restaurants;
  final String? title, description;

  const RestaurantWidget({this.restaurants, super.key, this.title, this.description});

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(
        builder: (context, appState, _) => CustomScaffold(
            title: title ?? Constants.restaurantListTitle,
            body: restaurants != null

                /// Build list based on given restaurants
                ? RestaurantList(restaurants!)

                /// Retrieve restuarants and build list based on results
                : StreamBuilder(
                    stream: Functions.getRestaurantRef().snapshots(),
                    builder: ((context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return RestaurantList(
                          snapshot.data!.docs.map((restaurant) => restaurant.data()).toList(),
                          title: title,
                          description: description,
                          showDialog: appState.loggedIn &&
                              (appState.user?.firstName == null || appState.user?.lastName == null),
                        );
                      } else {
                        if (snapshot.hasError) {
                          log('Error loading restaurants',
                              error: snapshot.error, name: 'RestaurantList.build');
                          if (kDebugMode) {
                            print(snapshot.error);
                          }
                        }
                        return const Center(child: CircularProgressIndicator());
                      }
                    }))));
  }
}

/// A widget to show a list of provided [restaurants]
///
/// The [title] and [description] fields are optional to override
/// After building, [showDialog] indicates if a user login dialog should be shown
class RestaurantList extends StatefulWidget {
  final List<Restaurant> restaurants;
  final String? title, description;
  final bool showDialog;

  RestaurantList(this.restaurants,
      {super.key, this.title, this.description, this.showDialog = false});
  final Map<String, String> filters = {'cuisine': '', 'city': ''};

  @override
  State<RestaurantList> createState() => _RestaurantListState();
}

class _RestaurantListState extends State<RestaurantList> {
  @override
  void initState() {
    super.initState();

    /// Show user login dialog
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.showDialog) {
        await showDialog(
            context: context,
            builder: (dialogContext) {
              return Consumer<ApplicationState>(builder: (context, appState, _) {
                return appState.userInfoDialogForm(dialogContext);
              });
            }).then((value) => Navigator.pop(context));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.restaurants.isEmpty
        ? const Center(child: Text('No restaurants in list'))
        : SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(children: [
                  if (widget.description != null)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(widget.description!, style: const TextStyle(fontSize: 18))),
                  ListView.builder(
                      itemCount: widget.restaurants.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, count) {
                        final Map<String, Color> tileColors = _getTileColor(count);
                        final restaurant = widget.restaurants[count];
                        String? city = restaurant.location?.city;

                        return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                                shape: const RoundedRectangleBorder(
                                    side: BorderSide(color: Colors.black, width: 1.5),
                                    borderRadius: BorderRadius.all(Radius.circular(16))),
                                title: Text(restaurant.name ?? '',
                                    style: TextStyle(fontSize: AppTheme.listTileTitleSize)),
                                trailing: Consumer<ApplicationState>(
                                    builder: (context, appState, _) =>
                                        _getFavouritesStar(restaurant, appState)),
                                subtitle:
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  if (city != null)
                                    Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Text(restaurant.getLocationString(),
                                            style: const TextStyle(fontSize: 18))),
                                  if (restaurant.cuisines != null)
                                    Row(children: [
                                      for (Cuisine cuisine in restaurant.cuisines!)
                                        if (cuisine.name != null)
                                          Padding(
                                              padding: const EdgeInsets.only(right: 8),
                                              child: ElevatedButton(
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty.all<Color>(
                                                              Colors.white)),
                                                  onPressed: () => Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) {
                                                          return RestaurantList(
                                                              widget.restaurants.where((element) {
                                                                return element.cuisines!.any(
                                                                    (item) =>
                                                                        item.name == cuisine.name);
                                                              }).toList(),
                                                              title: cuisine.name!,
                                                              description: cuisine.description);
                                                        }),
                                                      ),
                                                  child: Text(cuisine.name!,
                                                      style: const TextStyle(color: Colors.black))))
                                    ])
                                ]),
                                tileColor: tileColors[Constants.colorMapTile],
                                textColor: tileColors[Constants.colorMapText],
                                onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => RestaurantScreen(restaurant)),
                                    )));
                      })
                ])));
  }

  /// Returns a star shape to indicate a favourited [restaurant]
  ///
  /// Will update [appState] when clicked
  Widget _getFavouritesStar(Restaurant restaurant, ApplicationState appState) {
    return FavouritesStar(
      isSelected: restaurant.usersFavourited != null &&
          restaurant.usersFavourited!.contains(appState.user?.id),
      onClick: (selected) async {
        /// Update app state with favourited value
        final restaurantRef =
            FirebaseFirestore.instance.collection(Constants.restaurantKey).doc(restaurant.id);
        await restaurantRef.update({
          Constants.usersFavouritedKey: selected
              ? FieldValue.arrayUnion([appState.user?.id])
              : FieldValue.arrayRemove([appState.user?.id])
        });
      },
    );
  }

  /// Returns a map with a tile color and the associated text color given an [index]
  static Map<String, Color> _getTileColor(int index) {
    if (index >= 6) index -= 6;
    switch (index) {
      case 1:
        return {Constants.colorMapTile: Colors.green, Constants.colorMapText: Colors.white};
      case 2:
        return {Constants.colorMapTile: Colors.yellow, Constants.colorMapText: Colors.black};
      case 3:
        return {Constants.colorMapTile: Colors.orange, Constants.colorMapText: Colors.black};
      case 4:
        return {Constants.colorMapTile: Colors.red, Constants.colorMapText: Colors.black};
      case 5:
        return {Constants.colorMapTile: Colors.purple, Constants.colorMapText: Colors.white};
      default:
        return {Constants.colorMapTile: Colors.blue, Constants.colorMapText: Colors.white};
    }
  }
}
