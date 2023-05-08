import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/user.dart';
import '../app_logic/storage.dart';

class ContactCard extends StatelessWidget {
  final User user;

  const ContactCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.width / 3;
    var padding = height / 8;

    return SizedBox(
      height: height,
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Expanded(
            flex: 1,
            child: FutureBuilder(
              future: Storage.downloadURL(user.uid),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CircleAvatar(
                    radius: height * 0.45,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: CircleAvatar(
                      radius: height * 0.42,
                      backgroundColor: Colors.white,
                      foregroundImage: NetworkImage(snapshot.data!),
                    ),
                  );
                } else {
                  return Icon(
                    Icons.account_circle,
                    color: Colors.grey,
                    size: height,
                  );
                }
              },
            ),
          ),
          Flexible(
            flex: 2,
            child: Padding(
              padding:
                  EdgeInsets.fromLTRB(padding / 2, padding, padding, padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${user.name} ${user.surname}",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).textScaleFactor * 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat.yMd().format(user.birthday!),
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).textScaleFactor * 15,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
