import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'all_colors.dart';

Widget MainTitle(String pageTitle, {double size = 18}){
  return Text(
    pageTitle,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: MainColors().fieldTitleColorL,
      letterSpacing: 1.2,
    ),
  );
}