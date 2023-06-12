import 'dart:math';

import 'package:flutter/material.dart';

import '../app_logic/storage.dart';

class ProfilePicture extends StatelessWidget {
  final String uid;

  const ProfilePicture({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    String pictureUrl = "profile-pictures/$uid";
    return LayoutBuilder(
      builder: (builder, constraint) {
        double size = min(constraint.maxHeight, constraint.maxWidth);
        return FutureBuilder(
          future: Storage().downloadURL(pictureUrl),
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
                ),
              );
            } else {
              return Icon(
                key: const Key('IconReplacingCircleAvatar'),
                Icons.account_circle,
                color: Colors.grey,
                size: size,
              );
            }
          },
        );
      },
    );
  }
}
