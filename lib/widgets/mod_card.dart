import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../model/mod_item.dart';
import '../components/interactive_widgets.dart';

class ModCard extends StatelessWidget {
  final ModItem mod;
  final VoidCallback? onTap;

  const ModCard({
    super.key,
    required this.mod,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 134,
          decoration: BoxDecoration(
            color: const Color(0xFF181F2A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF374151),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLeftSection(),
                const SizedBox(width: 13),
                Expanded(child: _buildRightSection(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftSection() {
    return Column(
      children: [
        Hero(
          tag: 'mod_image_${mod.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildModImage(),
          ),
        ),
        const SizedBox(height: 6),
        _buildRatingSection(),
      ],
    );
  }

  Widget _buildModImage() {
    if (mod.imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: mod.imageUrl,
        width: 48,
        height: 48,
        memCacheWidth: 144,
        memCacheHeight: 144,
        maxWidthDiskCache: 144,
        maxHeightDiskCache: 144,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 100),
        placeholder: (context, url) => Container(
          width: 48,
          height: 48,
          color: const Color(0xFF374151),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 48,
          height: 48,
          color: const Color(0xFF374151),
          child: const Icon(
            Icons.image_not_supported,
            color: Color(0xFF9CA3AF),
            size: 24,
          ),
        ),
      );
    } else {
      return Image.asset(
        'lib/icons/main/mod_test_pfp.png',
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 48,
            height: 48,
            color: const Color(0xFF374151),
            child: const Icon(
              Icons.image_not_supported,
              color: Color(0xFF9CA3AF),
              size: 24,
            ),
          );
        },
      );
    }
  }

  Widget _buildRatingSection() {
    final ratingText = mod.rating.toStringAsFixed(1);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StarRating(
          rating: mod.rating,
          starSize: 10,
        ),
        const SizedBox(height: 2),
        Text(
          ratingText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFF59E0B),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 1.71,
          ),
        ),
        Text(
          mod.formattedRatingsCount,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 7,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 2.29,
          ),
        ),
      ],
    );
  }

  Widget _buildRightSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          mod.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            height: 1.50,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Text(
            mod.description,
            style: const TextStyle(
              color: Color(0xFFD1D5DB),
              fontSize: 12,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              height: 1.62,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 10),
        if (mod.tags.isNotEmpty)
          SizedBox(
            height: 26,
            child: _TagsList(tags: mod.tags),
          ),
      ],
    );
  }
}

class _TagsList extends StatelessWidget {
  final List<String> tags;

  const _TagsList({required this.tags});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: tags.length > 5 ? 5 : tags.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: InteractiveTag(
            text: tags[index],
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Фильтр по тегу "${tags[index]}"'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: const Color(0xFF388E3C),
                ),
              );
            },
          ),
        );
      },
    );
  }
}