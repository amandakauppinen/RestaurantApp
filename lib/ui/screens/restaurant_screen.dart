import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_app/app_theme.dart';
import 'package:restaurant_app/ui/screens/review_list.dart';
import 'package:restaurant_app/ui/shared/padded_divider.dart';
import 'package:restaurant_app/ui/shared/padded_widget.dart';
import 'package:restaurant_app/utils/containers.dart';
import 'package:restaurant_app/ui/shared/custom_scaffold.dart';
import 'package:restaurant_app/ui/shared/review_star_row.dart';
import 'package:restaurant_app/utils/functions.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

/// Container showing all relevant info for a given [restaurant]
class RestaurantScreen extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantScreen(this.restaurant, {super.key});

  @override
  Widget build(BuildContext context) {
    GeoPoint? coordinates;
    try {
      coordinates = restaurant.location?.coordinates;
    } catch (error) {
      log('Error setting coordinates', error: error, name: 'RestaurantScreen.build');
    }

    return CustomScaffold(
        body: coordinates != null
            ? SlidingUpPanel(
                defaultPanelState: PanelState.OPEN,
                backdropEnabled: true,
                panel: _getPageContent(context))
            : _getPageContent(context));
  }

  /// Returns all page content
  Widget _getPageContent(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(children: [
          const Align(alignment: Alignment.center, child: Icon(Icons.drag_handle)),
          const PaddedWidget(),
          Align(
              alignment: Alignment.center,
              child:
                  Text(restaurant.name!, style: TextStyle(fontSize: AppTheme.listTileTitleSize))),
          if (restaurant.averageReviewScore != null) ...[
            Align(
                alignment: Alignment.center,
                child: ReviewStarRow(
                    enabled: false,
                    shrink: true,
                    startingValue: restaurant.averageReviewScore,
                    iconSize: 24)),
            const PaddedWidget(multiplier: 2)
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child:
                      Text('Details:', style: TextStyle(fontSize: AppTheme.listTileSubtitleSize)),
                ),
                const Text('Location', style: TextStyle(fontSize: 16)),
                Text(restaurant.getLocationString(excludeProvince: false),
                    style: const TextStyle(fontSize: 14)),
                if (restaurant.dateOpened != null) ...[
                  Row(children: [
                    const Text('Established'),
                    Text(Functions.getDateString(restaurant.dateOpened))
                  ]),
                  const PaddedDivider()
                ],
              ]),
              if (restaurant.imagePath != null)
                FutureBuilder(
                    future: FirebaseStorage.instance
                        .ref()
                        .child(restaurant.imagePath!)
                        .getDownloadURL(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        log('Error loading image',
                            error: snapshot.error, name: 'RestaurantScreen.build');
                        return const CircularProgressIndicator();
                      } else if (snapshot.data != null && snapshot.hasData) {
                        double imageSize = MediaQuery.of(context).size.width / 3;
                        return SizedBox(
                            height: imageSize,
                            width: imageSize,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(snapshot.data!),
                            ));
                      } else {
                        return const CircularProgressIndicator();
                      }
                    })
            ],
          ),
          const PaddedDivider(),
          const PaddedWidget(),
          Text('Latest Review', style: TextStyle(fontSize: AppTheme.listTileSubtitleSize)),
          if (restaurant.latestReview != null)
            ListTile(
                shape: const RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                title: Text(restaurant.latestReview!.title!,
                    style: TextStyle(
                        fontSize: AppTheme.listTileSubtitleSize, fontWeight: FontWeight.bold)),
                subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(restaurant.latestReview!.content!,
                          style: TextStyle(fontSize: AppTheme.listTileSubtitleSize)),
                      Text(
                          'Posted: ${Functions.getDateString(restaurant.latestReview!.dateUpdated!)}',
                          style: TextStyle(
                              fontStyle: FontStyle.italic, fontSize: AppTheme.listTileItalicsSize)),
                      const PaddedWidget(multiplier: 2),
                    ])),
                trailing: restaurant.latestReview!.reviewScore != null
                    ? ReviewStarRow(
                        shrink: true,
                        enabled: false,
                        startingValue: restaurant.latestReview!.reviewScore!,
                      )
                    : null),
          ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('reviews')
                    .where('restaurantInfo.id', isEqualTo: restaurant.id)
                    .withConverter<Review>(
                      fromFirestore: (snapshots, _) =>
                          Review.fromJson(snapshots.data()!, id: snapshots.id),
                      toFirestore: (review, _) => review.toJson(),
                    )
                    .get()
                    .then((reviews) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ReviewList(
                            reviews.docs.map((review) => review.data()).toList(),
                            restaurant: restaurant,
                          )));
                });
              },
              child: Text(restaurant.latestReview != null ? 'View More' : 'See Reviews'))
        ]));
  }
}
