import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class MultipleImages extends StatefulWidget {
  final List<String> images;
  final int i;
  MultipleImages(this.images, this.i);
  @override
  _MultipleImagesState createState() => _MultipleImagesState();
}

class _MultipleImagesState extends State<MultipleImages> {
  @override
  Widget build(BuildContext context) {
    return Container(
        // height: MediaQuery.of(context).size.height*0.7,
        child: PhotoViewGallery.builder(
      pageController: PageController(initialPage: widget.i),
      gaplessPlayback: true,
      scrollPhysics: const BouncingScrollPhysics(),
      builder: (BuildContext context, int index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(widget.images[index]),
          initialScale: PhotoViewComputedScale.contained * 0.95,
          heroAttributes: PhotoViewHeroAttributes(tag: widget.i),
          onTapDown: (context, details, controllerValue) =>
              Navigator.of(context).pop(),
        );
      },
      itemCount: widget.images.length,
    ));
  }
}
