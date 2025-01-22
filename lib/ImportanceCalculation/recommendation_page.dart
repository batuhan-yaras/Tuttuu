import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tuttuu_app/product/CategoryDetailScreen.dart';

import '../UI/product/all_texts.dart';

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({super.key});

  @override  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  List<String> imageUrls = [];
  final List<String> defaultTags = [
    '3d', 'anime', 'geometrik', 'yazı', 'maori', 'mandala', 'minimal',
    'newschool', 'oldschool', 'portre', 'realistik', 'tribal', 'suluboya', 'blackart'
  ];

  @override
  void initState() {
    super.initState();
    fetchRecommendedImages();
  }
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
  Future<void> fetchRecommendedImages() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userInteractionDoc = await firestore.collection('userInteractions').doc(userId).get();
      Set<String> allImageUrls = {};

      final tattooQuerySnapshot = await firestore.collection('tattoos').get();
      int totalPhotosCount = ((tattooQuerySnapshot.size) / tags.length).round();

      if (userInteractionDoc.exists) {
        List<Map<String, dynamic>> tags = List<Map<String, dynamic>>.from(userInteractionDoc.get('tagImportance'));

        tags.sort((a, b) => (b['importance'] as num).compareTo(a['importance'] as num));

        double maxImportance = tags.isNotEmpty ? tags.first['importance'] : 1;

        for (var tag in tags) {
          String tagName = tag['tag'];
          double tagImportance = tag['importance'] ?? 1;

          int limit = ((totalPhotosCount) * (tagImportance / maxImportance)).round();
          limit = limit < 3 ? 3 : limit; // Minimum 3 image
          limit = limit > 10 ? 10 : limit; // Maximum 10 image

          final tattooQuery = await firestore.collection('tattoos')
              .where('tags', arrayContains: tagName)
              .limit(limit)
              .get();

          for (var tattooDoc in tattooQuery.docs) {
            allImageUrls.add(tattooDoc.get('url'));
          }

        }
      }

      if (allImageUrls.isEmpty) {
        for (var tag in defaultTags) {
          final tattooQuery = await firestore.collection('tattoos')
              .where('tags', arrayContains: tag)
              .limit(3)
              .get();

          for (var tattooDoc in tattooQuery.docs) {
            allImageUrls.add(tattooDoc.get('url'));
          }
        }
      }

      setState(() {
        imageUrls = allImageUrls.toList();
      });
    } catch (e) {
      print("Error fetching recommended images: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(AppFeatures().appNameLogo, height: 120),
      ),
      body: imageUrls.isNotEmpty
          ? CategoryDetailScreenBase(
        leading: Text(''),
        category: 'Tuttuu Recommendation',
        images: imageUrls,
        showFloatingActionButton: false,
        showDeleteButton: false, userId: userId,
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
