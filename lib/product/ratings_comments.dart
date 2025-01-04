import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuttuu_app/UI/product/all_texts.dart';
import 'package:tuttuu_app/UI/product/hiddenContainer.dart';
import 'package:tuttuu_app/product/CategoryDetailScreen.dart';
import 'package:tuttuu_app/product/ratings_comments_PageView.dart';
import '../UI/product/all_colors.dart';
import '../UI/product/all_sizes.dart';

class RatingsComments extends StatefulWidget {
  const RatingsComments({super.key, required this.receiverUserId, this.senderUserId = '', required this.isSender, required this.title, this.isUser = false, required this.hideReviewsProfile, required this.isOwner});
  final String receiverUserId;
  final String senderUserId;
  final bool isSender;
  final String title;
  final bool isUser;
  final bool hideReviewsProfile;
  final bool isOwner;
  @override
  State<RatingsComments> createState() => _RatingsCommentsState();
}


class _RatingsCommentsState extends State<RatingsComments> {

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

  Future<String> _getFullName(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc['hiddenReviewsProfile'] == false) {
        return userDoc.data()?['fullName'];
      } else {
        return '********';
      }
    } catch (e) {
      return 'Unknown User';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MainColors().fieldTitleColorL,
                ),
                overflow: TextOverflow.ellipsis,  // Taşan metin için '...' ekler
                maxLines: 2,  // Satır sayısını 1 ile sınırlar
              ),
            ),
            if(widget.hideReviewsProfile == false || widget.isOwner == true)
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RatingsCommentsPageView(
                        isUser: widget.isUser,
                        receiverUserId: widget.receiverUserId,
                        isSender: widget.isSender,
                        senderUserId: widget.senderUserId,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
        widget.hideReviewsProfile
        ? HiddenContainer(pageTitle: 'Hidden Reviews',assetImage: AppFeatures().hiddenReviews,)
        : StreamBuilder<QuerySnapshot>(
          stream: _getStreamBasedOnSenderStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  "No comments or ratings available.",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              );
            }

            final commentsData = snapshot.data!.docs;

            return SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: commentsData.length,
                itemBuilder: (context, index) {
                  final data = commentsData[index].data() as Map<String, dynamic>;

                  String userId = data['userId'] ?? 'Unknown User';
                  double rating = (data['rating'] ?? 0).toDouble();
                  String comment = data['comment'] ?? 'No comment provided';


                  return Container(
                    width: screenWidth * 0.8, // Kart genişliği
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
                            FutureBuilder<String>(
                              future: _getFullName(userId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Text(
                                    'Loading...',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: textSizes().ratingNameSurname,
                                    ),
                                  );
                                }
                                if (snapshot.hasError || !snapshot.hasData) {
                                  return Text(
                                    'Unknown User',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: textSizes().ratingNameSurname,
                                    ),
                                  );
                                }
                                return Text(
                                  snapshot.data!,
                                  style: TextStyle(
                                    color: MainColors().fieldLabelColorLighter,
                                    fontWeight: FontWeight.w400,
                                    fontSize: textSizes().ratingNameSurname,
                                  ),
                                );
                              },
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

                },
                separatorBuilder: (context, index) => SizedBox(width: 8),
              ),
            );
          },
        ),
      ],
    );
  }
}



