import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Etkileşim verilerini kaydetme
Future<void> saveInteraction(List<String> tags) async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    print("Kullanıcı oturum açmamış.");
    return;
  }

  final userInteractionsRef = FirebaseFirestore.instance
      .collection('userInteractions')
      .doc(currentUser.uid);

  WriteBatch batch = FirebaseFirestore.instance.batch();

  for (var tag in tags) {
    batch.set(
      userInteractionsRef,
      {
        'tags': {
          tag: {
            'frequency': FieldValue.increment(1),
            'lastInteraction': Timestamp.now(),
          }
        }
      },
      SetOptions(merge: true),
    );
  }

  await batch.commit();
  print("Tıklama verisi toplu olarak kaydedildi.");
}


Future<void> calculateAndSaveTagImportance() async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    print("Kullanıcı oturum açmamış.");
    return;
  }

  final userDoc = await FirebaseFirestore.instance
      .collection('userInteractions')
      .doc(currentUser.uid)
      .get();

  if (!userDoc.exists) {
    print("Kullanıcı verisi bulunamadı.");
    return;
  }

  const double frequencyWeight = 0.7;
  const double recencyWeight = 0.3;

  final Map<String, dynamic> tags = userDoc.data()?['tags'] ?? {};
  if (tags.isEmpty) {
    print("No tags found in the Firestore document.");
    return;
  }

  final List<Map<String, dynamic>> tagImportanceList = [];
  double totalImportance = 0.0;

  tags.forEach((tagName, tagData) {
    if (tagData is Map<String, dynamic>) {
      int frequency = tagData['frequency'] ?? 0;
      Timestamp lastInteraction = tagData['lastInteraction'] ?? Timestamp.now();

      double tagRecency = 1 / (DateTime.now().difference(lastInteraction.toDate()).inSeconds.abs() + 1);

      double tagImportance = (frequency * frequencyWeight) + (tagRecency * recencyWeight);

      tagImportanceList.add({
        'tag': tagName,
        'importance': tagImportance,
      });

      totalImportance += tagImportance;
    }
  });

  if (totalImportance == 0) {
    print("No importance calculated.");
    return;
  }

  // Normalize tag importance so that the total is 100
  final List<Map<String, dynamic>> normalizedTagImportanceList = [];
  tagImportanceList.forEach((tag) {
    double normalizedImportance = (tag['importance'] / totalImportance) * 100;
    normalizedTagImportanceList.add({
      'tag': tag['tag'],
      'importance': normalizedImportance,
    });
  });

  // Importance'a göre sıralama
  normalizedTagImportanceList.sort((a, b) => b['importance'].compareTo(a['importance']));

  // Tag importance'ı Firestore'a kaydetme
  final userInteractionsRef = FirebaseFirestore.instance
      .collection('userInteractions')
      .doc(currentUser.uid);

  await userInteractionsRef.set({
    'tagImportance': normalizedTagImportanceList,
  }, SetOptions(merge: true));

  print("Tag importance verisi kaydedildi.");
}

