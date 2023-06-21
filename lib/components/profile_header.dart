import 'package:flutter/material.dart';
import 'package:progetto/components/profile_picture.dart';

import '../app_logic/auth.dart';
import '../app_logic/storage.dart';
import '../app_logic/database.dart';
import '../app_logic/exceptions.dart';
import '../model/user.dart';

class ProfileHeader extends StatefulWidget {
  final User user;
  final Storage storage;
  final Database database;
  final Auth auth;
  final Axis direction;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.storage,
    required this.database,
    required this.auth,
    this.direction = Axis.horizontal,
  });

  @override
  State<StatefulWidget> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  bool? isFriend;
  late bool isCurrentUser;

  @override
  void initState() {
    isCurrentUser = (widget.user.uid == widget.auth.currentUser!.uid);
    if (!isCurrentUser) {
      try {
        widget.database
            .isFriendOf(
          currentUserUid: widget.auth.currentUser!.uid,
          friendUid: widget.user.uid,
        )
            .then((value) {
          setState(() {
            isFriend = value;
          });
        });
      } on DatabaseException {
        // If friendship can't be defined, don't show button but don't interrupt
        // rendering of the screen
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      var padding = constraint.maxHeight / 10;
      return SizedBox(
        height: constraint.maxHeight,
        child: Flex(
          direction: widget.direction,
          children: [
            Expanded(
              flex: 1,
              child: ProfilePicture(
                key: const Key('ProfilePictureInProfileHeader'),
                uid: widget.user.uid,
                storage: widget.storage,
              ),
            ),
            Expanded(
              flex: 2,
              child: widget.direction == Axis.horizontal
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: Stack(
                        key: const Key('StackInProfileHeader'),
                        alignment: Alignment.topRight,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Align(alignment: Alignment.centerLeft, child: _UserNameText(widget.user)),
                          isCurrentUser
                              ? Container()
                              : (isFriend == null)
                                  ? Container()
                                  : Align(
                                      alignment: Alignment.bottomCenter,
                                      child: _FriendshipButton(
                                        isFriend: isFriend!,
                                        onRemove: removeFriend,
                                        onAdd: addFriend,
                                      )),
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(vertical: padding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _UserNameText(widget.user),
                          isCurrentUser
                              ? Container()
                              : (isFriend == null)
                                  ? Container()
                                  : _FriendshipButton(
                                      isFriend: isFriend!,
                                      onRemove: removeFriend,
                                      onAdd: addFriend,
                                    )
                        ],
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }

  void addFriend() {
    try {
      widget.database.addFriend(
        currentUserUid: widget.auth.currentUser!.uid,
        friendUid: widget.user.uid,
      );
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Added friend!"),
        ),
      );
      setState(() {
        isFriend = true;
      });
    } on DatabaseException {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Please try again."),
        ),
      );
    }
  }

  void removeFriend() {
    try {
      widget.database.removeFriend(
        currentUserUid: widget.auth.currentUser!.uid,
        friendUid: widget.user.uid,
      );
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Removed friend."),
        ),
      );
      setState(() {
        isFriend = false;
      });
    } on DatabaseException {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Please try again."),
        ),
      );
    }
  }
}

class _UserNameText extends StatelessWidget {
  final User user;

  const _UserNameText(this.user);

  @override
  Widget build(BuildContext context) {
    return Text(
      "${user.name} ${user.surname}",
      key: const Key('NameInProfileHeader'),
      style: TextStyle(
        fontSize: MediaQuery.of(context).textScaleFactor * 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _FriendshipButton extends StatelessWidget {
  final bool isFriend;
  final void Function() onRemove;
  final void Function() onAdd;

  const _FriendshipButton({
    required this.isFriend,
    required this.onRemove,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return (isFriend == true)
        ? ElevatedButton(
            key: const Key('ButtonToRemoveFriend'),
            onPressed: onRemove,
            child: const Text("Remove friend"),
          )
        : FilledButton(
            key: const Key('ButtonToAddFriend'),
            onPressed: onAdd,
            child: const Text("Add to friends"),
          );
  }
}
