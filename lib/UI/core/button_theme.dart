import 'package:flutter/material.dart';
import 'package:tuttuu_app/UI/product/all_colors.dart';
import 'package:tuttuu_app/UI/product/all_paddings.dart';

class GeneralButtons extends StatelessWidget {
  const GeneralButtons(
      {super.key, this.fontSize = 15, this.height = 50, this.width = 210, this.onPressed, required this.buttonText});

  final double fontSize;
  final double height;
  final double width;
  final onPressed;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MainPaddings().mainButtonPadding,
      child: SizedBox(
        height: height,
        width: width,
        child: ElevatedButton(

          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
              elevation: 0.4,
              backgroundColor: MainColors().fieldTitleColorL,
              foregroundColor: MainColors().appBackgroundColor,
              textStyle: TextStyle(letterSpacing: 2, fontSize: fontSize, fontWeight: FontWeight.w600)),
          child: Text(buttonText,textAlign: TextAlign.center),
        ),
      ),
    );
  }


}
