import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuttuu_app/UI/product/image_add_box.dart';
import 'package:tuttuu_app/UI/product/title_settings.dart';
import 'package:tuttuu_app/core/image_services.dart';

import '../product/all_colors.dart';
import '../product/all_texts.dart';
import '../product/pp_settings.dart';

class StudioPopUp extends StatefulWidget {
  StudioPopUp({
    super.key,
    required this.fullName,
    required this.userId,
    required this.userData,
    required this.aboutMe,
    this.onPressed,
    required this.averageRating,
  });

  final String? userId;
  final Map<String, dynamic>? userData;
  final String fullName;
  final String aboutMe;
  final VoidCallback? onPressed;
  final double averageRating;

  @override
  State<StudioPopUp> createState() => _StudioPopUpState();
}

class _StudioPopUpState extends State<StudioPopUp> {
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    fetchUserImages();
  }

  Future<void> fetchUserImages() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('userImages')
          .where('userId', isEqualTo: widget.userId)
          .get();

      setState(() {
        imageUrls = querySnapshot.docs
            .map((doc) => doc['url'] as String)
            .toList();
      });
    } catch (e) {
      print('Error fetching user images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: MainColors().appBackgroundColor,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          imageUrls.isNotEmpty
              ? Image.network(imageUrls.first,fit: BoxFit.cover,height: 200,width: double.maxFinite,)
              : CircularProgressIndicator(),
          SizedBox(height: 14),
          MainTitle(widget.fullName, size: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 20),
              SizedBox(width: 4),
              Text(
                widget.averageRating.toStringAsFixed(1),
                style: TextStyle(
                  color: MainColors().fieldTitleColorL,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Text(
          widget.aboutMe,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: MainColors().fieldTitleColorL,
            fontSize: 14,
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Kapatmak için
          },
          child: Text(
            'Cancel',
            style: TextStyle(color: MainColors().fieldLabelColorLighter),
          ),
        ),
        TextButton(
          onPressed: widget.onPressed,
          child: Text(
            'Profile',
            style: TextStyle(color: MainColors().fieldTitleColorL),
          ),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}
