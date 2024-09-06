import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomAvatar extends StatefulWidget {
  double radius;
  String imageurl;
 CustomAvatar({super.key,
   required this.imageurl,
   required this.radius});

  @override
  State<CustomAvatar> createState() => _CustomAvatarState();
}

class _CustomAvatarState extends State<CustomAvatar> {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: Colors.black,
      child: CachedNetworkImage(
        alignment: Alignment.topCenter,
        imageUrl:widget.imageurl,
        imageBuilder: (context,
            imageProvider) =>
            CircleAvatar(
              radius: widget.radius,
              backgroundImage: imageProvider,
            ),

      ),
    );;
  }
}
