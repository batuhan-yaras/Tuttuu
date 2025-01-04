import 'package:flutter/material.dart';

import '../UI/core/button_theme.dart';
import '../UI/core/textField_theme.dart';
import '../UI/product/all_colors.dart';

class GeneralPopUp extends StatelessWidget {
  GeneralPopUp({
    super.key,
    required this.textTitle,
    required this.textSubtitle,
    required this.isTextField,
    this.invisibleTextFieldText = false,
    this.fieldInputType = TextInputType.text,
    this.maxLengthField = 20,
    this.labelTextField = '',
    this.buttonText = '',
    this.onPressed,
    this.textFieldController,
    this.isError = false, this.isButton = false, // Hata durumu ekledik
  });

  final String textTitle;
  final String textSubtitle;
  final bool isTextField;
  final bool invisibleTextFieldText;
  final TextInputType fieldInputType;
  final int maxLengthField;
  final String labelTextField;
  final String buttonText;
  final onPressed;
  final TextEditingController? textFieldController;
  final bool isError; // Hata durumu
  final bool isButton;

  @override
  Widget build(BuildContext context) {
    // Hata durumuna göre renkleri ayarlıyoruz
    final titleColor = isError ? Colors.red : MainColors().fieldTitleColorL;
    final subtitleColor = isError ? Colors.red.shade700 : MainColors().fieldLabelColorL;
    final backgroundColor = isError ? Colors.red.shade100 : MainColors().appBackgroundColor;

    return Container(
      child: AlertDialog(
        title: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            textTitle,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold, color: titleColor),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              textSubtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: subtitleColor),
            ),
            SizedBox(height: 6),
            if (isTextField)
              TextFieldStyles(
                invisibleBool: invisibleTextFieldText,
                fieldInputType: fieldInputType,
                maxLength: maxLengthField,
                labelText: labelTextField,
                controller: textFieldController,
              ),
            if (isButton)
              GeneralButtons(
                buttonText: buttonText,
                onPressed: onPressed,
              ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        backgroundColor: backgroundColor, // Hata durumunda farklı bir arka plan rengi
        elevation: 10.0,
      ),
    );
  }
}
