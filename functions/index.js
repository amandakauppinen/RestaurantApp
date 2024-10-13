// The Cloud Functions for Firebase SDK to create Cloud Functions and set up triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access Firestore.
const admin = require('firebase-admin');
admin.initializeApp();

exports.updatelatestReview = functions.firestore.document('/reviews/{documentId}').onWrite(async (snapshot) => {
    const db = admin.firestore();

    let review = snapshot.after.data();
    return db.runTransaction(async transaction => {
        const restaurantPath = db.collection('restaurants').doc(review.restaurantInfo.id);
        const restaurantSnap = await transaction.get(restaurantPath);
        const restaurantData = restaurantSnap.data();
        if(restaurantData) {
            let reviewCount = (restaurantData.reviewCount == undefined || restaurantData.reviewCount == 0) ? 1 : restaurantData.reviewCount + 1;
            let averageReviewScore = reviewCount == 1 ? review.reviewScore : getAverage(restaurantData.averageReviewScore == undefined ? 0 : restaurantData.averageReviewScore, reviewCount, review.reviewScore);
            let changes = {};
            changes['reviewCount'] = reviewCount;
            changes['latestReview'] = review;
            changes['averageReviewScore'] = averageReviewScore;
            transaction.update(restaurantPath, changes);
        }
    })
});

function getAverage (average, count, newScore) {
    average -= average / count;
    average += newScore / count;
    
    return average;
}

