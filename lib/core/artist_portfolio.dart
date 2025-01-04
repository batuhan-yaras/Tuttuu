import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuttuu_app/FavouritePageView.dart';
import 'package:tuttuu_app/UI/product/all_colors.dart';
import 'package:tuttuu_app/UI/product/all_texts.dart';
import 'package:tuttuu_app/UI/product/hiddenContainer.dart';
import 'package:tuttuu_app/userProfilePage.dart';

import '../product/CategoryDetailScreen.dart';
import '../product/ImageViewScreen.dart';

class FlexibleImageGrid extends StatefulWidget {
  const FlexibleImageGrid({
    super.key,
    required this.showDeleteButton,
    required this.showFloatingActionButton,
    required this.userId,
    this.portfolioTitle = 'Portfolio',
    this.collectionName = 'tattoos',
    this.tag, required this.isPortfolio, this.isHiddenFavourite = false, required this.isOwner,
  });

  final bool showDeleteButton;
  final bool showFloatingActionButton;
  final String userId;
  final String portfolioTitle;
  final String collectionName;
  final String? tag; // Optional for collections like 'favourites'
  final bool isPortfolio;
  final bool isHiddenFavourite;
  final bool isOwner;

  @override
  State<FlexibleImageGrid> createState() => _FlexibleImageGridState();
}



class _FlexibleImageGridState extends State<FlexibleImageGrid> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.portfolioTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MainColors().fieldTitleColorL,
                ),
                overflow: TextOverflow.ellipsis,  // Taşan metin için '...' ekler
                maxLines: 2,  // Satır sayısını 1 ile sınırlar
              ),
            ),
            if(isFavouritesHiddenProfile == false || widget.isOwner == true)
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _navigateToDetailScreen(context, widget.isPortfolio),
              ),
          ],
        ),
        widget.isHiddenFavourite
        ? HiddenContainer(pageTitle: 'Hidden Favourites', assetImage: AppFeatures().hiddenFavourite)
        : StreamBuilder<List<Map<String, dynamic>>>(
          stream: _getStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  InfoTexts().portfolioShare,
                  style: TextStyle(
                    fontSize: 16,
                    color: MainColors().fieldLabelColorLighter,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final imageUrls = snapshot.data!.map((e) => e['url'] as String).toList();

            return SizedBox(
              height: 150,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisSpacing: 4.0,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: MainColors().appBackgroundColor,
                    elevation: 10,
                    child: GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageViewScreen(
                              imagePath: imageUrls[index],
                              imageUrls: imageUrls,
                            ),
                          ),
                        );
                        if (result == true) {
                          setState(() {});
                        }
                      },
                      child: CachedNetworkImage(
                        imageUrl: imageUrls[index],
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Stream<List<Map<String, dynamic>>> _getStream() {
    if (widget.collectionName == 'favourites') {
      return FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(widget.userId)
          .snapshots()
          .map((docSnapshot) {
        if (docSnapshot.exists) {
          final List<dynamic> photos = docSnapshot['photos'] ?? [];
          // Fotoğrafları uygun bir listeye dönüştürüyoruz
          return photos.map((e) => {'url': e.toString()}).toList().reversed.toList();
        }
        return [];
      });
    } else {
      return FirebaseFirestore.instance
          .collection(widget.collectionName)
          .where('userId', isEqualTo: widget.userId)
          .where('tags', arrayContains: widget.tag)
          .snapshots()
          .map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          return {'url': doc['url']};
        }).toList().reversed.toList();
      });
    }
  }


  void _navigateToDetailScreen(BuildContext context,bool isPortfolio) {
    if(isPortfolio == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryDetailScreenPortfolio(
            category: widget.portfolioTitle,
            images: const [],
            showFloatingActionButton: widget.showFloatingActionButton,
            showDeleteButton: widget.showDeleteButton,
            userId: widget.userId,
          ),
        ),
      );
    } else if(isPortfolio == false){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FavouritePageView(userId: widget.userId)
        ),
      );
    }
  }
}
