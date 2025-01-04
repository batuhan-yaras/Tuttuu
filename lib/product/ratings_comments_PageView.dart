import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tuttuu_app/UI/product/all_colors.dart';
import 'package:tuttuu_app/UI/product/all_sizes.dart';
import 'package:tuttuu_app/core/tagImportanceSaving.dart';

class RatingsCommentsPageView extends StatefulWidget {
  const RatingsCommentsPageView({super.key, required this.receiverUserId, this.senderUserId = '', required this.isSender, this.isUser = false});
  final String receiverUserId;
  final String senderUserId;
  final bool isSender;
  final bool isUser;
  @override
  State<RatingsCommentsPageView> createState() =>
      _RatingsCommentsPageviewState();
}
class _RatingsCommentsPageviewState extends State<RatingsCommentsPageView> {

  @override
  void initState() {
    fetchAverageRating();
    super.initState();
  }
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  void _showRatingDialog(BuildContext context) {
    double selectedRating = 0; // Yıldız seçimi için başlangıç değeri
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        double selectedRating = 0;
        TextEditingController commentController = TextEditingController();

        return AlertDialog(
          backgroundColor: MainColors().appBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Center(
            child: Text(
              "Rate and Comment",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: MainColors().fieldTitleColorL),
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Select Rating:",
                    style: TextStyle(
                        color: MainColors().fieldTitleColorL,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          size: 32,
                          color: index < selectedRating
                              ? Colors.amber
                              : Colors.grey.shade400,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            selectedRating = (index + 1).toDouble();
                          });
                        },
                      );
                    }),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Your Comment:",
                    style: TextStyle(
                        color: MainColors().fieldTitleColorL,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Write your comment here...",
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Popup'ı kapat
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: MainColors().fieldTitleColorL),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedRating < 1) {
                  // Eğer yıldız seçilmemişse uyarı göster
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please select at least 1 star.")),
                  );
                  return;
                }

                String comment = commentController.text.trim();
                Navigator.pop(context);

                if (currentUserId != null) {
                  try {
                    await FirebaseFirestore.instance.collection('ratingsAndComments').add({
                      'userId': currentUserId,
                      'receiverUserId': widget.receiverUserId,
                      'rating': selectedRating,
                      'comment': comment,
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Rating and Comment saved successfully!")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to save data: $e")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("User is not logged in.")),
                  );
                }
                await fetchAverageRating();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: MainColors().fieldTitleColorL),
              child: Text(
                "Submit",
                style: TextStyle(color: MainColors().appBackgroundColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, double>> calculateTotalRatings() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('ratingsAndComments')
          .where('receiverUserId', isEqualTo: widget.receiverUserId) // Kullanıcıya göre filtreleme
          .get();

      double totalRatings = 0;
      double totalCount = 0;

      for (var doc in querySnapshot.docs) {
        double rating = (doc['rating'] ?? 0).toDouble();
        totalRatings += rating;
        totalCount++;
      }

      return {'totalRatings': totalRatings, 'totalCount': totalCount};
    } catch (e) {
      print("Error calculating total ratings: $e");
      return {'totalRatings': 0, 'totalCount': 0};
    }
  }

  Future<void> fetchAverageRating() async {
    try {
      final result = await calculateTotalRatings();
      if (result['totalCount'] == 0) {
        setState(() {
          averageRating = null;
        });
      } else {
        setState(() {
          averageRating = (result['totalRatings']! / result['totalCount']!)!;
        });
      }
    } catch (e) {
      print("Error fetching average rating: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch average rating: $e")),
      );
    }
  }
  Future<double?> calculateOverallAverageRating() async {
    try {
      final result = await calculateTotalRatings();
      if (result['totalCount'] == 0) {
        return null;
      }
      return result['totalRatings']! / result['totalCount']!;
    } catch (e) {
      print("Error calculating average rating: $e");
      return null;
    }
  }
  Stream<double?> getAverageRatingStream() {
    return FirebaseFirestore.instance
        .collection('ratingsAndComments')
        .where('receiverUserId', isEqualTo: widget.receiverUserId)
        .snapshots()
        .map((snapshot) {
      double totalRatings = 0;
      int totalCount = 0;

      for (var doc in snapshot.docs) {
        double rating = (doc['rating'] ?? 0).toDouble();
        totalRatings += rating;
        totalCount++;
      }

      if (totalCount == 0) return null;
      return totalRatings / totalCount;
    });
  }


  double? averageRating;
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ratings and Comments',
          style: TextStyle(
            color: MainColors().fieldTitleColorL,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              StreamBuilder<double?>(
                stream: getAverageRatingStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }

                  double? averageRating = snapshot.data;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 60),
                      SizedBox(width: 10),
                      Text(
                        averageRating != null
                            ? averageRating.toStringAsFixed(1)
                            : '0 - 5',
                        style: TextStyle(
                          color: MainColors().fieldTitleColorL,
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 50),
              Container(
                height: screenHeight * 0.6,
                child: CommentsList(receiverUserId: widget.receiverUserId, isSender: widget.isSender,senderUserId: widget.senderUserId,),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: (currentUserId != widget.receiverUserId && widget.isUser == false)
          ? FloatingActionButton(
        backgroundColor: MainColors().fieldTitleColorL,
        elevation: 4,
        child: Icon(
          Icons.star,
          color: MainColors().appBackgroundColor,
        ),
        onPressed: () {
          _showRatingDialog(context);
        },
      )
          : null,
    );
  }

}

class CommentsList extends StatefulWidget {
  const CommentsList({super.key, required this.receiverUserId, this.senderUserId = '', required this.isSender});
  final String receiverUserId;
  final String senderUserId;
  final bool isSender;
  @override
  State<CommentsList> createState() => _CommentsListState();
}

class _CommentsListState extends State<CommentsList> {
  Future<String> _getFullName(String userId) async {
    try{
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc!['hiddenReviewsProfile'] == false) {
        return userDoc.data()?['fullName'];
      } else {
        return '********';
      }
    } catch(e){
      return 'Unknown User';
    }
  }

  Stream<QuerySnapshot> fetchRatings(){
    return FirebaseFirestore.instance
        .collection('ratingsAndComments')
        .where('receiverUserId', isEqualTo: widget.receiverUserId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  Stream<QuerySnapshot> fetchSenderRatings(){
    return FirebaseFirestore.instance
        .collection('ratingsAndComments')
        .where('userId', isEqualTo: widget.senderUserId)
        .orderBy('timestamp',descending: true)
        .snapshots();
  }
  Stream<QuerySnapshot> _getStreamBasedOnSenderStatus(){
    if (widget.isSender) {
      return fetchSenderRatings();
    } else {
      return fetchRatings();
    }
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getStreamBasedOnSenderStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "No comments or ratings yet.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        final commentsData = snapshot.data!.docs;

        return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: commentsData.length,
          itemBuilder: (context, index) {
            final data = commentsData[index].data() as Map<String, dynamic>;

            String userId = data['userId'] ?? 'Unknown User';
            double rating = (data['rating'] ?? 0).toDouble();
            String comment = data['comment'] ?? 'No comment provided';

            return FutureBuilder(future: _getFullName(userId), builder: (context, snapshot){
              String fullName = snapshot.data ?? 'Loading...';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Card(
                  color: MainColors().appBackgroundColor,
                  elevation: 4,
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(5, (index) {
                        return Icon(
                          Icons.star,
                          color: index < rating ? Colors.amber : Colors.grey, // Rating'e göre renk
                          size: textSizes().ratingStarSmall,
                        );
                      }),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          fullName,
                          style: TextStyle(
                            color: MainColors().fieldLabelColorLighter,
                            fontSize: textSizes().ratingNameSurname,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          comment,
                          style: TextStyle(
                            color: MainColors().fieldTitleColorL,
                            fontSize: textSizes().commentText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });


          },
        );
      },
    );
  }
}

