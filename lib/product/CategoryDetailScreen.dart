import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuttuu_app/ImportanceCalculation/tagImportanceSaving.dart';
import '../UI/product/all_colors.dart';
import '../UI/product/all_texts.dart';
import '../UI/product/title_settings.dart';
import '../core/image_services.dart';
import 'ImageViewScreen.dart';

class CategoryDetailScreenBase extends StatefulWidget {
  final bool showDeleteButton;
  final String category;
  final List<String> images;
  final bool showFloatingActionButton;
  final bool onlyPortfolio;
  final String userId; // userId parametresini ekledik
  var leading;
  final bool showAppBar;  // New parameter to control visibility of AppBar
  final bool isRandom;

  CategoryDetailScreenBase({
    super.key,
    required this.category,
    required this.images,
    this.showFloatingActionButton = false,
    this.onlyPortfolio = false,
    this.showDeleteButton = false,
    this.leading,
    required this.userId, // userId parametresi
    this.showAppBar = true, this.isRandom = false, // Default to true, so AppBar is shown by default
  });

  @override
  State<CategoryDetailScreenBase> createState() => _CategoryDetailScreenBaseState();
}
final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
class _CategoryDetailScreenBaseState extends State<CategoryDetailScreenBase> {

  List<String> selectedTags = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
        centerTitle: true,
        leading: widget.leading,
        title: MainTitle(widget.category),
      )
          : null,
      body: widget.onlyPortfolio ? _buildPortfolioImageStream() : _buildImageGrid(widget.images),
      floatingActionButton: widget.showFloatingActionButton ? _buildFloatingActionButton() : null,
    );
  }

  Widget _buildPortfolioImageStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tattoos')
          .where('userId', isEqualTo: widget.userId)  // userId'yi burada kullanıyoruz
          .where('tags', arrayContains: 'portfolio')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final filteredImages = snapshot.data?.docs.map((doc) => doc['url'] as String).toList().reversed.toList() ?? [];

        return _buildImageGrid(filteredImages);
      },
    );
  }
  Widget _buildImageGrid(List<String> images) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Card(
          color: MainColors().appBackgroundColor,
          elevation: 10,
          child: GestureDetector(
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageViewScreen(
                    imagePath: images[index],
                    showDeleteButton: widget.showDeleteButton,
                    imageUrls: images,
                  ),
                ),
              );
              await handleImageTap(images[index]);
              saveInteraction(selectedTags);
              calculateAndSaveTagImportance();
              selectedTags = [];
            },
            child: CachedNetworkImage(
              imageUrl: images[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        );
      },
    );
  }
  Future handleImageTap(String imageUrl) async {
    try {
      print('Fetching image with URL: $imageUrl');  // URL'yi kontrol et
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('tattoos')
          .where('url', isEqualTo: imageUrl)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot imageDoc = snapshot.docs.first;
        List<dynamic> tags = imageDoc['tags'] ?? [];
        setState(() {
          selectedTags.addAll(List<String>.from(tags));
        });
        print('Selected Tags: $selectedTags');
      } else {
        print('No image found with the provided URL.');
      }
    } catch (e) {
      print('Error fetching image tags: $e');
    }
  }


  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        _showImageAndTagSelector(context);
      },
      backgroundColor: MainColors().fieldTitleColorL,
      child: Icon(
        Icons.add,
        color: MainColors().appBackgroundColor,
      ),
    );
  }


  void _showImageAndTagSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        List<String> selectedTags = [];
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Please select at least one tag',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: tags.map((tag) {
                      return FilterChip(
                        label: Text(tag),
                        selected: selectedTags.contains(tag),
                        onSelected: (isSelected) {
                          setState(() {
                            if (isSelected) {
                              selectedTags.add(tag);
                            } else {
                              selectedTags.remove(tag);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedTags.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select at least one tag.'),
                          ),
                        );
                        return;
                      }
                      bool permissionGranted = await ImageService().requestPermission();
                      if (permissionGranted) {
                        List<File> selectedImages = await ImageService().pickImages(context);
                        List<String> downloadUrls = await ImageService().uploadImages(context, selectedImages, widget.userId, ['portfolio'] + selectedTags, 'tattoos/',true);
                        setState(() {
                          widget.images.addAll(downloadUrls);
                        });
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class CategoryDetailScreen extends StatefulWidget {
  final bool showDeleteButton;
  final String category;
  final List<String> images;
  final bool showFloatingActionButton;
  final bool showAppBar;
  final bool isRandom;

  const CategoryDetailScreen({
    super.key,
    required this.category,
    required this.images,
    this.showFloatingActionButton = false,
    this.showDeleteButton = false, this.showAppBar = true, this.isRandom = false,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return CategoryDetailScreenBase(
      isRandom: widget.isRandom,
      showAppBar: widget.showAppBar,
      category: widget.category,
      images: widget.images,
      showFloatingActionButton: widget.showFloatingActionButton,
      onlyPortfolio: false,
      showDeleteButton: widget.showDeleteButton,
      userId: currentUserId,
    );
  }
}

class CategoryDetailScreenPortfolio extends StatelessWidget {
  final bool showDeleteButton;
  final String category;
  final List<String> images;
  final bool showFloatingActionButton;
  final String userId; // userId parametresi ekledik

  const CategoryDetailScreenPortfolio({
    super.key,
    required this.category,
    required this.images,
    this.showFloatingActionButton = false,
    this.showDeleteButton = false,
    required this.userId, // userId parametresi
  });

  @override
  Widget build(BuildContext context) {
    return CategoryDetailScreenBase(
      category: category,
      images: images,
      showFloatingActionButton: showFloatingActionButton,
      onlyPortfolio: true,
      showDeleteButton: showDeleteButton,
      userId: userId, // userId'yi ilettik
    );
  }
}
