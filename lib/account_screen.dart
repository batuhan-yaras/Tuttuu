import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tuttuu_app/UI/core/button_theme.dart';
import 'package:tuttuu_app/UI/product/all_colors.dart';
import 'package:tuttuu_app/UI/product/all_paddings.dart';
import 'package:tuttuu_app/UI/product/all_texts.dart';
import 'package:tuttuu_app/UI/product/pp_settings.dart';
import 'package:tuttuu_app/product/general_popup.dart';
import 'package:intl/intl.dart';
import 'mainAppPage.dart';

class AccountScreen extends StatefulWidget {

  @override
  State<AccountScreen> createState() => _AccountScreenState();

}

class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController aboutMeController = TextEditingController();
  User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  final ImagePicker _picker = ImagePicker();
  String imageUrl = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> deleteProfilePhoto() async {
    try {
      // Firestore'dan kullanıcı verisini al
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (userDoc.exists) {
        String? photoUrl = userDoc.data()?['profilePictureUrl'];

        if (photoUrl != null && photoUrl.isNotEmpty) {
          // Firestore'daki URL'yi sil
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .update({
            'profilePictureUrl': '',
          });

          // Firebase Storage'dan fotoğrafı sil
          String userFolderPath = 'profile_pictures/${currentUser!.uid}';
          final storageRef = FirebaseStorage.instance.ref().child(userFolderPath);

          final listResult = await storageRef.listAll();

          for (var item in listResult.items) {
            await item.delete(); // Fotoğrafı sil
          }

          // State'i güncelle
          setState(() {
            imageUrl = ''; // Profil fotoğrafını sıfırla
          });

        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    }
  }


  Future<void> changeProfilePhoto() async {
    try {
        deleteProfilePhoto();
        setState(() {
          imageUrl = ''; // State'i güncelle
        });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    }
  }

// Yeni fotoğraf yükleme
  Future<void> _pickAndUploadImage() async {
    setState(() {
      isLoading = true; // Yükleme başladığında isLoading'i true yapıyoruz
    });

    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      setState(() {
        isLoading = false; // Dosya seçilmezse isLoading'i false yapıyoruz
      });
      return;
    }

    changeProfilePhoto();

        // Yeni fotoğrafı Firebase Storage'a yükle
        final storageRef = FirebaseStorage.instance.ref().child(
            'profile_pictures/${currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = storageRef.putFile(File(pickedFile.path));
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // Firestore'a yeni URL'yi kaydet
        await FirebaseFirestore.instance.collection('users')
            .doc(currentUser!.uid)
            .update({
          'profilePictureUrl': downloadUrl,
        });

        setState(() {
          imageUrl = downloadUrl; // Yeni profil fotoğrafını state'e aktar
          isLoading = false; // Yükleme tamamlandı, isLoading'i false yap
        });
  }


  // Firestore'dan kullanıcı verilerini çekme
  Future<void> fetchUserData() async {
    try {
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            userData = userDoc.data() as Map<String, dynamic>;
            imageUrl = userData!['profilePictureUrl'];
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }



  // Hakkımda kısmı için düzenlenebilir widget
  Widget aboutMeSection() {
    bool isEditable = false;
    String savedAboutMeText = '';

    if (userData != null && userData!['aboutMe'] != null && userData!['aboutMe'] != '') {
      savedAboutMeText = userData!['aboutMe'];
      isEditable = false; // Eğer aboutMe varsa, düzenlenemez olarak başlasın
      aboutMeController.text = savedAboutMeText;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Me',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MainColors().fieldTitleColorL
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: aboutMeController,
          maxLines: 5,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MainColors().fieldTitleColorL),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MainColors().fieldTitleColorL, width: 2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            hintText: 'Write something about yourself...',
          ),
        ),
      ],
    );
  }
  String formatDate(Timestamp timestamp) {
    final DateTime date = timestamp.toDate(); // Firestore Timestamp'ten DateTime'e dönüştürme
    final DateFormat formatter = DateFormat('dd/MM/yyyy'); // İstenen format
    return formatter.format(date); // Formatlanmış tarih
  }
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AccountTexts().title),
        centerTitle: true,
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator()) // Veri yükleniyorsa spinner göster
          : SingleChildScrollView(
        padding: MainPaddings().appPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil Fotoğrafı
            Center(
              child: Stack(
                children: [
                  isLoading
                      ? CircleAvatar(child: CircularProgressIndicator(),radius: 60,) // Yükleme yapılıyorsa gösterilecek
                      : ProfilePicture(imageUrl: imageUrl,userName: userData!['fullName'],),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Are you sure?"),
                              content: Text("Do you really want to delete your profile photo?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                  child: Text("No"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    deleteProfilePhoto();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Yes"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: CircleAvatar(
                        backgroundColor: MainColors().errorContainer,
                        radius: 14,
                        child: Icon(
                          Icons.delete,
                          color: MainColors().errorColor,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        _pickAndUploadImage();
                      },
                      child: CircleAvatar(
                        backgroundColor: MainColors().fieldTitleColorL,
                        radius: 14,
                        child: Icon(
                          Icons.edit,
                          color: MainColors().appBackgroundColor,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            // Ad Soyad
            AccountInfoRow(
              icon: Icons.person,
              title: 'Name',
              value: userData!['fullName'] ?? 'Not available',
            ),
            SizedBox(height: 8),
            // Email
            AccountInfoRow(
              icon: Icons.email,
              title: 'Email',
              value: userData!['email'] ?? 'Not available',
            ),
            SizedBox(height: 8),
            // Telefon Numarası
            AccountInfoRow(
              icon: Icons.phone,
              title: 'Phone',
              value: "+90${userData!['phoneNumber']}" ?? 'Not available',
            ),
            SizedBox(height: 8),
            // Date of Birth
            AccountInfoRow(
              icon: Icons.cake,
              title: 'Date of Birth',
              value: formatDate(userData!['birth']) ?? 'Not available',
            ),
            SizedBox(height: 8),
            // Cinsiyet
            AccountInfoRow(
              icon: Icons.wc,
              title: 'Gender',
              value: userData!['gender'] ?? 'Not available',
            ),
            SizedBox(height: 30),
            // Hakkımda kısmı
            aboutMeSection(),
            SizedBox(height: 20),
            // Kaydet Butonu
            Center(
              child: GeneralButtons(
                onPressed: () async {
                  final userId = _auth.currentUser?.uid;
                  if (userId != null) {
                    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

                    try {
                      await userRef.update({
                        'aboutMe': aboutMeController.text.trim(),
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Bilgiler başarıyla kaydedildi!')),
                      );

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MainAppPage()),
                            (route) => false,
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Bir hata oluştu: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Kullanıcı oturumu bulunamadı.')),
                    );
                  }
                },
                buttonText: 'Save',
                height: 40,
                width: 160,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Edit yapmak için
// Bilgi Gösterim Alanı
class AccountInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool edit;
  final bool isName;
  AccountInfoRow({required this.icon, required this.title, required this.value, this.edit = false,this.isName = false,});

  final TextEditingController _nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: MainColors().fieldTitleColorL),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: MainColors().fieldTitleColorL),
              ),
              Text(
                value,
                style: TextStyle(
                    fontSize: 14,
                    color: MainColors().fieldLabelColorLighter),
              ),
            ],
          ),
        ),
        if(edit)
          IconButton(
              icon: Icon(Icons.edit,size: 16,),
              onPressed: (){
                showDialog(context: context, builder: (BuildContext context){
                  return GeneralPopUp(
                    textTitle: 'Change Your $title',
                    textSubtitle: 'Enter a new value for $title',
                    isTextField: true,
                    invisibleTextFieldText: false,
                    labelTextField: title,
                    maxLengthField: 40,
                    isButton: true,
                    buttonText: 'Change',
                    onPressed: (){
                      if(isName){

                      }

                    },
                  );
                });
              },
          ),
      ],
    );
  }
}
