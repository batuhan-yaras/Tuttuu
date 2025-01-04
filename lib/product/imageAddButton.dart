import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../UI/product/all_colors.dart';
import '../core/image_services.dart';

class ImageAddButton extends StatelessWidget {
   ImageAddButton({super.key, required imageURLList, required this.userID, this.onPressed});

  ImageService imageservices = ImageService();

  final String userID;
  late List imageURLList;

  final onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add),
      color: MainColors().appBackgroundColor,
      onPressed: onPressed,
    );
  }
}
