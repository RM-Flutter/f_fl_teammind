import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Widget that can display both asset images and network images
/// Automatically detects if the imageUrl is a network URL or asset path
class DynamicImageWidget extends StatelessWidget {
  const DynamicImageWidget({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.errorWidget,
  });

  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget? errorWidget;

  bool get _isNetworkImage {
    // Return false if imageUrl is null or empty
    if (imageUrl.isEmpty) {
      return false;
    }
    return imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    // If imageUrl is empty, show error widget or default icon
    if (imageUrl.isEmpty) {
      return errorWidget ?? const Icon(Icons.image_not_supported_outlined);
    }
    
    if (_isNetworkImage) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: width,
        fit: fit,
        errorWidget: (context, url, error) =>
            errorWidget ??
            const Icon(Icons.image_not_supported_outlined),
      );
    } else {
      return Image.asset(
        imageUrl,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ??
            const Icon(Icons.image_not_supported_outlined),
      );
    }
  }
}

