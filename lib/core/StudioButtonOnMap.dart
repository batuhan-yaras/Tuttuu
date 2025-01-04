import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuttuu_app/UI/core/button_theme.dart';

class ArtistButtons extends StatefulWidget {
  const ArtistButtons({super.key, required this.text, this.onPressed});
  final String text;
  final onPressed;

  @override
  _ArtistButtonsState createState() => _ArtistButtonsState();
}

class _ArtistButtonsState extends State<ArtistButtons> {
  bool? isArtist; // Nullable to indicate loading state.

  @override
  void initState() {
    super.initState();
    _checkIsArtist();
  }

  Future<void> _checkIsArtist() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      setState(() {
        isArtist = userDoc.data()?['isTattooArtist'] ?? false;
      });
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      setState(() {
        isArtist = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isArtist == null) {
      return Center(child: CircularProgressIndicator()); // Loading state.
    }

    return isArtist!
        ? GeneralButtons(buttonText: widget.text, onPressed: widget.onPressed,height: 40,width: 168,fontSize: 12,)
        : SizedBox.shrink(); // Empty widget if not an artist.
  }
}
