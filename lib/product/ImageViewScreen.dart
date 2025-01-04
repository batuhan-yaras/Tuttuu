
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../UI/product/all_colors.dart';
import '../core/image_services.dart';

class ImageViewScreen extends StatefulWidget {
  final bool showDeleteButton;
  final String imagePath;
  final List<String> imageUrls;

  const ImageViewScreen({super.key, required this.imagePath, this.showDeleteButton = false, required this.imageUrls});

  @override
  State<ImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
  late List<String> localImageUrls;
  bool? isFavourite;

  @override
  void initState() {
    super.initState();
    loadFavouriteStatus();
    localImageUrls = List.from(widget.imageUrls);
  }

  Future<void> loadFavouriteStatus() async {
    bool status = await ImageService().isPhotoInFavourites(userId, widget.imagePath);
    setState(() {
      isFavourite = status; // Durumu güncelle
    });
  }

  Future<void> _deleteImage(String url) async {
    try {
      // Firestore'dan görseli silme işlemleri...
      final doc = await FirebaseFirestore.instance
          .collection('userImages')
          .where('url', isEqualTo: url)
          .where('userId', isEqualTo: userId)
          .get();

      final doc2 = await FirebaseFirestore.instance
          .collection('tattoos')
          .where('url', isEqualTo: url)
          .where('userId', isEqualTo: userId)
          .get();

      if (doc.docs.isNotEmpty) {
        await doc.docs.first.reference.delete();
      }
      if (doc2.docs.isNotEmpty) {
        await doc2.docs.first.reference.delete();
      }

      // Firebase Storage'dan görseli sil
      await ImageService().deleteImageFromStorage(url);

      setState(() {
        localImageUrls.remove(url);
      });

      // Silme işlemi başarılı, `true` değeri ile geri dön
      Navigator.of(context).pop(true);
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi ver
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: MainColors().appBackgroundColor),
        backgroundColor: Colors.black,
        actions: widget.showDeleteButton ? [
          IconButton(onPressed: (){
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Are you sure?"),
                  content: Text("Do you really want to delete this image?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text("No"),
                    ),
                    TextButton(
                      onPressed: () {
                        _deleteImage(widget.imagePath); // Doğru URL'yi geç
                        Navigator.of(context).pop();
                        setState(() {
                          localImageUrls = widget.imageUrls;
                        });
                      },
                      child: Text("Yes"),
                    ),
                  ],
                );
              },
            );
          }, icon: Icon(Icons.delete)),
        ]
            : null,
      ),
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Stack(
            children: [
              PhotoView(
                imageProvider: NetworkImage(widget.imagePath),
                backgroundDecoration: const BoxDecoration(
                  color: Colors.black,
                ),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
            ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: screenWidth,
                    color: Colors.black54,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {
                            _downloadImage(widget.imagePath);
                          },
                          icon: Icon(
                            size: 26,
                            Icons.download,
                            color: MainColors().appBackgroundColor,
                          ),
                        ),
                IconButton(
                  onPressed: () async {
                    await ImageService().toggleFavouritePhoto(userId, widget.imagePath);
                    setState(() {
                      isFavourite = !(isFavourite ?? false); // Durumu tersine çevir
                    });
                  },
                  icon: Icon(
                    isFavourite == null
                        ? Icons.favorite_border // Yüklenme sırasında default ikon
                        : (isFavourite! ? Icons.favorite : Icons.favorite_border),
                    size: 26,
                    color: isFavourite == null
                        ? MainColors().appBackgroundColor // Yüklenirken default renk
                        : (isFavourite! ? Colors.red : MainColors().appBackgroundColor),
                  ),
                ),
                      ],
                    ),
                  ),
                ),
              ),
        ]
          ),
        ),
      ),
    );
  }

  Future<void> _downloadImage(String url) async {
    // İndirme işlemini gerçekleştirecek kodu buraya ekleyebilirsiniz.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download feature is under development')),
    );
  }
}