import 'package:flutter/material.dart';
import '../model/mod_item.dart';

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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 134,
          decoration: BoxDecoration(
            color: const Color(0xFF181F2A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF374151)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              _buildLeftColumn(),
              const SizedBox(width: 13),
              Expanded(child: _buildRightColumn()),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Hero(
          tag: 'mod_image_${mod.id}',
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(mod.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        _buildStarsRating(),
        const SizedBox(height: 2),
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

  Widget _buildStarsRating() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(mod.starsCount, (starIndex) {
        return Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(right: 2),
          decoration: const BoxDecoration(
            color: Color(0xFFF59E0B),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildRightColumn() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 19),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFD1D5DB),
                fontSize: 12,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                height: 1.62,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildTags(),
        ],
      ),
    );
  }

  Widget _buildTags() {
    final visibleTags = mod.tags.take(5).toList();
    
    return Wrap(
      spacing: 6,
      runSpacing: 5,
      children: visibleTags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF374151),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF374151)),
          ),
          child: Text(
            tag,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD1D5DB),
              fontSize: 9,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              height: 1.33,
            ),
          ),
        );
      }).toList(),
    );
  }
}
