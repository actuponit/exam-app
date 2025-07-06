import 'package:cached_network_image/cached_network_image.dart';
import 'package:exam_app/core/widgets/cache_manager.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, Object)? errorWidget;

  const CachedImage(
      {super.key,
      required this.imageUrl,
      this.fit = BoxFit.cover,
      this.placeholder,
      this.errorWidget});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      cacheManager: MyAppCacheManager(),
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}
