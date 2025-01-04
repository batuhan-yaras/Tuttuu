import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuttuu_app/UI/core/button_theme.dart';
import 'package:tuttuu_app/UI/product/all_texts.dart';
import 'package:tuttuu_app/core/image_services.dart';
import '../../product/imageAddButton.dart';
import 'all_colors.dart';

class ImageAddBox extends StatefulWidget {
  const ImageAddBox({super.key, required this.pageOwner, required this.userId, required this.showDeleteButton});
  final String userId;
  final bool pageOwner;
  final bool showDeleteButton;
  @override
  State<ImageAddBox> createState() => _ImageAddBoxState();
}
class _ImageAddBoxState extends State<ImageAddBox> {
  ImageService imageservices = ImageService();
  final PageController _pageController = PageController();
  List<String> imageUrls = [];
  Future<void> _deleteImage(String url) async {
    try {
      // Firestore'dan görseli sil
      final doc = await FirebaseFirestore.instance
          .collection('userImages')
          .where('url', isEqualTo: url)
          .where('userId', isEqualTo: widget.userId)
          .get();

      if (doc.docs.isNotEmpty) {
        doc.docs.first.reference.delete();
      }

      // Firebase Storage'dan sil
      imageservices.deleteImageFromStorage(url);
      setState(() {
        imageUrls.remove(url);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting image: $e')),
      );
    }
  }
  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  void _fetchImages() async {
    // Firestore'dan kullanıcının tüm görsellerini al
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('userImages')
        .where('userId', isEqualTo: widget.userId)
        .where('tags', isEqualTo: ['studio'])
        .get();

    // Kullanıcıya ait görsellerin URL'lerini listeye ekle
    final List<String> fetchedUrls = snapshot.docs.map((doc) => doc['url'] as String).toList();
// Ekranı güncelle
    setState(() {
      imageUrls = fetchedUrls;
    });

  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          Card(
            color: MainColors().appBackgroundColor,
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: SizedBox(
              height: 220,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('userImages')
                    .where('userId', isEqualTo: widget.userId)
                    .where('tags', isEqualTo: ['studio'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading images.'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        InfoTexts().promoteStudio,
                        style: TextStyle(
                            fontSize: 16,
                            color: MainColors().fieldLabelColorLighter),
                      ),
                    );
                  }

                  // Kullanıcıya ait görsellerin URL'lerini listeye ekle
                  final List<String> fetchedUrls = snapshot.data!.docs
                      .map((doc) => doc['url'] as String)
                      .toList();

                  imageUrls = fetchedUrls;

                  return PageView.builder(
                    controller: _pageController,
                    itemCount: fetchedUrls.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                            bottom: Radius.circular(15)),
                        child: Stack(
                          children: [
                            Center(
                              child: Image.network(
                                fetchedUrls[index],
                                fit: BoxFit.cover,
                                height: 220,
                                width: double.maxFinite,
                                errorBuilder: (context, error, stackTrace) {
                                  _deleteImage(fetchedUrls[index]);
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: widget.showDeleteButton
                                  ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0.4,
                                  backgroundColor: Colors.white54,
                                  shape: const CircleBorder(),
                                ),
                                child: Icon(
                                  Icons.delete,
                                  color: MainColors().errorColor,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Are you sure?"),
                                        content: const Text(
                                            "Do you really want to delete this image?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop();
                                            },
                                            child: const Text("No"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop();
                                              _deleteImage(
                                                  fetchedUrls[index]);
                                            },
                                            child: const Text("Yes"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          if (imageUrls.length > 1) ...[
            Positioned(
              left: 0,
              top: 95,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_left,
                  color: Colors.black38,
                  size: 40,
                ),
                onPressed: () {
                  final currentIndex = _pageController.page?.round() ?? 0;
                  if (currentIndex > 0) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),
            // Sağ ok
            Positioned(
              right: 0,
              top: 95,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_right,
                  color: Colors.black38,
                  size: 40,
                ),
                onPressed: () {
                  final currentIndex = _pageController.page?.round() ?? 0;
                  if (currentIndex < imageUrls.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),
          ],
          Positioned(
            bottom: 10,
            left: MediaQuery.of(context).size.width / 1.7,
            child: widget.pageOwner
                ? Container(
              width: 60,
              height: 50,
              decoration: BoxDecoration(
                color: MainColors().fieldTitleColorL,
                borderRadius: const BorderRadius.all(
                  Radius.circular(50),
                ),
              ),
              child: ImageAddButton(
                imageURLList: imageUrls,
                userID: widget.userId,
                onPressed: () async {
                  bool permissionGranted =
                  await imageservices.requestPermission();
                  if (permissionGranted) {
                    List<File> selectedImages =
                    await imageservices.pickImages(context);
                    List<String> downloadUrls =
                    await imageservices.uploadImages(
                        context,
                        selectedImages,
                        widget.userId,
                        ['studio'],
                        'studios/',
                        false);
                    setState(() {
                      imageUrls.addAll(downloadUrls);
                    });
                  }
                },
              ),
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

