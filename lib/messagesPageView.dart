import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tuttuu_app/UI/product/all_colors.dart';
import 'package:tuttuu_app/UI/product/pp_settings.dart';
import 'package:tuttuu_app/UI/product/title_settings.dart';
import 'package:tuttuu_app/core/message_sender.dart';
//TODO: Bildirim ayarla.
class MessagesPageView extends StatefulWidget {
  final String currentUserId;

  const MessagesPageView({super.key, required this.currentUserId});

  @override
  State<MessagesPageView> createState() => _MessagesPageViewState();
}
class _MessagesPageViewState extends State<MessagesPageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: MainTitle('Messages'),centerTitle: false,),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .where('participants', arrayContains: widget.currentUserId) // currentUserId içeren konuşmalar
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No messages found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final conversation = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final participants = conversation['participants'] as List;

              // Find the other participant ID (not the current user)
              final otherUserId = participants.firstWhere(
                    (id) => id != widget.currentUserId,
                orElse: () => 'Unknown User',
              );

              // Fetch user details for the other participant
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(
                      leading: CircleAvatar(),
                      title: Text('Loading...'),
                      subtitle: Text(''),
                    );
                  }

                  final user = userSnapshot.data!;
                  final userName = user['fullName'] ?? 'Unknown';
                  final imageUrl = user['profilePictureUrl'] ?? 'https://ui-avatars.com/api/?name=$userName&size=240&length=1';

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListTile(
                      leading: CircleAvatar(child: ProfilePicture(imageUrl: imageUrl,userName: userName,),radius: 23,),
                      title: Text(
                        userName, // Display the other user's name here
                        style: TextStyle(
                          color: MainColors().fieldTitleColorL,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        conversation['lastMessage'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing: Text(
                        _formatTimestamp(conversation['lastMessageTime']),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessageSender(receiverUserId: otherUserId,fullName: userName,imageUrl: imageUrl),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dateTime = timestamp.toDate();
    return DateFormat('HH.mm').format(dateTime);
  }
}
