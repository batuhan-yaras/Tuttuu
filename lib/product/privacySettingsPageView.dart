import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuttuu_app/UI/product/all_colors.dart';
import 'package:tuttuu_app/UI/product/all_paddings.dart';
import 'package:tuttuu_app/settingsPageView.dart';

import '../UI/product/all_texts.dart';
import '../UI/product/title_settings.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool isHidden = false; // Switch'in başlangıç durumu
  bool isHiddenFavourite = false;
  User? currentUser = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    _loadHiddenReviewProfile();
    _loadHiddenFavouritesProfile();
  }

  // Firestore'dan kullanıcı verisini alıp, 'hiddenReviewsProfile' alanını güncelleyen fonksiyon
  Future<void> _loadHiddenReviewProfile() async {
    try {
      String userId = currentUser!.uid; // Gerçek kullanıcı ID'sini buraya ekleyin

      // Firestore'dan kullanıcının 'hiddenReviewsProfile' değerini alıyoruz
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        setState(() {
          isHidden = userDoc['hiddenReviewsProfile'] ?? false; // Varsayılan olarak false al
        });
      }
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  Future<void> _loadHiddenFavouritesProfile() async {
    try {
      String userId = currentUser!.uid; // Gerçek kullanıcı ID'sini buraya ekleyin

      // Firestore'dan kullanıcının 'hiddenReviewsProfile' değerini alıyoruz
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        setState(() {
          isHiddenFavourite = userDoc['hiddenFavouritesProfile'] ?? false;
        });
      }
    } catch (e) {
      print("Error loading Firestore data: $e");
    }
  }

  // Firestore'da 'hiddenReviewsProfile' değerini güncelleyen fonksiyon
  Future<void> _updateHiddenReviewProfile(bool value) async {
    try {
      String userId = currentUser!.uid; // Gerçek kullanıcı ID'sini buraya ekleyin

      // Firestore'da değeri güncelliyoruz
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'hiddenReviewsProfile': value,
      });
      // Durum güncelleme işlemi başarılı olursa UI'yi güncelliyoruz
      setState(() {
        isHidden = value;
      });
    } catch (e) {
      print("Error updating Firestore: $e");
    }
  }

  Future<void> _updateHiddenFavouriteProfile(bool value) async {
    try {
      String userId = currentUser!.uid; // Gerçek kullanıcı ID'sini buraya ekleyin

      // Firestore'da değeri güncelliyoruz
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'hiddenFavouritesProfile': value,
      });
      // Durum güncelleme işlemi başarılı olursa UI'yi güncelliyoruz
      setState(() {
        isHiddenFavourite = value;
      });
    } catch (e) {
      print("Error updating Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(AppFeatures().appNameLogo, height: 120,),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8,top: 40,bottom: 20),
              child: MainTitle('Gizlilik Ayarları', size: 20),
            ),
            ListTileWithCard(
              title: 'Favorilediğim dövmeler profilimde gösterilmesin.',
              showLeading: false,
              showSwitch: true,
              switchValue: isHiddenFavourite,
              onSwitchChanged: (bool value) {
                _updateHiddenFavouriteProfile(value);
              },
            ),
            SizedBox(height: 16,),
            ListTileWithCard(
              title: "Yaptığım yorumlar ve değerlendirmeler profilimde gösterilmesin.",
              showSubtitle: true,
              subtitleText: "Stüdyoya yaptığınız değerlendirmede isminiz anonim olacaktır.",
              showLeading: false,
              showSwitch: true,
              switchValue: isHidden,
              onSwitchChanged: (bool value) {
                _updateHiddenReviewProfile(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
