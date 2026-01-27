import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullScreenImageViewer extends StatelessWidget {
  final List? imageUrls;
  final bool? url;
  bool? file = false;
  bool? one = false;
  bool? thum = false;
  var image;
  final int initialIndex;

  FullScreenImageViewer({super.key, required this.imageUrls,
    this.one,
    this.image,
    required this.initialIndex,required this.url, this.file, this.thum});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading:GestureDetector(
            onTap: (){
              context.pop(context);
            },
            child:const Icon(Icons.arrow_back, color: Color(0xffFFFFFF),)),
      ),
      body: PhotoViewGallery.builder(
        itemCount: imageUrls!.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage((one == true) ? image:(url == false)?imageUrls!
                :(file == true)? (thum == false)?imageUrls![index].file : (imageUrls![index].projectUnitsMainThumb.isNotEmpty)?
            imageUrls![index].projectUnitsMainThumb![0].file : "":imageUrls![index]['file']),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}