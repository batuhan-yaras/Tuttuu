import 'package:flutter/material.dart';
import 'package:tuttuu_app/UI/product/all_paddings.dart';
import 'package:tuttuu_app/UI/product/all_texts.dart';
import 'package:tuttuu_app/UI/product/image_add_box.dart';
import 'package:tuttuu_app/UI/product/pp_settings.dart';
import 'package:tuttuu_app/core/artist_portfolio.dart';
import 'package:tuttuu_app/product/ratings_comments.dart';
import '../UI/product/all_colors.dart';
import '../UI/product/main_divider.dart';

class ProfileBasePage extends StatelessWidget {
  final String? userId;
  final Map<String, dynamic>? userData;
  final bool isOwner;

  const ProfileBasePage({
    Key? key,
    required this.userId,
    required this.userData,
    this.isOwner = false,
  }) : super(key: key);

  Widget profilePhotoAndAboutMe(){
    return Row(
      children: [
        ProfilePicture(imageUrl: userData!['profilePictureUrl'],userName: userData!['fullName'],),
        SizedBox(width: 20,),
      ],
    );
  }

  Widget aboutMeShow() {
    if (userData != null && userData!['aboutMe'] != null && userData!['aboutMe'] != '') {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if(userData!['isTattooArtist'] == true)
                profilePhotoAndAboutMe(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ProfileTexts().aboutMe,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: MainColors().fieldTitleColorL),
                    ),
                    SizedBox(height: 8),
                    Text(
                      userData!['aboutMe'],
                      style: TextStyle(fontSize: 14, color: MainColors().fieldTitleColorL),
                    ),
                  ],
                ),
              ),
            ],
          ),
          MainDivider(40),
        ],
      );
    } else {
      return MainDivider(40);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MainPaddings().appPadding,
      child: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageAddBox(
                  pageOwner: isOwner,
                  userId: userId!,
                  showDeleteButton: isOwner),
              aboutMeShow(),
              FlexibleImageGrid(
                  isPortfolio: true,
                  tag: 'portfolio',
                  showDeleteButton: isOwner,
                  showFloatingActionButton: isOwner,
                  userId: userId!,
                  isOwner: isOwner,
              ),
              MainDivider(40),
              RatingsComments(receiverUserId: userId!,isSender: false,title: ProfileTexts().ratingAndComments,hideReviewsProfile: false, isOwner: isOwner,),
            ],
          ),
        ],
      ),
    );
  }
}
