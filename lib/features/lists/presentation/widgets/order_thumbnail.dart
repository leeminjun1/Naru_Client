import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_asset_image.dart';

class OrderThumbnail extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final IconData fallbackIcon;

  const OrderThumbnail({
    super.key,
    required this.imageUrl,
    this.width = 80,
    this.height = 80,
    this.fallbackIcon = Icons.store,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
        color: const Color(0xFFF3F5F7),
      ),
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    final path = imageUrl?.trim();
    if (path == null || path.isEmpty) return _fallback();

    if (path.startsWith('assets/')) {
      return AppAssetImage(
        assetPath: path,
        fit: BoxFit.cover,
        fallback: _fallback(),
      );
    }

    return Image.network(
      _resolveNetworkUrl(path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  String _resolveNetworkUrl(String path) {
    final uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme) return path;

    final baseUri = Uri.tryParse(AppConfig.baseUrl);
    if (baseUri == null || !baseUri.hasScheme) return path;

    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return baseUri.replace(path: normalizedPath, query: null).toString();
  }

  Widget _fallback() {
    return Center(
      child: Icon(
        fallbackIcon,
        color: AppColors.textMuted,
      ),
    );
  }
}
