import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/application_state.dart';
import 'package:restaurant_app/ui/shared/custom_form.dart';
import 'package:restaurant_app/utils/containers.dart';
import 'package:restaurant_app/ui/shared/review_star_row.dart';

/// Builds a dialog that allows a user to enter a review for a [restaurant]
/// If an [existingReview] is found, then [update] is set to true, so that the
/// review is modified instead of created. [onUpdate] is called when the user
/// submits the review
class ReviewDialog extends StatefulWidget {
  final Restaurant restaurant;
  final Review? existingReview;
  late final bool update;
  final Function(Review?)? onUpdate;

  ReviewDialog(this.restaurant, {super.key, this.existingReview, this.onUpdate}) {
    update = existingReview != null;
  }

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  String? title, content;
  int? reviewScore;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Set initial values
    reviewScore ??= widget.existingReview?.reviewScore ?? 0;
    title ??= widget.existingReview?.title ?? '';
    content ??= widget.existingReview?.content ?? '';

    return Consumer<ApplicationState>(builder: (context, appState, _) {
      return AlertDialog(
          title: const Text('Leave a review'),
          content: Form(
              key: _formKey,
              child: Column(children: [
                ReviewStarRow(
                    onChanged: (value) => reviewScore = value.toInt(),
                    startingValue: widget.existingReview?.reviewScore),
                CustomForm(
                    hint: 'Title',
                    existingValue: widget.existingReview?.title,
                    onChanged: (value) => title = value),
                CustomForm(
                    hint: 'Content',
                    existingValue: widget.existingReview?.content,
                    onChanged: (value) => content = value)
              ])),
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && reviewScore != 0) {
                    final time = DateTime.now().toIso8601String();
                    Review review = Review(
                        id: widget.existingReview?.id,
                        title: title,
                        content: content,
                        reviewScore: reviewScore,
                        dateCreated: time,
                        dateUpdated: time,
                        userId: appState.user?.id,
                        restaurant: widget.restaurant,
                        newData: widget.existingReview == null);
                    if (review.isValid()) {
                      review.sendData().then((success) {
                        Navigator.pop(context);
                        if (success) {
                          if (widget.onUpdate != null) widget.onUpdate!(review);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(review.newData ? 'Review Added!' : 'Review Updated!'),
                          ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Error uploading data'),
                          ));
                        }
                      });
                    }
                  }
                },
                child: const Text('Submit'))
          ]);
    });
  }
}
