import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurant_app/utils/constants.dart';
import 'package:restaurant_app/utils/containers.dart';

/// Provides various misc. functions used throughout the app

class Functions {
  /// Returns a restaurant query reference
  static Query<Restaurant> getRestaurantRef() {
    return FirebaseFirestore.instance
        .collection(Constants.restaurantKey)
        .orderBy(Constants.dateUpdatedKey, descending: true)
        .withConverter<Restaurant>(
          fromFirestore: (snapshots, _) => Restaurant.fromJson(snapshots.data()!, id: snapshots.id),
          toFirestore: (restaurant, _) => restaurant.toJson(),
        );
  }

  /// Returns formatted string given a [date]
  static String getDateString(dynamic date) {
    if (date.runtimeType == String) date = DateTime.tryParse(date);
    if (date == null) return '';
    return '${date.day}.${date.month}.${date.year}';
  }
}
