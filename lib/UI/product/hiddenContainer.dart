import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tuttuu_app/UI/product/all_colors.dart';
import 'package:tuttuu_app/UI/product/title_settings.dart';

class HiddenContainer extends StatelessWidget {
  const HiddenContainer({super.key, required this.pageTitle, required this.assetImage});
final String pageTitle;
final String assetImage;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SizedBox(
        height: 150,
        child: Stack(
          children: [
          Image.asset(assetImage,fit: BoxFit.cover,height: 150,width: screenWidth,),
          Center(child: Container(color: Colors.black26,child: Align(alignment: Alignment.center,child: MainTitle(pageTitle)),width: double.maxFinite,height: 30,))
          ],
        ),
      ),
    );
  }
}
