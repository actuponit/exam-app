import 'package:cached_network_image/cached_network_image.dart';
import 'package:exam_app/core/widgets/cache_manager.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;

  const CachedImage(
      {super.key, required this.imageUrl, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      cacheManager: MyAppCacheManager(),
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}
