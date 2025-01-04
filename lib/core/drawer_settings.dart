import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tuttuu_app/FavouritePageView.dart';
import 'package:tuttuu_app/messagesPageView.dart';
import 'package:tuttuu_app/product/ratings_comments_PageView.dart';
import 'package:tuttuu_app/settingsPageView.dart';

import '../UI/product/all_colors.dart';
import '../UI/product/all_texts.dart';
import '../account_screen.dart';
import '../login_page.dart';
import '../recommendation_page.dart';
import 'gallery.dart';

class GeneralDrawer extends StatefulWidget {
  const GeneralDrawer({super.key});

  @override
  State<GeneralDrawer> createState() => _GeneralDrawerState();
}

class _GeneralDrawerState extends State<GeneralDrawer> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: MainColors().appBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: MainColors().appBackgroundColor,
            ),
            child: Image.asset(AppFeatures().appNameLogo, height: 150),
          ),
    GeneralListTile(text: ListTileItems().account, icon: Icons.person,onTap: (){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AccountScreen()),
      );},),
    GeneralListTile(text: ListTileItems().tattooModels,icon: Icons.brush, onTap: (){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ImagePortfolio()),
      );},),
    GeneralListTile(text: ListTileItems().favouriteModels,icon: Icons.favorite,onTap: (){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FavouritePageView(userId: currentUser!.uid)),
      );
    },),
    GeneralListTile(text: ListTileItems().tattooRecommendation,icon: Icons.recommend,onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RecommendationPage()),
      );
    },),
    GeneralListTile(text: ListTileItems().ratings,icon: Icons.star,onTap: (){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RatingsCommentsPageView(receiverUserId: currentUser!.uid,isSender: true,senderUserId: currentUser!.uid,)),
      );
    },),
    GeneralListTile(text: ListTileItems().chatScreen,icon: Icons.chat,onTap: (){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MessagesPageView(currentUserId: currentUser!.uid)),
      );
    },),
          GeneralListTile(text: ListTileItems().help,icon: Icons.help,),
    GeneralListTile(text: ListTileItems().rateTheApp,icon: Icons.thumb_up,),
          GeneralListTile(text: ListTileItems().settings,icon: Icons.settings,onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPageView()),
            );
          },),
    GeneralListTile(text: ListTileItems().logout,icon: Icons.logout,onTap: (){
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
      );
    },),
        ],
      ),
    );

  }

}


class GeneralListTile extends StatelessWidget {
  const GeneralListTile({super.key, required this.text, this.onTap, required this.icon});

  final String text;
  final onTap;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(text),
      leading: Icon(icon),
      onTap: onTap,
    );
  }
}

