import 'package:flutter/material.dart';
import 'package:tuttuu_app/UI/product/all_colors.dart';


class PhotoAndTextWidget extends StatelessWidget {
  const PhotoAndTextWidget({super.key, required this.pageController, required this.textItems, required this.photoItems, required this.onPageChanged, required this.subtext});

  final PageController pageController;
  final List<String> textItems;
  final List<String> photoItems;
  final ValueChanged<int> onPageChanged;
  final List<String> subtext;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: PageView.builder(
        controller: pageController,
        itemCount: textItems.length,
        onPageChanged: onPageChanged,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Görsel
                Image.asset(
                  photoItems[index],
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 5), // Görsel ile metin arasında boşluk
                // Metin
                Text(
                  textItems[index],
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold, // Kalın yazı tipi
                    color: MainColors().fieldTitleColorL, // Metin rengi
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                // Alt metin açıklaması (opsiyonel)
                Text(
                  subtext[index], // İsteğe bağlı açıklama
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: MainColors().textFieldDisabledL, // Açıklama rengi
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
