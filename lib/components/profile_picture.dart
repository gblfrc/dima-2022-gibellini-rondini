import 'dart:math';

import 'package:flutter/material.dart';

import '../app_logic/storage.dart';

class ProfilePicture extends StatefulWidget {
  final String uid;
  final Storage storage;

  const ProfilePicture({super.key, required this.uid, required this.storage});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  bool hasError = false;

  @override
  Widget build(BuildContext context) {
    String pictureRemoteLocation = "profile-pictures/${widget.uid}";
    return LayoutBuilder(
      builder: (builder, constraint) {
        double size = min(constraint.maxHeight, constraint.maxWidth);
        Icon fallbackIcon = Icon(
          key: const Key('IconReplacingCircleAvatar'),
          Icons.account_circle,
          color: Colors.grey,
          size: size,
        );
        if (hasError) {
          return fallbackIcon;
        } else {
          return FutureBuilder(
            future: widget.storage.downloadURL(pictureRemoteLocation),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return CircleAvatar(
                  key: const Key("CircleAvatarBorder"),
                  radius: size * 0.48,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: CircleAvatar(
                    key: const Key("CircleAvatarImage"),
                    radius: size * 0.42,
                    backgroundColor: Colors.white,
                    foregroundImage: NetworkImage(snapshot.data!),
                    onForegroundImageError: (error, stackTrace) {
                      setState(() {
                        hasError = true;
                      });
                    },
                  ),
                );
              } else {
                return fallbackIcon;
              }
            },
          );
        }
      },
    );
  }
}
