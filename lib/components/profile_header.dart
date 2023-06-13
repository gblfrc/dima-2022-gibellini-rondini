import 'package:flutter/material.dart';
import 'package:progetto/components/profile_picture.dart';

import '../app_logic/auth.dart';
import '../app_logic/storage.dart';
import '../app_logic/database.dart';
import '../app_logic/exceptions.dart';
import '../model/user.dart';

class ProfileHeader extends StatefulWidget {
  final User user;

  const ProfileHeader({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.shortestSide / 3;
    var padding = height / 10;
    bool isCurrentUser = (widget.user.uid == Auth().currentUser!.uid);

    return SizedBox(
      height: height,
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Expanded(
            flex: 1,
            child: ProfilePicture(uid: widget.user.uid, storage: Storage(),),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Stack(
                  alignment: Alignment.topRight,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "${widget.user.name} ${widget.user.surname}",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).textScaleFactor * 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!isCurrentUser)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: FutureBuilder(
                          future: Database.getFriends(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text(
                                "Something went wrong while checking friend list. Please try again later.",
                                textAlign: TextAlign.center,
                              );
                            }
                            if (snapshot.hasData) {
                              for (User friend in snapshot.data!) {
                                if (friend.uid == widget.user.uid) {
                                  return ElevatedButton(
                                    onPressed: removeFriend,
                                    child: const Text("Remove friend"),
                                  );
                                }
                              }
                              return FilledButton(
                                onPressed: addFriend,
                                child: const Text("Add to friends"),
                              );
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
                        // child: Container(
                        //     color: Colors.green.shade100,
                        //     height: 20,
                        //     width: 20),
                      ),
                    // Text(
                    //   DateFormat.yMd().format(user.birthday!),
                    //   style: TextStyle(
                    //     fontSize: MediaQuery.of(context).textScaleFactor * 15,
                    //   ),
                    // ),
                  ],
                ),
            ),
          ),
        ],
      ),
    );
  }

  void addFriend() {
    try {
      Database.addFriend(widget.user.uid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Added to friends!"),
        ),
      );
      Navigator.of(context).pop();
    } on DatabaseException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Please try again."),
        ),
      );
    }
  }

  void removeFriend() {
    try {
      Database.removeFriend(widget.user.uid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Friend removed."),
        ),
      );
      Navigator.of(context).pop();
    } on DatabaseException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Please try again."),
        ),
      );
    }
  }
}
