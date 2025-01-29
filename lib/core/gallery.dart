import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuttuu_app/UI/product/title_settings.dart';
import '../UI/product/all_colors.dart';
import '../UI/product/all_texts.dart';
import '../product/CategoryDetailScreen.dart';

class ImagePortfolio extends StatefulWidget {
  const ImagePortfolio({super.key});

  @override
  State<ImagePortfolio> createState() => _ImagePortfolioState();
}
class _ImagePortfolioState extends State<ImagePortfolio> {
  bool isLoading = true;
  List<String> allImages = []; // Tüm görsellerin listesi
  final List<String> categories = [
    '3D', 'Anime', 'Geometrik', 'Yazı', 'Maori', 'Mandala', 'Minimal',
    'New School', 'Old School', 'Portre', 'Gerçekçi', 'Tribal', 'Suluboya'
  ]; // Kategorilerin listesi
  final List<String> tags = [
    '3d', 'anime', 'geometrik', 'yazı', 'maori', 'mandala', 'minimal',
    'newschool', 'oldschool', 'portre', 'realistik', 'tribal', 'suluboya'
  ]; // Etiketlerin listesi
  String selectedCategory = 'Hepsi'; // Başlangıçta 'All' seçili
  List<String> filteredImages = []; // Filtrelenmiş görseller

  @override
  void initState() {
    super.initState();
    loadTattoos();
  }

  // Görselleri Firestore'dan çekiyoruz ve seçilen kategoriye göre filtreliyoruz
  Future<void> loadTattoos() async {
    List<String> imagesList = []; // Tüm görseller burada toplanacak

    try {
      QuerySnapshot tagSnapshot = await FirebaseFirestore.instance.collection('tattoos').get();

      for (var doc in tagSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('tags') && data.containsKey('url')) {
          String downloadURL = data['url']; // Tek bir URL alıyoruz
          List<String> tagsFromDb = List<String>.from(data['tags']); // Tagleri alıyoruz

          // Seçilen kategoriye göre filtreleme yapıyoruz
          if (selectedCategory == 'Hepsi' || tagsFromDb.contains(tags[categories.indexOf(selectedCategory)])) {
            imagesList.add(downloadURL);
          }
        } else {
          debugPrint("Missing 'tags' or 'url' in document: ${doc.id}");
        }
      }

      setState(() {
        allImages = imagesList; // Görselleri güncelle
        filteredImages = imagesList; // Filtrelenmiş görselleri de güncelle
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading tattoos: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: MainTitle(InfoTexts().tuttuuGallery,size: 22),
        actions: [
          DropdownButton<String>(
            dropdownColor: MainColors().appBackgroundColor,
            style: TextStyle(color: MainColors().fieldTitleColorL,fontSize: 14,fontWeight: FontWeight.w400),
            padding: EdgeInsets.only(right: 20.0),
            value: selectedCategory,
            onChanged: (String? newValue) {
              setState(() {
                selectedCategory = newValue!;
                loadTattoos(); // Kategori değiştiğinde görselleri tekrar yükle
              });
            },
            items: ['Hepsi', ...categories].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: CategoryDetailScreen(
          isRandom: true,
          showAppBar: false,
          category: selectedCategory, // Seçilen kategori adı
          images: filteredImages, // Filtrelenmiş görselleri geçiyoruz
        ),
      ),
    );
  }
}
