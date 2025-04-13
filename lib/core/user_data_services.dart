import 'package:cloud_firestore/cloud_firestore.dart';

class UserDataService {
  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return userDoc.data();
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return null;
  }

  Future<double> calculateAverageRating(String userId) async {
    double totalRatings = 0;
    int totalCount = 0;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('ratingsAndComments')
          .where('receiverUserId', isEqualTo: userId)
          .get();

      for (var doc in snapshot.docs) {
        double rating = (doc['rating'] ?? 0).toDouble();
        totalRatings += rating;
        totalCount++;
      }

      if (totalCount > 0) {
        return totalRatings / totalCount; // Ortalama puan
      }
    } catch (e) {
      print('Error calculating average rating: $e');
    }

    return 0.0; // Eğer hiç puan yoksa veya bir hata olursa
  }
}
