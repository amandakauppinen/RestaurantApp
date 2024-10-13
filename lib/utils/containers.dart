import 'package:cloud_firestore/cloud_firestore.dart';

/// Used to group all containers for parsing data received from cloud firestore

class Restaurant {
  String? id, name, imagePath, dateAdded, dateOpened, userId;
  Location? location;
  List<Cuisine>? cuisines;
  Review? latestReview;
  List<dynamic>? usersFavourited;
  double? averageReviewScore;
  int? reviewCount;

  Restaurant(
      {this.id,
      this.cuisines,
      this.location,
      this.name,
      this.dateAdded,
      this.dateOpened,
      this.imagePath,
      this.latestReview,
      this.userId,
      this.usersFavourited,
      this.averageReviewScore,
      this.reviewCount});

  bool isValid() {
    try {
      id!;
      location?.isValid() == true;
      name!;
    } catch (error) {
      return false;
    }
    return true;
  }

  static Restaurant fromJson(Map<String, Object?> json, {String? id}) {
    List<Cuisine> cuisineList = [];
    if (json.keys.contains('cuisines')) {
      for (var element in (json['cuisines'] as List).cast<Map<String, dynamic>>()) {
        cuisineList.add(Cuisine(name: element['name'], description: element['description']));
      }
    }

    return Restaurant(
        id: id ?? json['id'] as String?,
        cuisines: cuisineList,
        location: json['location'] != null
            ? Location.fromJson((json['location'] as Map<String, dynamic>))
            : null,
        name: json['name'] as String?,
        imagePath: json['imagePath'] as String?,
        dateAdded: json['dateAdded'] as String?,
        dateOpened: json['dateOpened'] as String?,
        userId: json['userId'] as String?,
        latestReview: json['latestReview'] != null
            ? Review.fromJson(json['latestReview'] as Map<String, dynamic>)
            : null,
        usersFavourited: json['usersFavourited'] as List?,
        averageReviewScore: json['averageReviewScore'] as double?,
        reviewCount: json['reviewCount'] as int?);
  }

  Map<String, Object?> toJson() {
    List<Map<String, dynamic>> cuisineMaps = [];
    cuisines?.forEach((cuisine) {
      cuisineMaps.add(cuisine.toJson());
    });

    return {
      'id': id,
      'cuisines': cuisineMaps,
      'location': location?.toJson(),
      'name': name,
      'imagePath': imagePath,
      'dateAdded': dateAdded ?? DateTime.now().toIso8601String(),
      'dateOpened': dateOpened ?? DateTime.now().toIso8601String(),
      'latestReview': latestReview?.toJson(),
      'userId': userId,
      'usersFavourited': usersFavourited,
      'averageReviewScore': averageReviewScore,
      'reviewCount': reviewCount
    };
  }

  Map<String, Object?> toJsonLimited() {
    return {'id': id, 'location': location?.toJson(), 'name': name, 'imagePath': imagePath};
  }

  String getLocationString({bool excludeProvince = true}) {
    List<String?> locations = [
      location?.city,
      excludeProvince ? null : location?.province,
      location?.country
    ];
    locations.removeWhere((element) => element == null);
    String locationString = '';
    for (int i = 0; i < locations.length; i++) {
      if (i != 0) locationString += ', ';
      locationString += locations[i]!;
      if (i < locations.length - 1 && locationString.isNotEmpty) {}
    }
    return locationString;
  }
}

class Cuisine {
  String? name, description;

  bool isValid() {
    try {
      name!;
      description!;
    } catch (error) {
      return false;
    }
    return true;
  }

  Cuisine({required this.name, required this.description});

  Cuisine.fromJson(Map<String, Object?> json)
      : this(name: json['name'] as String?, description: json['description'] as String?);

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }
}

class Location {
  String? city, province, country;
  GeoPoint? coordinates;

  Location({this.city, this.province, this.country, this.coordinates});

  bool isValid() {
    try {
      city!;
      country!;
      coordinates!;
    } catch (error) {
      return false;
    }
    return true;
  }

  Location.fromJson(Map<String, Object?> json)
      : this(
            city: json['city'] as String?,
            province: json['province'] as String?,
            country: json['country'] as String?,
            coordinates: json['coordinates'] as GeoPoint?);

  Map<String, Object?> toJson() {
    return {'city': city, 'province': province, 'country': country, 'coordinates': coordinates};
  }
}

class AppUser {
  String? id, firstName, lastName, email, authId, dateJoined;

  bool isValid() {
    try {
      id!;
      firstName!;
      lastName!;
      email!;
    } catch (error) {
      return false;
    }
    return true;
  }

  AppUser({this.id, this.firstName, this.lastName, this.email, this.authId, this.dateJoined});

  AppUser.fromJson(Map<String, Object?> json, String docId)
      : this(
            id: docId,
            authId: json['authId'] as String?,
            firstName: json['firstName'] as String?,
            lastName: json['lastName'] as String?,
            email: json['email'] as String?,
            dateJoined: json['dateJoined'] as String?);

  Map<String, Object?> toJson() {
    return {
      'authId': authId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'dateJoined': dateJoined ?? DateTime.now().toIso8601String()
    };
  }

  void clear() {
    id = '';
    firstName = '';
    lastName = '';
    email = '';
    authId = '';
    dateJoined = '';
  }
}

class Review {
  String? id, title, content, userId, dateCreated, dateUpdated;
  int? reviewScore;
  Restaurant? restaurant;
  bool newData;

  Review(
      {this.id,
      this.title,
      this.content,
      this.dateCreated,
      this.dateUpdated,
      this.reviewScore,
      this.userId,
      this.restaurant,
      this.newData = true});

  bool isValid() {
    try {
      if (!newData) id!;
      title != null && title != '';
      content != null && content != '';
      dateCreated!;
      dateUpdated!;
      reviewScore!;
      userId!;
      restaurant?.isValid() == true;
    } catch (error) {
      return false;
    }
    return true;
  }

  Review.fromJson(Map<String, Object?> json, {String? id})
      : this(
            id: id ?? json['id'] as String?,
            title: json['title'] as String?,
            content: json['content'] as String?,
            dateCreated: json['dateCreated'] as String?,
            dateUpdated: json['dateUpdated'] as String?,
            reviewScore: json['reviewScore'] as int?,
            userId: json['userId'] as String?,
            restaurant: json['restaurantInfo'] != null
                ? Restaurant.fromJson(json['restaurantInfo'] as Map<String, dynamic>)
                : null);

  Map<String, Object?> toJson() {
    return {
      'title': title,
      'content': content,
      'dateCreated': dateCreated ?? DateTime.now().toIso8601String(),
      'dateUpdated': dateUpdated ?? DateTime.now().toIso8601String(),
      'reviewScore': reviewScore,
      'userId': userId,
      'restaurantInfo': restaurant?.toJsonLimited()
    };
  }

  Future<bool> sendData() async {
    final reviewRef = FirebaseFirestore.instance.collection('reviews').withConverter<Review>(
        fromFirestore: (snapshots, _) => Review.fromJson(snapshots.data()!, id: snapshots.id),
        toFirestore: (review, _) => review.toJson());
    String? returnedReviewId = id;
    newData
        ? returnedReviewId = (await reviewRef.add(this)).id
        : await reviewRef.doc(id!).update(toJson());
    if ((await FirebaseFirestore.instance.collection('reviews').doc(returnedReviewId).get())
            .data() !=
        null) {
      id = returnedReviewId;
      return true;
    }
    return false;
  }
}
