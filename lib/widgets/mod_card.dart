import 'package:flutter/material.dart';
import '../model/mod_item.dart';
import '../components/interactive_widgets.dart';

class ModCard extends StatefulWidget {
  final ModItem mod;
  final VoidCallback? onTap;

  const ModCard({
    super.key,
    required this.mod,
    this.onTap,
  });

  @override
  State<ModCard> createState() => _ModCardState();
}

class _ModCardState extends State<ModCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 134,
          decoration: BoxDecoration(
            color: const Color(0xFF181F2A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered 
                  ? const Color(0xFF388E3C) 
                  : const Color(0xFF374151),
              width: 1,
            ),
            boxShadow: _isHovered 
                ? [
                    BoxShadow(
                      color: const Color(0xFF388E3C).withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left section - Image and rating
                Column(
                  children: [
                    // Mod avatar image
                    Hero(
                      tag: 'mod_image_${widget.mod.id}',
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(
                            image: AssetImage('lib/icons/main/mod_test_pfp.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    
                    // Rating section
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Star rating
                        StarRating(
                          rating: widget.mod.rating,
                          starSize: 10,
                        ),
                        const SizedBox(height: 2),
                        
                        // Rating number
                        Text(
                          widget.mod.rating.toStringAsFixed(1),
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
                          widget.mod.formattedRatingsCount,
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
                    ),
                  ],
                ),
                const SizedBox(width: 13),
                
                // Right section - Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        widget.mod.title,
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
                          widget.mod.description,
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
                      
                      // Tags
                      if (widget.mod.tags.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: widget.mod.tags.take(5).map((tag) {
                            return InteractiveTag(
                              text: tag,
                              onPressed: () {
                                // TODO: Filter by tag
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Фильтр по тегу "$tag"'),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: const Color(0xFF388E3C),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
