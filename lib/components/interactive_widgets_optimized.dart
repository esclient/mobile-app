import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Custom SVG Icon Widget with better error handling
class SvgIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color? color;

  const SvgIcon({
    super.key,
    required this.assetPath,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: color != null 
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
      placeholderBuilder: (BuildContext context) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color?.withValues(alpha: 0.3) ?? Colors.grey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.image_not_supported,
            size: size * 0.6,
            color: color ?? Colors.grey,
          ),
        );
      },
    );
  }
}

// Optimized Search Bar with debouncing
class OptimizedSearchBar extends StatefulWidget {
  final String placeholder;
  final ValueChanged<String>? onSearchSubmitted;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterPressed;
  final String? initialValue;
  final Duration debounceDuration;

  const OptimizedSearchBar({
    super.key,
    this.placeholder = 'Поиск модов',
    this.onSearchSubmitted,
    this.onSearchChanged,
    this.onFilterPressed,
    this.initialValue,
    this.debounceDuration = const Duration(milliseconds: 500),
  });

  @override
  State<OptimizedSearchBar> createState() => _OptimizedSearchBarState();
}

class _OptimizedSearchBarState extends State<OptimizedSearchBar> {
  bool _isSearchFocused = false;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialValue ?? '');
    _searchFocusNode = FocusNode();
    _searchFocusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(OptimizedSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _searchController.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    }
  }

  void _onTextChanged(String value) {
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Start new timer for debouncing
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (widget.onSearchChanged != null) {
        widget.onSearchChanged!(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: const TextStyle(
                  color: Color(0xBF9B9B9B),
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(13.0),
                  child: SvgIcon(
                    assetPath: 'lib/icons/header/search.svg',
                    size: 20,
                    color: Color(0xBF9B9B9B),
                  ),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _onTextChanged('');
                          if (widget.onSearchSubmitted != null) {
                            widget.onSearchSubmitted!('');
                          }
                        },
                        icon: const Icon(
                          Icons.clear,
                          color: Color(0xBF9B9B9B),
                          size: 20,
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF374151),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF374151),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF388E3C),
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                fillColor: Colors.transparent,
                filled: true,
              ),
              onSubmitted: widget.onSearchSubmitted,
              onChanged: _onTextChanged,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: _isSearchFocused ? 53 : 0, 
          child: _isSearchFocused
              ? Row(
                  children: [
                    const SizedBox(width: 7),
                    _buildActionButton(
                      onPressed: widget.onFilterPressed,
                      icon: 'lib/icons/header/filter.svg',
                    ),
                  ],
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required String icon,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF374151),
            width: 1,
          ),
        ),
        child: Center(
          child: SvgIcon(
            assetPath: icon,
            size: 20,
            color: const Color(0xBF9B9B9B),
          ),
        ),
      ),
    );
  }
}

// Legacy InteractiveSearchBar for backward compatibility
class InteractiveSearchBar extends StatelessWidget {
  final String placeholder;
  final ValueChanged<String>? onSearchPressed;
  final VoidCallback? onFilterPressed;
  final String? searchQuery;

  const InteractiveSearchBar({
    super.key,
    this.placeholder = 'Поиск модов',
    this.onSearchPressed,
    this.onFilterPressed,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return OptimizedSearchBar(
      placeholder: placeholder,
      onSearchSubmitted: onSearchPressed,
      onSearchChanged: onSearchPressed,
      onFilterPressed: onFilterPressed,
      initialValue: searchQuery,
    );
  }
}

// Optimized Period Button with const constructors where possible
class PeriodButton extends StatefulWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onPressed;

  const PeriodButton({
    super.key,
    required this.text,
    this.isSelected = false,
    this.onPressed,
  });

  @override
  State<PeriodButton> createState() => _PeriodButtonState();
}

class _PeriodButtonState extends State<PeriodButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 43,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: widget.isSelected ? const Color(0xFF388E3C) : null,
            border: Border.all(
              color: widget.isSelected 
                  ? const Color(0xFF388E3C)
                  : _isHovered
                      ? const Color(0xFF388E3C)
                      : const Color(0xFF374151),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              widget.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Optimized Star Rating with const constructors
class StarRating extends StatelessWidget {
  final double rating;
  final int maxStars;
  final double starSize;

  const StarRating({
    super.key,
    required this.rating,
    this.maxStars = 5,
    this.starSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index < maxStars - 1 ? 2 : 0),
          child: SvgIcon(
            assetPath: 'lib/icons/main/star.svg',
            size: starSize,
            color: index < rating.floor() 
                ? const Color(0xFFF59E0B) 
                : const Color(0xFF374151),
          ),
        );
      }),
    );
  }
}

// Optimized Interactive Tag
class InteractiveTag extends StatefulWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onPressed;

  const InteractiveTag({
    super.key,
    required this.text,
    this.isSelected = false,
    this.onPressed,
  });

  @override
  State<InteractiveTag> createState() => _InteractiveTagState();
}

class _InteractiveTagState extends State<InteractiveTag> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          decoration: BoxDecoration(
            color: widget.isSelected || _isHovered 
                ? const Color(0xFF388E3C) 
                : const Color(0xFF374151),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected || _isHovered 
                  ? const Color(0xFF388E3C) 
                  : const Color(0xFF374151),
              width: 1,
            ),
          ),
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD1D5DB),
              fontSize: 10,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              height: 1.33,
            ),
          ),
        ),
      ),
    );
  }
}

// Optimized Bottom Navigation Item
class BottomNavItem extends StatefulWidget {
  final String label;
  final String iconPath;
  final bool isActive;
  final VoidCallback? onPressed;

  const BottomNavItem({
    super.key,
    required this.label,
    required this.iconPath,
    this.isActive = false,
    this.onPressed,
  });

  @override
  State<BottomNavItem> createState() => _BottomNavItemState();
}

class _BottomNavItemState extends State<BottomNavItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive 
        ? const Color(0xFF388E3C) 
        : _isPressed
            ? const Color(0xFF388E3C)
            : const Color(0xFF9CA3AF);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgIcon(
              assetPath: widget.iconPath,
              size: 20,
              color: color,
            ),
            const SizedBox(height: 1),
            Flexible(
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
