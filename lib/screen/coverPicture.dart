import 'package:flutter/material.dart';

class CoverPicture extends StatefulWidget {
  final String cover;
  CoverPicture(this.cover);
  @override
  _CoverPictureState createState() => _CoverPictureState();
}

class _CoverPictureState extends State<CoverPicture> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: Image.network(
              widget.cover,
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}