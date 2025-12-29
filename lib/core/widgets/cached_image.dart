import 'package:cached_network_image/cached_network_image.dart';
import 'package:exam_app/core/widgets/cache_manager.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the imageUrl is a network URL (http or https)
    if (_isNetworkUrl(imageUrl)) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        cacheManager: MyAppCacheManager(),
        placeholder: (context, url) =>
            placeholder ?? const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) =>
            errorWidget ?? const Icon(Icons.error),
      );
    } else if (_isAssetPath(imageUrl)) {
      // Handle local asset images
      return Image.asset(
        imageUrl,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? const Icon(Icons.error),
      );
    } else {
      File(imageUrl).existsSync();
      // Handle local file images
      return Image.file(
        File("$imageUrl.jpg"),
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? const Icon(Icons.error),
      );
    }
  }

  /// Check if the provided URL is a network URL
  bool _isNetworkUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  /// Check if the provided path is an asset path
  bool _isAssetPath(String path) {
    return path.startsWith('assets/') || path.startsWith('packages/');
  }
}
