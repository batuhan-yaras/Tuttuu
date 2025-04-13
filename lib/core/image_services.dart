import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // İzin isteme fonksiyonu
  Future<bool> requestPermission() async {
    var cameraStatus = await Permission.camera.request();
    return cameraStatus.isGranted;
  }

  Future<void> addFavouritePhotos(String userId, String photoUrl) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('favourites').doc(userId);

      await userDoc.set({
        'photos': FieldValue.arrayUnion([photoUrl]),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Favorilere ekleme hatası: $e');
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Favori fotoğrafları kontrol et
  Future<bool> isPhotoInFavourites(String userId, String imagePath) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('favourites').doc(userId).get();
      if (!snapshot.exists) return false;

      List<dynamic> photos = snapshot['photos'] ?? [];
      return photos.contains(imagePath);
    } catch (e) {
      print('Error checking if photo is in favourites: $e');
      return false;
    }
  }

  // Favorilere ekle veya çıkar
  Future<void> toggleFavouritePhoto(String userId, String imagePath) async {
    try {
      DocumentReference docRef = _firestore.collection('favourites').doc(userId);

      DocumentSnapshot snapshot = await docRef.get();
      if (!snapshot.exists) {
        // Kullanıcı için favoriler dokümanı oluştur
        await docRef.set({
          'userId': userId,
          'photos': [imagePath],
        });
        return;
      }

      List<dynamic> photos = snapshot['photos'] ?? [];

      if (photos.contains(imagePath)) {
        // Fotoğrafı favorilerden çıkar
        photos.remove(imagePath);
      } else {
        // Fotoğrafı favorilere ekle
        photos.add(imagePath);
      }

      // Güncellenmiş fotoğraf listesini kaydet
      await docRef.update({'photos': photos});
    } catch (e) {
      print('Error toggling favourite photo: $e');
    }
  }

  // Kullanıcının favori fotoğraflarını al
  Stream<List<String>> getFavouritePhotos(String userId) {
    try {
      // Firestore'dan verileri dinliyoruz
      return _firestore
          .collection('favourites')
          .doc(userId)
          .snapshots() // Bu, dokümanda yapılan her değişiklikte stream tetiklenir
          .map((snapshot) {
        if (!snapshot.exists) return []; // Eğer doküman yoksa boş liste döner

        List<dynamic> photos = snapshot['photos'] ?? [];
        return List<String>.from(photos.reversed); // Verileri String listesine dönüştürüp döndürüyoruz
      });
    } catch (e) {
      print('Error fetching favourite photos: $e');
      return Stream.value([]); // Hata durumunda boş bir stream döner
    }
  }

  Future<List<String>> fetchUserImages({required String tag, required String userId}) async {
    // Firestore'dan kullanıcının görsellerini al
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('userImages')
        .where('userId', isEqualTo: userId)
        .where('tags', arrayContains: tag)
        .get();

    // Görsel URL'lerini döndür
    return snapshot.docs.map((doc) => doc['url'] as String).toList();
  }

  // Fotoğrafları cihazdan seçme fonksiyonu
  Future<List<File>> pickImages(BuildContext context) async {
    bool permissionGranted = await requestPermission(); // Önce izinleri al

    if (permissionGranted) {
      try {
        final pickedFiles = await _picker.pickMultiImage();
        return pickedFiles.map((pickedFile) => File(pickedFile.path)).toList(); // Seçilen fotoğrafları listeye ekle
      } catch (e) {
        print('Error occurred while picking images: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred while picking images: ${e.toString()}')),
        );
      }
    } else {
      print('Permissions not granted');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissions not granted')),
      );
    }

    return []; // Eğer bir şey seçilmediyse boş liste döndür
  }

  Future<List<String>> uploadImages(BuildContext context, List<File> images, String userId, List<String> tags,
      String directory, bool isTattoo) async {
    List<String> downloadUrls = [];

    if (images.isNotEmpty) {
      try {
        for (int i = 0; i < images.length; i++) {
          final image = images[i];

          // Benzersiz dosya adı oluşturma
          String fileName = '$directory/$userId/${DateTime.now().millisecondsSinceEpoch}_$i.png';
          final storageRef = FirebaseStorage.instance.ref().child(fileName);

          try {
            // Görseli Firebase Storage'a yükleme
            UploadTask uploadTask = storageRef.putFile(image);
            final snapshot = await uploadTask.whenComplete(() {});
            String downloadUrl = await snapshot.ref.getDownloadURL();
            downloadUrls.add(downloadUrl);

            if (isTattoo == true) {
              await FirebaseFirestore.instance.collection('tattoos').add({
                'url': downloadUrl,
                'userId': userId,
                'tags': tags,
                'timestamp': FieldValue.serverTimestamp(),
              });
            } else {
              // Firebase Firestore'a kayıt ekleme
              await FirebaseFirestore.instance.collection('userImages').add({
                'url': downloadUrl,
                'userId': userId,
                'tags': tags,
                'timestamp': FieldValue.serverTimestamp(),
              });
            }
          } catch (e) {
            print('Error uploading image $i: ${e.toString()}');
          }
        }

        // Başarı mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All images uploaded successfully!')),
        );
      } catch (e) {
        print('General error occurred: ${e.toString()}');
      }
    } else {
      // Görsel seçilmediğinde kullanıcıyı bilgilendir
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images selected to upload.')),
      );
    }

    return downloadUrls; // Yüklenen tüm görsellerin URL'lerini döndür
  }

  Future<void> deleteImageFromStorage(String imageUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image from storage: $e');
    }
  }
}
