import 'package:flutter/material.dart';
import 'package:tuttuu_app/UI/product/all_colors.dart';

class BuildPageIndicatorGeneral extends StatelessWidget {
  const BuildPageIndicatorGeneral({super.key, required this.currentIndex, required this.items});

  final int currentIndex;
  final List items;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(items.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: currentIndex == index ? 8.0 : 6.0,
          height: currentIndex == index ? 8.0 : 6.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentIndex == index ? MainColors().fieldTitleColorL : MainColors().fieldLabelColorL,
          ),
        );
      }),
    );
  }
}
