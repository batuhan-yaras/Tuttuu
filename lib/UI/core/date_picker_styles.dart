
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için
import '../product/all_colors.dart';
import '../product/all_paddings.dart';

class DatePickerStyles extends StatelessWidget {
  const DatePickerStyles({
    super.key,
    this.iconField,
    this.selectedDate,
    required this.onDateSelected,
  });

  final IconData? iconField;
  final DateTime? selectedDate;
  final void Function(DateTime) onDateSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MainPaddings().textFieldPadding,
      child: GestureDetector(
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );

          if (pickedDate != null) {
            onDateSelected(pickedDate);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelStyle: TextStyle(color: MainColors().fieldLabelColorL),
            icon: iconField != null ? Icon(iconField) : null, // Check if iconField is null
            iconColor: MainColors().textFieldDisabledL,
            floatingLabelStyle: TextStyle(color: MainColors().fieldTitleColorL),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MainColors().textFieldDisabledL),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: MainColors().fieldTitleColorL,
              ),
            ),
          ),
          child: Text(
            selectedDate != null
                ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                : 'Date of Birth*',
            style: TextStyle(
              color: selectedDate != null
                  ? MainColors().fieldTitleColorL
                  : MainColors().fieldLabelColorL,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}