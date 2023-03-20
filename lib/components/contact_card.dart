import 'package:flutter/material.dart';

class ContactCard extends StatelessWidget {
  final String imageLink;
  final String name;
  final String
      bio; // remove if no bio is intended to be (or replace with something else)

  const ContactCard(this.imageLink, this.name, this.bio, {super.key});

  @override
  Widget build(BuildContext context) {
    var containerWidth = MediaQuery.of(context).size.width / 3;
    var padding = containerWidth / 8;
    containerWidth = containerWidth - 2 * padding;

    return Flex(
      direction: Axis.horizontal,
      children: [
        Expanded(
          flex: 1,
          child: Padding(
              padding: EdgeInsets.all(padding),
              child: Container(
                height: containerWidth,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius:
                        BorderRadius.all(Radius.circular(containerWidth / 2)),
                    image: DecorationImage(image: NetworkImage(imageLink))
                ),
              )
          ),
        ),
        Expanded(
            flex: 2,
            child: Padding(
              padding:
                  EdgeInsets.fromLTRB(padding / 2, padding, padding, padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).textScaleFactor * 22,
                        fontWeight: FontWeight.bold,
                      )),
                  Text(
                    bio,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).textScaleFactor * 15,
                    ),
                  )
                ],
              ),
            )
        )
      ],
    );
  }
}
