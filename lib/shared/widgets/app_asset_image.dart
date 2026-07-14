import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppAssetImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? fallback;

  const AppAssetImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  static final Map<String, Future<ImageProvider?>> _embeddedImageCache = {};

  static Future<ImageProvider?> _loadEmbeddedImage(String assetPath) async {
    try {
      final svg = await rootBundle.loadString(assetPath);
      final match = RegExp(r'base64,([^"\s]+)').firstMatch(svg);
      if (match == null) return null;
      return MemoryImage(base64Decode(match.group(1)!));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!assetPath.toLowerCase().endsWith('.svg')) {
      return Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => fallback ?? const SizedBox.shrink(),
      );
    }

    return FutureBuilder<ImageProvider?>(
      future: _embeddedImageCache.putIfAbsent(
        assetPath,
        () => _loadEmbeddedImage(assetPath),
      ),
      builder: (context, snapshot) {
        final imageProvider = snapshot.data;
        if (imageProvider != null) {
          return Image(
            image: imageProvider,
            width: width,
            height: height,
            fit: fit,
            gaplessPlayback: true,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, __, ___) => fallback ?? const SizedBox.shrink(),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return fallback ?? const SizedBox.shrink();
        }
        return SvgPicture.asset(
          assetPath,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => fallback ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
