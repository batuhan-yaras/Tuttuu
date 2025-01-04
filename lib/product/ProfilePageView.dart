import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tuttuu_app/core/message_sender.dart';
import '../UI/product/all_colors.dart';
import '../UI/product/all_texts.dart';
import '../UI/product/title_settings.dart';
import '../core/user_data_services.dart';
import 'ProfilePageBase.dart';

class ProfilePageView extends StatefulWidget {
  const ProfilePageView({super.key, required this.studioId, this.showFloatingButton = true});
  final String studioId;
  final bool showFloatingButton;

  @override
  State<ProfilePageView> createState() => _ProfilePageViewState();
}

class _ProfilePageViewState extends State<ProfilePageView> {
  String? userId;
  Map<String, dynamic>? userData;
  double averageRating = 0.0;
  User? currentUser = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('studioId', isEqualTo: widget.studioId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      userId = snapshot.docs.first.id;
      userData = await UserDataService().fetchUserData(userId!);
      setState(() {});
      double rating = await UserDataService().calculateAverageRating(userId!);
      setState(() {
        averageRating = rating;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: userData == null
            ? Text('Loading...')
            : MainTitle(userData!['fullName'], size: 22),
        actions: [
          averageRating != 0
              ? Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                            children: [
                Icon(Icons.star, color: Colors.amber, size: 26),
                SizedBox(width: 4),
                Text(
                  averageRating.toStringAsFixed(1),
                  style: TextStyle(
                    color: MainColors().fieldTitleColorL,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                            ],
                          ),
              )
              : SizedBox.shrink(),
        ],
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : ProfileBasePage(userId: userId!, userData: userData, isOwner: false),
      floatingActionButton: (userData != null && currentUser != null && userId != null && currentUser!.uid != userId && widget.showFloatingButton == true)
          ? FloatingActionButton(
        backgroundColor: MainColors().fieldTitleColorL,
        elevation: 4,
        child: Icon(
          Icons.message,
          color: MainColors().appBackgroundColor,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MessageSender(
                receiverUserId: userId!,
                fullName: userData!['fullName'],
                imageUrl: userData!['profilePictureUrl'],
              ),
            ),
          );
        },
      )
          : null,
    );
  }
}

