import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuttuu_app/UI/core/textField_theme.dart';
import 'package:tuttuu_app/UI/product/pp_settings.dart';
import 'package:tuttuu_app/UI/product/title_settings.dart';
import 'package:tuttuu_app/core/user_data_services.dart';
import 'package:tuttuu_app/product/CategoryDetailScreen.dart';
import 'package:tuttuu_app/product/ProfilePageView.dart';
import 'package:tuttuu_app/userProfilePage.dart';

import '../UI/product/all_colors.dart';

class MessageSender extends StatefulWidget {
  MessageSender({super.key, required this.receiverUserId, required this.fullName, required this.imageUrl});
  final String receiverUserId;
  late String fullName;
  late String imageUrl;

  @override
  _MessageSenderState createState() => _MessageSenderState();
}

class _MessageSenderState extends State<MessageSender> {
  final TextEditingController _controller = TextEditingController();

  String getConversationId(String userId1, String userId2) {
    return userId1.compareTo(userId2) < 0 ? '${userId1}_$userId2' : '${userId2}_$userId1';
  }

  Future<void> sendMessage(String message) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "Anonim";
    final conversationId = getConversationId(currentUserId, widget.receiverUserId);

    _controller.clear();

    if (message.isNotEmpty) {
      await FirebaseFirestore.instance.collection('conversations').doc(conversationId).collection('messages').add({
        'text': message,
        'senderId': currentUserId,
        'receiverUserId': widget.receiverUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Son mesajı güncelle
      await FirebaseFirestore.instance.collection('conversations').doc(conversationId).set({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'participants': [currentUserId, widget.receiverUserId],
      });
    }
  }

  Stream<List<QueryDocumentSnapshot>> fetchMessages() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "Anonim";
    final conversationId = getConversationId(currentUserId, widget.receiverUserId);

    return FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs);
  }

  bool _isTattooArtist = false;
  Future<void> isTattooArtist() async {
    try {
      // Firestore'dan ilgili veriyi çekme
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.receiverUserId).get();

      // Verinin mevcut olup olmadığını kontrol et
      if (userDoc.exists) {
        // 'isTattooArtist' alanını kontrol et
        bool isTattooArtist = userDoc['isTattooArtist'] ?? false; // Varsayılan değeri false olarak al
        setState(() {
          _isTattooArtist = isTattooArtist;
        });
      } else {
        print("User not found");
        setState(() {
          _isTattooArtist = false; // Varsayılan değeri false olarak ayarla
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        _isTattooArtist = false; // Hata durumunda da varsayılan false
      });
    }
  }

  String _studioId = '';
  Future<void> getStudioId() async {
    try {
      // Firestore'dan ilgili veriyi çekme
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.receiverUserId).get();

      // Verinin mevcut olup olmadığını kontrol et
      if (userDoc.exists) {
        // 'studioId' alanını kontrol et
        String studioId = userDoc['studioId'] ?? ''; // Eğer alan yoksa boş bir string döner
        setState(() {
          _studioId = (studioId.isEmpty ? null : studioId)!; // Boş değilse studioId'yi atıyoruz
        });
      } else {
        print("User not found");
        setState(() {
          _studioId = ''; // Kullanıcı bulunamazsa studioId'yi null yap
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        _studioId = ''; // Hata durumunda da null
      });
    }
  }

  @override
  void initState() {
    super.initState();
    isTattooArtist();
    getStudioId();
  }

  @override
  Widget build(BuildContext context) {
    // Boş imageUrl durumunda alternatif URL
    String imageUrl = widget.imageUrl.isEmpty
        ? 'https://ui-avatars.com/api/?name=${widget.fullName}&size=240&length=1'
        : widget.imageUrl;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: Row(
            children: [
              CircleAvatar(
                  radius: 20,
                  child: ProfilePicture(
                    imageUrl: imageUrl,
                    userName: widget.fullName,
                  )),
              const SizedBox(width: 10),
              MainTitle(widget.fullName, size: 20),
            ],
          ),
          onTap: () {
            if (_isTattooArtist == true) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePageView(
                            studioId: _studioId,
                            showFloatingButton: false,
                          )));
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserProfilePage(
                            receiverUserId: widget.receiverUserId,
                            sendMessageFunction: false,
                            userId: widget.receiverUserId,
                            isOwner: false,
                            isAppBar: true,
                          )));
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<QueryDocumentSnapshot>>(
                stream: fetchMessages(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final messages = snapshot.data!;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isSentByCurrentUser = message['senderId'] == FirebaseAuth.instance.currentUser?.uid;

                      return Align(
                        alignment: isSentByCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSentByCurrentUser ? Colors.blueAccent : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message['text'],
                            style: TextStyle(
                              color: isSentByCurrentUser ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(color: MainColors().fieldLabelColorL),
                        labelText: 'Mesajını yaz...',
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: MainColors().textFieldDisabledL),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: MainColors().fieldTitleColorL,
                          ),
                        ),
                      ),
                      maxLength: 200,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      sendMessage(_controller.text);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
