import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/app_theme.dart';
import 'package:restaurant_app/application_state.dart';
import 'package:restaurant_app/ui/shared/padded_widget.dart';
import 'package:restaurant_app/ui/shared/review_dialog.dart';
import 'package:restaurant_app/utils/constants.dart';
import 'package:restaurant_app/utils/containers.dart';
import 'package:restaurant_app/ui/shared/custom_scaffold.dart';
import 'package:restaurant_app/ui/shared/review_star_row.dart';
import 'package:restaurant_app/utils/functions.dart';

/// List for a given [restaurant]'s [reviews]
class ReviewList extends StatefulWidget {
  final List<Review> reviews;
  final Restaurant? restaurant;

  const ReviewList(this.reviews, {super.key, this.restaurant});

  @override
  State<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      widget.reviews.removeWhere((element) => !element.isValid());

      return CustomScaffold(
          title: Constants.reviewScreenTitle,
          body: SingleChildScrollView(
              child: Column(children: [
            if (appState.loggedIn &&
                widget.restaurant != null &&
                !(widget.reviews.any((review) => review.userId == appState.user?.id))) ...[
              const PaddedWidget(multiplier: 2),
              ElevatedButton(
                  onPressed: () => showDialog(
                      context: context,
                      builder: (context) => ReviewDialog(widget.restaurant!,
                          onUpdate: (addedReview) => setState(() {
                                if (addedReview != null) widget.reviews.add(addedReview);
                              }))),
                  child: const Text('Leave a review')),
              const PaddedWidget(multiplier: 2)
            ],
            _getInnerWidget()
          ])));
    });
  }

  /// Returns ListView of reviews
  Widget _getInnerWidget() {
    return widget.reviews.isEmpty
        ? const Center(child: Text('No reviews in list'))
        : ListView.builder(
            itemCount: widget.reviews.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => _reviewBuilder(context, index, widget.reviews[index]));
  }

  /// Builds list tile for a [review] at the given [index]
  Widget _reviewBuilder(BuildContext context, int index, Review review) {
    return Padding(
        padding: const EdgeInsets.all(8),
        child: ListTile(
            shape: const RoundedRectangleBorder(
                side: BorderSide(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.all(Radius.circular(16))),
            title: Text(widget.restaurant != null ? review.title! : review.restaurant!.name!,
                style: TextStyle(
                    fontSize: AppTheme.listTileSubtitleSize, fontWeight: FontWeight.bold)),
            subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.restaurant != null
                        ? [_getContentText(review), _getDateText(review)]
                        : [
                            Text(
                                '${review.restaurant?.location?.city}, ${review.restaurant?.location?.country}'),
                            _getDateText(review),
                            const PaddedWidget(),
                            _getContentText(review)
                          ])),
            trailing: Consumer<ApplicationState>(builder: (context, appState, _) {
              widget.reviews.removeWhere((element) => !element.isValid());

              return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                if (review.userId == appState.user?.id && widget.restaurant != null)
                  InkWell(
                      onTap: () => showDialog(
                          context: context,
                          builder: (context) => ReviewDialog(widget.restaurant!,
                                  existingReview: review, onUpdate: (updatedReview) {
                                if (updatedReview != null) {
                                  setState(() => widget.reviews[index] = updatedReview);
                                }
                              })),
                      child: const Icon(Icons.edit, color: Colors.black, size: 20)),
                if (review.reviewScore != null) ...[
                  const PaddedWidget(multiplier: 0.5),
                  Expanded(
                      child: ReviewStarRow(
                    shrink: true,
                    enabled: false,
                    startingValue: review.reviewScore!,
                  ))
                ]
              ]);
            })));
  }

  /// Returns a formatted date string based on a given [review]
  Widget _getDateText(Review review) {
    return Text('Posted: ${Functions.getDateString(review.dateUpdated!)}',
        style: TextStyle(fontStyle: FontStyle.italic, fontSize: AppTheme.listTileItalicsSize));
  }

  /// Returns formatted content text for a given [review]
  Widget _getContentText(Review review) {
    return Text(review.content!, style: TextStyle(fontSize: AppTheme.listTileSubtitleSize));
  }
}
