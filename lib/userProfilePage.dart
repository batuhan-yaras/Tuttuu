import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tuttuu_app/FavouritePageView.dart';
import 'package:tuttuu_app/UI/product/all_colors.dart';
import 'package:tuttuu_app/UI/product/all_paddings.dart';
import 'package:tuttuu_app/UI/product/main_divider.dart';
import 'package:tuttuu_app/UI/product/pp_settings.dart';
import 'package:tuttuu_app/UI/product/title_settings.dart';
import 'package:tuttuu_app/core/artist_portfolio.dart';
import 'package:tuttuu_app/core/gallery.dart';
import 'package:tuttuu_app/core/image_services.dart';
import 'package:tuttuu_app/core/message_sender.dart';
import 'package:tuttuu_app/product/ImageViewScreen.dart';
import 'package:tuttuu_app/product/ProfilePageBase.dart';
import 'package:tuttuu_app/product/ratings_comments.dart';

import 'UI/product/all_texts.dart';
import 'core/user_data_services.dart';


class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key, required this.receiverUserId, required this.sendMessageFunction, required this.userId, required this.isOwner, this.isAppBar = false});
  final String userId;
  final String receiverUserId;
  final bool sendMessageFunction;
  final bool isOwner;
  final bool isAppBar;
  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}


bool isReviewsHiddenProfile = false;
bool isFavouritesHiddenProfile = false;

class _UserProfilePageState extends State<UserProfilePage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchIfReviewIsHidden();
    fetchIfFavouritesHidden();
  }

  Future<void> fetchIfFavouritesHidden() async {
    try{
      User? currentUser = FirebaseAuth.instance.currentUser;

      if(currentUser != null){
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            isFavouritesHiddenProfile = userDoc['hiddenFavouritesProfile'];
          });
        }
        print(isReviewsHiddenProfile);
      }


    } catch(e){
      print("Hata: $e");
    }
  }

  Future<void> fetchIfReviewIsHidden() async {
    try{
      User? currentUser = FirebaseAuth.instance.currentUser;

      if(currentUser != null){
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            isReviewsHiddenProfile = userDoc['hiddenReviewsProfile'];
          });
        }
        print(isReviewsHiddenProfile);
      }
    } catch (e) {
      print("Hata: $e");
    }
  }

  Future<void> fetchUserData() async {
    if (currentUser != null) {
      userData = await UserDataService().fetchUserData(widget.userId);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isAppBar == true
        ? AppBar(
        title: Image.asset(AppFeatures().appNameLogo, height: 120,),
      )
        : null,
      body: userData == null
        ? Center(child: CircularProgressIndicator(),)
        : Padding(padding: MainPaddings().appPadding,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(flex: 5,child: CircleAvatar(radius: 60,child: ProfilePicture(imageUrl: userData!['profilePictureUrl'],userName: userData!['fullName'],),)),
                  Expanded(
                    flex: 7,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MainTitle(userData!['fullName'],size: 24),
                            Text('${userData!['age']}',style: TextStyle(color: MainColors().fieldLabelColorLighter,fontSize: 16),),
                          ],
                        ),
                      ),
                  ),
                ],
              ),
              SizedBox(height: 40,),
              ProfileBasePage(userId: widget.userId, userData: userData).aboutMeShow(),
              FlexibleImageGrid(
                isPortfolio: false,
                showDeleteButton: widget.isOwner,
                showFloatingActionButton: widget.isOwner,
                userId: widget.userId,
                portfolioTitle: "${userData!['fullName']}'s Favourites",
                collectionName: 'favourites',
                isHiddenFavourite: isFavouritesHiddenProfile,
                isOwner: widget.isOwner,
              ),
              MainDivider(30),
              RatingsComments(
                receiverUserId: widget.userId,
                isSender: true,
                senderUserId: widget.userId,
                title: "${userData!['fullName']}'s Given Reviews",
                isUser: true,
                hideReviewsProfile: isReviewsHiddenProfile,
                isOwner: widget.isOwner,),
            ],
          ),
        ),
      ),
      floatingActionButton: (widget.sendMessageFunction)
       ? FloatingActionButton(
        backgroundColor: MainColors().fieldTitleColorL,
        child: Icon(
          Icons.message,
          color: MainColors().appBackgroundColor,
        ),
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MessageSender(receiverUserId: widget.receiverUserId, fullName: userData!['fullName'], imageUrl: userData!['profilePictureUrl']))
          );
        },
      ) : null,
    );
  }
}
