import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePicture extends StatefulWidget {
  const ProfilePicture({super.key, required this.imageUrl, this.userName = ''});
  final String imageUrl;
  final String userName;

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  @override
  Widget build(BuildContext context) {
    // Check if the imageUrl is not empty, otherwise use the default URL
    String displayImageUrl = widget.imageUrl.isNotEmpty
        ? widget.imageUrl
        : 'https://ui-avatars.com/api/?name=${widget.userName}&size=240&length=1';

    return CircleAvatar(
      radius: 60,
      backgroundImage: NetworkImage(displayImageUrl),
    );
  }
}
