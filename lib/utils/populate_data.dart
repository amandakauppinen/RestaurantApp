import 'dart:developer';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_app/ui/shared/padded_widget.dart';
import 'package:restaurant_app/utils/constants.dart';
import 'package:restaurant_app/utils/containers.dart';

/// Class to populate data for testing - can be added to the drawer so that when
/// clicked, a dialog with population options is opened

List<AppUser> users = [
  AppUser(id: '000000', email: 'test_email0@email.com', firstName: '0Test', lastName: '0Email'),
  AppUser(id: '111111', email: 'test_email1@email.com', firstName: '1Test', lastName: '1Email'),
  AppUser(id: '222222', email: 'test_email2@email.com', firstName: '2Test', lastName: '2Email')
];

List<Restaurant> restaurants = [
  Restaurant(
      id: 'uJfSK6hS6xPzBBmv2f6w',
      name: 'Restaurant 0',
      location: Location(
          city: 'Stockholm',
          province: 'Södermanland',
          country: 'Sweden',
          coordinates: const GeoPoint(59.329362, 18.068410)),
      //imagePath: 'gs://restaurant-app-b5118.appspot.com/restaurant0.png',
      cuisines: [cuisines[0]]),
  Restaurant(
      id: 'GsjTM188e2deJMTGaxgz',
      name: 'Restaurant 1',
      location: Location(
          city: 'Phoenix',
          province: 'Arizona',
          country: 'USA',
          coordinates: const GeoPoint(33.448329, -112.074003)),
      //imagePath: 'gs://restaurant-app-b5118.appspot.com/restaurant1.png',
      cuisines: [cuisines[7], cuisines[8]]),
  Restaurant(
      id: 'wHmtbPgiWkXKO109DmFl',
      name: 'Restaurant 2',
      location: Location(
          city: 'Tokyo',
          province: 'Kantō',
          country: 'Japan',
          coordinates: const GeoPoint(35.681988, 139.769831)),
      //imagePath: 'gs://restaurant-app-b5118.appspot.com/restaurant2.png',
      cuisines: [cuisines[5]]),
  Restaurant(
      id: 'swdU3oCH4tkXlCruDKgm',
      name: 'Restaurant 3',
      location: Location(
          city: 'Helsinki',
          province: 'Uusimaa',
          country: 'Finland',
          coordinates: const GeoPoint(60.169876, 24.938397)),
      //imagePath: 'gs://restaurant-app-b5118.appspot.com/restaurant3.png',
      cuisines: [cuisines[0], cuisines[5]]),
  Restaurant(
      id: 'VZu3XoP4EX7ScTCMyE7I',
      name: 'Restaurant 4',
      location: Location(
          city: 'Montreal',
          province: 'Québec',
          country: 'Canada',
          coordinates: const GeoPoint(45.502023, -73.567640)),
      //imagePath: 'gs://restaurant-app-b5118.appspot.com/restaurant4.png',
      cuisines: [cuisines[2], cuisines[4]]),
  Restaurant(
      id: 'RTeeY0aJM2LmNh9p2gVI',
      name: 'Restaurant 5',
      location: Location(
          city: 'Rome',
          province: 'Lazio',
          country: 'Italy',
          coordinates: const GeoPoint(41.902240, 12.496424)),
      //imagePath: 'gs://restaurant-app-b5118.appspot.com/restaurant5.png',
      cuisines: [cuisines[3], cuisines[6]]),
  Restaurant(
      id: 'fXgxM4bgpDPVjWTLo5qO',
      name: 'Restaurant 6',
      location: Location(
          city: 'Heraklion',
          province: 'Crete',
          country: 'Greece',
          coordinates: const GeoPoint(35.340309, 25.143640)),
      cuisines: [cuisines[1], cuisines[3]])
];

List<Review> reviews = [
  Review(
      title: 'Great',
      content: 'A great restaurant!',
      dateCreated: '20170101',
      dateUpdated: '20170101',
      reviewScore: 5),
  Review(
      title: 'Good',
      content: 'A good restaurant!',
      dateCreated: '20180101',
      dateUpdated: '20180101',
      reviewScore: 4),
  Review(
      title: 'Okay',
      content: 'An okay restaurant!',
      dateCreated: '20190101',
      dateUpdated: '20190101',
      reviewScore: 3),
  Review(
      title: 'Bad',
      content: 'A bad restaurant!',
      dateCreated: '20200101',
      dateUpdated: '20200101',
      reviewScore: 2),
  Review(
      title: 'Horrible',
      content: 'A horrible restaurant!',
      dateCreated: '20210101',
      dateUpdated: '20210101',
      reviewScore: 1)
];

List<Cuisine> cuisines = [
  /* 0 */ Cuisine(
      name: 'Nordic',
      description:
          'New Nordic Cuisine (Danish: Det nye nordiske køkken, Swedish: Det nya nordiska köket, Norwegian: Det nye nordiske kjøkken, Finnish: Uusi pohjoismainen keittiö) is a culinary movement which has been developed in the Nordic countries, and Scandinavia in particular, since the 2000s. The evolving cuisine has sought to take advantage of the possibilities inherent in traditional Scandinavian recipes for fish and meat dishes, building on the use of local products while reviving and adapting some of the older techniques, for example, those for marinating, smoking and salting.'),
  /* 1 */ Cuisine(
      name: 'Greek',
      description:
          'Greek cuisine (Greek: Ελληνική Κουζίνα) is the cuisine of Greece and the Greek diaspora. In common with many other cuisines of the Mediterranean, it is founded on the triad of wheat, olive oil, and wine. It uses vegetables, olive oil, grains, fish, and meat, including pork, poultry, veal and beef, lamb, rabbit, and goat.'),
  /* 2 */ Cuisine(
      name: 'Canadian',
      description:
          'Canadian cuisine consists of the cooking traditions and practices of Canada, with regional variances around the country. Modern Canadian cuisine has maintained this dedication to local ingredients and terroir, as exemplified in the naming of specific ingredients based on their locale, such as Malpeque oysters or Alberta beef.'),
  /* 3 */ Cuisine(
      name: 'Mediterranean',
      description:
          'Mediterranean cuisine is the food and methods of preparation used by the people of the Mediterranean Basin. The historical connections of the region, as well as the impact of the Mediterranean Sea on the region\'s climate and economy, mean that these cuisines share dishes beyond the core trio of oil, bread, and wine, such as roast lamb or mutton, meat stews with vegetables and tomato (for example, Spanish andrajos), vegetable stews (Provençal ratatouille, Spanish pisto, Italian ciambotta), and the salted cured fish roe, bottarga, found across the region.'),
  /* 4 */ Cuisine(
      name: 'French',
      description:
          'French cuisine (French: Cuisine française) consists of the cooking traditions and practices from France. Its cuisine has been influenced throughout the centuries by the many surrounding cultures of Spain, Italy, Switzerland, Germany and Belgium, in addition to its own food traditions on the long western coastlines of the Atlantic, the Mediterranean Sea, the Channel and inland. A meal often consists of three courses, hors d\'œuvre or entrée (introductory course, sometimes soup), plat principal (main course), fromage (cheese course) or dessert, sometimes with a salad offered before the cheese or dessert.'),
  /* 5 */ Cuisine(
      name: 'Japanese',
      description:
          'Japanese cuisine encompasses the regional and traditional foods of Japan, which have developed through centuries of political, economic, and social changes. The traditional cuisine of Japan (Japanese: washoku) is based on rice with miso soup and other dishes; there is an emphasis on seasonal ingredients. Seafood and vegetables are also deep-fried in a light batter, as tempura. Apart from rice, a staple includes noodles, such as soba and udon. Japan also has many simmered dishes, such as fish products in broth called oden, or beef in sukiyaki and nikujaga.'),
  /* 6 */ Cuisine(
      name: 'Italian',
      description:
          'Italian cuisine (Italian: Cucina italiana) is a Mediterranean cuisine consisting of the ingredients, recipes and cooking techniques developed across the Italian Peninsula since antiquity, and later spread around the world together with waves of Italian diaspora. The Mediterranean diet forms the basis of Italian cuisine, rich in pasta, fish, fruits and vegetables. Cheese, cold cuts and wine are central to Italian cuisine, and along with pizza and coffee (especially espresso) form part of Italian gastronomic culture.'),
  /* 7 */ Cuisine(
      name: 'American',
      description:
          'American cuisine consists of the cooking style and traditional dishes prepared in the United States. It has been significantly influenced by Europeans, indigenous Native Americans, Black Americans, Asians, Pacific Islanders, and many other cultures and traditions. While some of American cuisine is fusion cuisine, many regions in the United States have a specific regional cuisine. Several are deeply rooted in ethnic heritages, such as American Chinese, Cajun, New Mexican, Louisiana Creole, Pennsylvania Dutch, Soul food, Tex-Mex, and Tlingit.'),
  /* 8 */ Cuisine(
      name: 'Mexican',
      description:
          'Mexican cuisine consists of the cooking cuisines and traditions of the modern country of Mexico. Today\'s food staples are native to the land and include corn (maize), beans, squash, amaranth, chia, avocados, tomatoes, tomatillos, cacao, vanilla, agave, turkey, spirulina, sweet potato, cactus, and chili pepper. Its history over the centuries has resulted in regional cuisines based on local conditions, including Baja Med, Chiapas, Veracruz, Oaxacan, and the American cuisines of New Mexican and Tex-Mex.')
];

List<String> restaurantImages = [
  'restaurant0',
  'restaurant1',
  'restaurant2',
  'restaurant3',
  'restaurant4',
  'restaurant5',
];

class PopulateData {
  static void populateDataDialog(BuildContext context) {
    showDialog(context: context, builder: (dialogContext) => PopuplateDataDialog(dialogContext));
  }
}

class PopuplateDataDialog extends StatefulWidget {
  final BuildContext dialogContext;
  const PopuplateDataDialog(this.dialogContext, {super.key});

  @override
  State<PopuplateDataDialog> createState() => _PopuplateDataDialogState();
}

class _PopuplateDataDialogState extends State<PopuplateDataDialog> {
  bool populateRestaurants = false, populateReviews = false, populateFavourites = false;
  int userCount = 0;
  List<int> userDropdown = [];
  bool populatingData = false,
      populatingUsers = false,
      populatedUsers = false,
      populatingRestaurants = false,
      populatedRestaurants = false,
      populatingReviews = false,
      populatedReviews = false,
      populatingFavourites = false,
      populatedFavourites = false,
      populationComplete = false,
      populateAll = false;

  @override
  Widget build(BuildContext context) {
    if (userDropdown.isEmpty) {
      for (int i = (populateRestaurants || populateReviews || populateFavourites) ? 1 : 0;
          i <= users.length;
          i++) {
        userDropdown.add(i);
      }
    }

    return AlertDialog(
        title: const Text('Populate Data'),
        content: populatingData
            ? Column(children: [
                const Text('Populating data...'),
                if (!populationComplete) ...[
                  const PaddedWidget(multiplier: 2),
                  const CircularProgressIndicator()
                ],
                if (populatingUsers) ...[
                  const PaddedWidget(multiplier: 2),
                  Text(populatedUsers ? 'Users populated' : 'Poulating users...')
                ],
                if (populatingRestaurants) ...[
                  const PaddedWidget(),
                  Text(populatedRestaurants ? 'Restaurants populated' : 'Populating restaurants...')
                ],
                if (populatingReviews) ...[
                  const PaddedWidget(),
                  Text(populatedReviews ? 'Reviews populated' : 'Populating reviews...')
                ],
                if (populatingFavourites) ...[
                  const PaddedWidget(),
                  Text(populatedFavourites ? 'Favourites populated' : 'Populating favourites...')
                ],
                if (populationComplete) ...[
                  const PaddedWidget(multiplier: 2),
                  const Text('Population complete!', style: TextStyle(fontSize: 18))
                ]
              ])
            : SizedBox(
                height: 300.0,
                width: 300.0,
                child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Additional Users'),
                        DropdownButton(
                            items: userDropdown.map((int value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                            value: userCount,
                            onChanged: (updatedValue) => setState(() => userCount = updatedValue!))
                      ]),
                      _getDataRow('Restaurants', populateRestaurants,
                          (updatedValue) => setState(() => populateRestaurants = updatedValue)),
                      _getDataRow('Reviews', populateReviews,
                          (updatedValue) => setState(() => populateReviews = updatedValue)),
                      _getDataRow('Favourite Restaurants', populateFavourites,
                          (updatedValue) => setState(() => populateFavourites = updatedValue)),
                      const Divider(),
                      _getDataRow(
                          'Populate all',
                          populateAll,
                          (updatedValue) => setState(() {
                                populateAll = updatedValue;
                                userCount = userCount == 0 ? 1 : userCount;
                                populateRestaurants = updatedValue;
                                populateReviews = updatedValue;
                                populateFavourites = updatedValue;
                              }))
                    ])),
        actions: [
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: populatingData && !populationComplete
                      ? MaterialStateProperty.all<Color>(Colors.grey)
                      : null),
              onPressed: () {
                if (populatingData) {
                  if (populationComplete) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Data updated')));
                    Navigator.pop(widget.dialogContext);
                  }
                } else {
                  _populateData().then((success) {
                    if (!success) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Error updating data.')));
                      Navigator.pop(widget.dialogContext);
                    }
                  });
                }
              },
              child: populationComplete ? const Text('Finish') : const Text('Update'))
        ]);
  }

  Widget _getDataRow(String title, dynamic value, Function(dynamic) onChanged) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title),
      Checkbox(
        value: value,
        onChanged: (updatedValue) => onChanged(updatedValue!),
      )
    ]);
  }

  Future<bool> _populateData() async {
    setState(() => populatingData = true);
    List<Restaurant>? addedRestaurants;
    List<AppUser>? addedUsers;

    if (userCount != 0) {
      addedUsers = await _populateUsers();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: Constants.adminEmail, password: Constants.adminPassword);
    }
    addedUsers ??= (await FirebaseFirestore.instance
            .collection('users')
            .withConverter<AppUser>(
              fromFirestore: (snapshots, _) => AppUser.fromJson(snapshots.data()!, snapshots.id),
              toFirestore: (user, _) => user.toJson(),
            )
            .get())
        .docs
        .map((user) => user.data())
        .toList();
    for (AppUser user in addedUsers) {
      if (user.email == Constants.adminEmail) addedUsers.remove(user);
    }
    if (addedUsers.isEmpty) return false;

    if (populateRestaurants) addedRestaurants = await _populateRestaurants(addedUsers);
    addedRestaurants ??= (await FirebaseFirestore.instance
            .collection('restaurants')
            .withConverter<Restaurant>(
              fromFirestore: (snapshots, _) =>
                  Restaurant.fromJson(snapshots.data()!, id: snapshots.id),
              toFirestore: (restaurant, _) => restaurant.toJson(),
            )
            .get())
        .docs
        .map((user) => user.data())
        .toList();
    if (addedRestaurants.isEmpty) return false;

    if (populateReviews) await _populateReviews(addedUsers, addedRestaurants);
    if (populateFavourites) await _populateFavourites(addedUsers, addedRestaurants);
    setState(() {
      populationComplete = true;
    });
    return true;
  }

  Future<List<AppUser>?> _populateUsers() async {
    await _deleteDocs('users');

    try {
      log('Populating users', name: 'Populate data');
      setState(() {
        populatingUsers = true;
      });

      List<AppUser> addedUsers = [];
      int i = 0;
      while (i < userCount) {
        AppUser user = users[i];
        UserCredential result = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: user.email!, password: '$i$i$i$i$i$i');
        User? returnedUser = result.user;
        if (returnedUser != null) {
          user.dateJoined = DateTime.now().toIso8601String();
          user.authId = returnedUser.uid;

          await FirebaseFirestore.instance.collection('users').doc(user.id).set(user.toJson());
          addedUsers.add(user);
        }
        i++;
      }
      setState(() {
        populatedUsers = true;
      });
      return addedUsers;
    } catch (error) {
      log('Error populating users. Check that authenticated users have been deleted from Firebase Authentication Users list',
          error: error, name: 'PopulateData._populateUsers');
      if (kDebugMode) {
        print(error);
      }
    }
    return null;
  }

  Future<List<Restaurant>?> _populateRestaurants(List<AppUser> addedUsers) async {
    await _deleteDocs('restaurants');

    try {
      log('Populating restaurants', name: 'Populate data');
      setState(() {
        populatingRestaurants = true;
      });

      List<Restaurant> addedRestaurants = [];
      for (Restaurant restaurant in restaurants) {
        restaurant.usersFavourited = addedUsers.map((user) => user.id!).toList();
        /* int rand = math.Random().nextInt(restaurantImages.length);
        File file = File('${(await getTemporaryDirectory()).path}/${restaurantImages[rand - 1]}');
        (await FirebaseStorage.instance.ref().child('RestaurantPhotos').putFile(file)); */

        final updatedRestaurantResult = await (await FirebaseFirestore.instance
                .collection('restaurants')
                .add(restaurant.toJson()))
            .get();
        final updatedRestaurant = updatedRestaurantResult.data() as Map<String, dynamic>;
        addedRestaurants
            .add(Restaurant.fromJson(updatedRestaurant, id: updatedRestaurantResult.id));
      }

      setState(() {
        populatedRestaurants = true;
      });
      return addedRestaurants;
    } catch (error) {
      log('Error populating restaurants', error: error, name: 'PopulateData._populateRestaurants');
      if (kDebugMode) {
        print(error);
      }
    }
    return null;
  }

  Future<void> _populateReviews(List<AppUser> addedUsers, List<Restaurant> addedRestaurants) async {
    await _deleteDocs('reviews');
    List<Review> formattedReviews = [];

    try {
      log('Populating reviews', name: 'Populate data');
      setState(() {
        populatingReviews = true;
      });

      int reviewsPerUser = (reviews.length / addedUsers.length).round();
      int userIndex = 0, reviewCount = 0, restaurantCount = 0;
      for (Review review in reviews) {
        Review formattedReview = review;
        String time = DateTime.now().toIso8601String();
        review.dateCreated = time;
        review.dateUpdated = time;

        if (reviewCount == reviewsPerUser) {
          userIndex++;
          reviewCount = -1;
        }
        review.userId = addedUsers[userIndex].id;
        review.restaurant = addedRestaurants[restaurantCount];

        formattedReviews.add(formattedReview);

        restaurantCount == addedRestaurants.length - 1 ? restaurantCount = 0 : restaurantCount++;
        reviewCount++;
      }

      for (Review review in formattedReviews) {
        await FirebaseFirestore.instance.collection('reviews').add(review.toJson());
      }

      for (Restaurant restaurant in addedRestaurants) {
        if (restaurant.latestReview == null) {
          Review? latestReview = formattedReviews.firstWhere(
              (element) => element.restaurant?.id == restaurant.id,
              orElse: () => Review());
          if (latestReview.reviewScore != null) {
            latestReview.restaurant = null;
            restaurant.latestReview = latestReview;
            await FirebaseFirestore.instance
                .collection('restaurants')
                .doc(restaurant.id)
                .update({'latestReview': latestReview.toJson()});
          }
        }
      }

      setState(() {
        populatedReviews = true;
      });
    } catch (error) {
      log('Error populating reviews', error: error, name: 'PopulateData._populateReviews');
      if (kDebugMode) {
        print(error);
      }
    }
  }

  Future<void> _populateFavourites(
      List<AppUser> addedUsers, List<Restaurant> addedRestaurants) async {
    await _deleteDocs('favourite-restaurants');

    try {
      log('Populating favourites', name: 'Populate data');
      setState(() {
        populatingFavourites = true;
      });

      for (Restaurant restaurant in addedRestaurants) {
        List<String> userIndexes = [];
        for (int i = 0; i < 3; i++) {
          int index = math.Random().nextInt(addedUsers.length);
          if (!userIndexes.contains(addedUsers[index].id)) {
            userIndexes.add(addedUsers[index].id!);
          }
        }
        await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(restaurant.id)
            .update({'usersFavourited': userIndexes});
      }
      setState(() {
        populatedFavourites = true;
      });
    } catch (error) {
      log('Error populating favourites', error: error, name: 'PopulateData._populateFavourites');
      if (kDebugMode) {
        print(error);
      }
    }
  }

  Future<void> _deleteDocs(String collectionId) async {
    try {
      final collectionRef = await FirebaseFirestore.instance.collection(collectionId).get();
      for (DocumentSnapshot ds in collectionRef.docs) {
        if (collectionId == 'users' &&
            (ds.data() as Map<String, dynamic>)['email'] == Constants.adminEmail) {
          log('Preserving constant email', name: 'PopulateData._deleteDocs');
        } else {
          ds.reference.delete();
        }
      }
    } catch (error) {
      log('Error deleting documents', error: error, name: 'PopulateData._deleteDocs');
      if (kDebugMode) {
        print(error);
      }
    }
  }
}
