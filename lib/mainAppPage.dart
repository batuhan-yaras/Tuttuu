import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuttuu_app/FavouritePageView.dart';
import 'package:tuttuu_app/core/message_sender.dart';
import 'package:tuttuu_app/core/gallery.dart';
import 'package:tuttuu_app/UI/product/all_colors.dart';
import 'package:tuttuu_app/UI/product/all_paddings.dart';
import 'package:tuttuu_app/UI/product/all_texts.dart';
import 'package:tuttuu_app/UI/product/artist_Q_page.dart';
import 'package:tuttuu_app/core/drawer_settings.dart';
import 'package:tuttuu_app/core/image_services.dart';
import 'package:tuttuu_app/login_page.dart';
import 'package:tuttuu_app/map_screen.dart';
import 'package:tuttuu_app/messagesPageView.dart';
import 'package:tuttuu_app/product/CategoryDetailScreen.dart';
import 'package:tuttuu_app/product/ProfilePageView.dart';
import 'package:tuttuu_app/product/artistProfilePage.dart';
import 'package:tuttuu_app/recommendation_page.dart';
import 'package:tuttuu_app/account_screen.dart';
import 'package:tuttuu_app/signup_page.dart';
import 'package:tuttuu_app/userProfilePage.dart';



class MainAppPage extends StatefulWidget {
  const MainAppPage({super.key});

  @override
  State<MainAppPage> createState() => _MainAppPageState();
}
class _MainAppPageState extends State<MainAppPage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    fetchIsTattooArtist();
    fetchUserPhotos();
  }


  Future<void> fetchIsTattooArtist() async {
    try {
      // Firebase Authentication'dan mevcut kullanıcıyı al
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Kullanıcının Firestore'daki dökümanını çek
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        // Eğer döküman mevcutsa isTattooArtist alanını al
        if (userDoc.exists) {
          setState(() {
            isTattooArtist = userDoc['isTattooArtist'];
          });
        }
      }
    } catch (e) {
      print("Hata: $e");
    }
  }
  List<String> userPhotos = []; // Kullanıcı fotoğraflarını saklamak için bir liste

  Future<void> fetchUserPhotos() async {
    try {
      // Firebase Authentication'dan mevcut kullanıcıyı al
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Kullanıcının Firestore'daki dökümanını çek
        QuerySnapshot userPhotosSnapshot = await FirebaseFirestore.instance
            .collection('userImages')
            .where('userId', isEqualTo: currentUser.uid)
            .get();

        // Alınan dökümanları listeye ekle
        userPhotos = userPhotosSnapshot.docs
            .map((doc) => doc['url'] as String)
            .toList();

        // Ekranı güncelle
        setState(() {});
      }
    } catch (e) {
      print("Hata: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return  DefaultTabController(
      length: 5,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: MainColors().appBackgroundColor,
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.menu,color: MainColors().fieldTitleColorL,),
                onPressed: () {
                  Scaffold.of(context).openDrawer(); // Doğru context burada
                },
              );
            },
          ),
          title: Image.asset(AppFeatures().appNameLogo, height: 120,),
        ),
        drawer: const GeneralDrawer(),

        bottomNavigationBar: BottomAppBar(
          color: MainColors().appBackgroundColor,
          child:  TabBar(
            indicatorColor: MainColors().fieldTitleColorL,
            labelColor: MainColors().fieldTitleColorL,
            unselectedLabelColor: MainColors().fieldLabelColorLighter,
            tabs: const [
              Tab(icon: Icon(Icons.person)),
              Tab(icon: Icon(Icons.brush)),
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.favorite)),
              Tab(icon: Icon(Icons.chat)),
            ],
          ),
        ),
        body: TabBarView(children: [
          isTattooArtist == true
          ? const ArtistProfilePage()
          : UserProfilePage(receiverUserId: currentUser!.uid,sendMessageFunction: false,userId: currentUser!.uid,isOwner: true,),
          const ImagePortfolio(),
          const MapScreen(),
          FavouritePageView(userId: currentUser!.uid),
          MessagesPageView(currentUserId: currentUser!.uid,),
        ]),
      ),
    );
  }

}

