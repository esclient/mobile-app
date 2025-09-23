import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../model/mod_item.dart';
import '../components/interactive_widgets.dart';

/// Optimized version of ModCard with better performance
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
    return GestureDetector(
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
    );
  }

  Widget _buildLeftSection() {
    return Column(
      children: [
        // Optimized image loading with caching
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
    // Check if it's a network image or local asset
    if (mod.imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: mod.imageUrl,
        width: 48,
        height: 48,
        memCacheWidth: 96, // Cache at 2x resolution for retina displays
        memCacheHeight: 96,
        fit: BoxFit.cover,
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
      // Local asset image
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Star rating
        StarRating(
          rating: mod.rating,
          starSize: 10,
        ),
        const SizedBox(height: 2),
        
        // Rating number
        Text(
          mod.rating.toStringAsFixed(1),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFF59E0B),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 1.71,
          ),
        ),
        
        // Rating count
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
        // Title
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
        
        // Description
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
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 10),
        
        // Tags - optimized to show only essential tags
        if (mod.tags.isNotEmpty)
          SizedBox(
            height: 26,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mod.tags.length > 5 ? 5 : mod.tags.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InteractiveTag(
                    text: mod.tags[index],
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Фильтр по тегу "${mod.tags[index]}"'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: const Color(0xFF388E3C),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}