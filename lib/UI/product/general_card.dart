import 'package:flutter/material.dart';
import 'package:tuttuu_app/UI/product/all_colors.dart';

class GeneralCard extends StatefulWidget {
  const GeneralCard({super.key});

  @override
  State<GeneralCard> createState() => _GeneralCardState();
}

class _GeneralCardState extends State<GeneralCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: MainColors().appBackgroundColor,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: SizedBox(
        height: 220,
        child: PageView.builder(
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15),bottom: Radius.circular(15)),
              child: Container(
                color: Colors.blue[(index + 1) * 200], // Kaydırılabilir alanın rengi
                child: Center(
                  child: Text(
                    'Page $index',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
            );
          },
          itemCount: 5, // Kaç tane sayfa olduğunu belirler
        ),
      ),
    );
  }
}
