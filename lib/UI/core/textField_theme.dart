import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuttuu_app/UI/product/all_colors.dart';
import 'package:tuttuu_app/UI/product/all_paddings.dart';

class TextFieldStyles extends StatelessWidget {
  const TextFieldStyles({
    super.key,
    required this.invisibleBool,
    required this.fieldInputType,
    required this.maxLength,
    this.iconField,
    required this.labelText,
    this.controller,
    this.validator, // Optional validator
  });

  final IconData? iconField;
  final TextInputType fieldInputType;
  final bool invisibleBool;
  final int maxLength;
  final String labelText;
  final TextEditingController? controller;
  final String? Function(String?)? validator; // Optional validator

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MainPaddings().textFieldPadding,
      child: TextFormField(
        controller: controller,
        obscureText: invisibleBool,
        style: TextStyle(color: MainColors().fieldTitleColorL),
        autofocus: false,
        cursorColor: MainColors().fieldTitleColorL,
        keyboardType: fieldInputType,
        inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
        decoration: InputDecoration(
          labelStyle: TextStyle(color: MainColors().fieldLabelColorL),
          icon: iconField != null ? Icon(iconField) : null, // Check if iconField is null
          iconColor: MainColors().textFieldDisabledL,
          floatingLabelStyle: TextStyle(color: MainColors().fieldTitleColorL),
          labelText: labelText,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MainColors().textFieldDisabledL),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: MainColors().fieldTitleColorL,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.red,
            ),
          ),
        ),
        validator: validator, // Use the optional validator
      ),
    );
  }
}
