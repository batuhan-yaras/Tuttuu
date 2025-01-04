import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tuttuu_app/UI/product/all_paddings.dart';
import 'package:tuttuu_app/UI/product/image_add_box.dart';
import 'package:tuttuu_app/UI/product/main_divider.dart';
import 'package:tuttuu_app/UI/product/title_settings.dart';
import 'package:tuttuu_app/core/user_data_services.dart';
import 'package:tuttuu_app/product/ratings_comments.dart';
import '../UI/product/all_colors.dart';
import 'ProfilePageBase.dart';

class ArtistProfilePage extends StatefulWidget {
  const ArtistProfilePage({super.key});

  @override
  State<ArtistProfilePage> createState() => _ArtistProfilePageState();
}

class _ArtistProfilePageState extends State<ArtistProfilePage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  double averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchRatings();
  }


  Future<void> fetchUserData() async {
    if (currentUser != null) {
      userData = await UserDataService().fetchUserData(currentUser!.uid);
      setState(() {});
    }
  }

  Future<void> fetchRatings() async {
    if (currentUser != null) {
      double rating = await UserDataService().calculateAverageRating(currentUser!.uid);
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
          : ProfileBasePage(userId: currentUser!.uid, userData: userData, isOwner: true),
    );
  }
}


