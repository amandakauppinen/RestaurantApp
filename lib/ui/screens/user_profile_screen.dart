import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/application_state.dart';
import 'package:restaurant_app/ui/screens/restaurant_list.dart';
import 'package:restaurant_app/ui/screens/review_list.dart';
import 'package:restaurant_app/ui/shared/padded_widget.dart';
import 'package:restaurant_app/utils/constants.dart';
import 'package:restaurant_app/utils/containers.dart';
import 'package:restaurant_app/ui/shared/custom_scaffold.dart';

/// Profile screen for a logged in user
class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      return CustomScaffold(
          title: Constants.userProfile,
          body: ListView(children: [
            const PaddedWidget(),
            CircleAvatar(
                radius: 60,
                child: Text(_getUserInitials(appState.user), style: const TextStyle(fontSize: 45))),
            const PaddedWidget(),
            ListTile(
              title: Text(Constants.userFavourites),
              onTap: () async {
                final favouriteRef = FirebaseFirestore.instance
                    .collection(Constants.favouriteRestaurantsKey)
                    .where(Constants.userIdKey, isEqualTo: appState.user?.id)
                    .withConverter<Restaurant>(
                      fromFirestore: (snapshots, _) => Restaurant.fromJson(snapshots.data()!),
                      toFirestore: (restaurant, _) => restaurant.toJson(),
                    );
                await favouriteRef.get().then((value) => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RestaurantWidget(
                            restaurants: value.docs.map((review) => review.data()).toList()))));
              },
            ),
            const PaddedWidget(),
            ListTile(
                title: Text(Constants.myReviews),
                onTap: () async {
                  final reviewRef = FirebaseFirestore.instance
                      .collection(Constants.reviewsKey)
                      .where(Constants.userIdKey, isEqualTo: appState.user?.id)
                      .orderBy(Constants.dateUpdatedKey, descending: true)
                      .withConverter<Review>(
                        fromFirestore: (snapshots, _) => Review.fromJson(snapshots.data()!),
                        toFirestore: (review, _) => review.toJson(),
                      );
                  await reviewRef.get().then((value) => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ReviewList(value.docs.map((review) => review.data()).toList()))));
                })
          ]),
          includeDrawer: false);
    });
  }

  /// Returns a string containing a given [user]'s initials based on first and surname
  String _getUserInitials(AppUser? user) {
    try {
      return '${user!.firstName!.substring(0, 1).toUpperCase()} ${user.lastName!.substring(0, 1).toUpperCase()}';
    } catch (error) {
      log('Error parsing names', error: error, name: 'ApplicationState.getUserInitials');
      if (kDebugMode) {
        print(error);
      }
      return '';
    }
  }
}
