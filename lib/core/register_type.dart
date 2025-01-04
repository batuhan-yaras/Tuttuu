import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tuttuu_app/login_page.dart';
import 'package:tuttuu_app/product/general_popup.dart';

void registerUser(
    context,
    String email,
    String password,
    bool isTattooArtist,
    Function(bool) onUsedEmail,
    Function(bool) onWeakPassword,
    Function(bool) onInvalidEmail
    ) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    // Kullanıcıyı Firestore'a kaydetme
    await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
      'email': email,
      'isTattooArtist': isTattooArtist,
      if (isTattooArtist) 'studioLocation': null,
      if(isTattooArtist == false) 'hiddenReviewsProfile' : false,
      if(isTattooArtist == false) 'hiddenFavouritesProfile' : false,
      'profilePictureUrl': '',

    });

    User? user = userCredential.user;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      print('Doğrulama emaili gönderildi.');
    }

    showDialog(
        context: context,
        builder: (BuildContext context){
          return GeneralPopUp(
              textTitle: 'Verification Link Sent.',
              textSubtitle: 'You need to verify your E-mail Address to login.',
              isTextField: false,
              isButton: true,
              buttonText: 'Login',
              onPressed: (){
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                );
              },
          );
        });

    print('Kullanıcı başarıyla kaydedildi. TattooArtist: $isTattooArtist');
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      onUsedEmail(true);  // Email zaten kullanılıyor
      print('Email already in use.');
    } else if (e.code == 'weak-password') {
      onWeakPassword(true);  // Zayıf şifre hatası
      print('Şifre çok zayıf.');
    } else if (e.code == 'invalid-email') {
      onInvalidEmail(true);  // Geçersiz email hatası
      print('Geçersiz e-posta adresi.');
    } else {
      print('Firebase Auth Hatası: ${e.message}');
    }
  } catch (e) {
    print('Beklenmeyen bir hata oluştu: $e');
  }
}
