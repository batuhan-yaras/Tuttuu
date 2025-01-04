import 'package:flutter/material.dart';
import 'package:tuttuu_app/UI/product/all_paddings.dart';

import '../product/all_colors.dart';

class GenderSelectorStyles extends StatefulWidget {
  const GenderSelectorStyles({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
  });

  final String selectedGender;
  final ValueChanged<String> onGenderChanged;

  @override
  State<GenderSelectorStyles> createState() => _GenderSelectorStylesState();
}

class _GenderSelectorStylesState extends State<GenderSelectorStyles> {
  late String _selectedGender;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.selectedGender;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MainPaddings().textFieldPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.wc, color: MainColors().fieldTitleColorL),
          const SizedBox(width: 15,),
          Container(
              child: Row(
                children: [
                  _genderButton('Male'),
                  _genderButton('Female'),
                  _genderButton('Prefer not to say'),
                ],
              ),
            ),
          ],
        ),
      );
  }

  Widget _genderButton(String gender) {
    final bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
        widget.onGenderChanged(gender);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? MainColors().fieldTitleColorL : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          gender,
          style: TextStyle(
            color: isSelected ? Colors.white : MainColors().fieldLabelColorL,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}