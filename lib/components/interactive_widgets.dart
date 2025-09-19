import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Custom SVG Icon Widget
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

// Interactive Search Bar Component
class InteractiveSearchBar extends StatefulWidget {
final String placeholder;
final ValueChanged<String>? onSearchPressed;
final VoidCallback? onFilterPressed;
final VoidCallback? onSettingsPressed;
final VoidCallback? onNotificationPressed;
  final String? searchQuery;

const InteractiveSearchBar({
super.key,
this.placeholder = 'Поиск модов',
this.onSearchPressed,
this.onFilterPressed,
this.onSettingsPressed,
  this.onNotificationPressed,
    this.searchQuery,
});

  @override
  State<InteractiveSearchBar> createState() => _InteractiveSearchBarState();
}

class _InteractiveSearchBarState extends State<InteractiveSearchBar> {
bool _isSearchFocused = false;
bool _isFilterHovered = false;
bool _isSettingsHovered = false;
  bool _isNotificationHovered = false;
late TextEditingController _searchController;
late FocusNode _searchFocusNode;

@override
void initState() {
super.initState();
_searchController = TextEditingController(text: widget.searchQuery ?? '');
_searchFocusNode = FocusNode();
_searchFocusNode.addListener(() {
  setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
      });
  });
}

@override
void dispose() {
  _searchController.dispose();
    _searchFocusNode.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
return Container(
padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
child: Row(
children: [
// Search Input with integrated search icon
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
prefixIcon: Padding(
padding: const EdgeInsets.all(13.0),
child: SvgIcon(
assetPath: 'lib/icons/main/Search.svg',
size: 20,
color: const Color(0xBF9B9B9B),
),
),
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
    onSubmitted: (value) {
      widget.onSearchPressed?.call(value);
    },
onChanged: (value) {
// Можно добавить живой поиск здесь если нужно
},
),
),
),

// Show filter button only when search is focused
AnimatedContainer(
duration: const Duration(milliseconds: 200),
width: _isSearchFocused ? 53 : 0, // 46 + 7 margin
child: _isSearchFocused 
      ? Row(
          children: [
            const SizedBox(width: 7),
            _buildActionButton(
              isHovered: _isFilterHovered,
            onHoverChanged: (hovered) => setState(() => _isFilterHovered = hovered),
            onPressed: widget.onFilterPressed,
            icon: 'lib/icons/main/Filter.svg',
          ),
          ],
          )
          : null,
      ),
        
          // Settings button - always visible
          const SizedBox(width: 7),
          _buildActionButton(
            isHovered: _isSettingsHovered,
            onHoverChanged: (hovered) => setState(() => _isSettingsHovered = hovered),
            onPressed: widget.onSettingsPressed,
            icon: 'lib/icons/main/Gear.svg',
          ),
          
          // Notification button - always visible
          const SizedBox(width: 7),
          _buildActionButton(
            isHovered: _isNotificationHovered,
            onHoverChanged: (hovered) => setState(() => _isNotificationHovered = hovered),
            onPressed: widget.onNotificationPressed,
            icon: 'lib/icons/main/Notification.svg',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required bool isHovered,
    required ValueChanged<bool> onHoverChanged,
    required VoidCallback? onPressed,
    required String icon,
  }) {
    return MouseRegion(
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovered 
                  ? const Color(0xFF388E3C) 
                  : const Color(0xFF374151),
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
      ),
    );
  }
}

// Interactive Period Button Component
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

// Star Rating Component
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
            assetPath: 'lib/icons/main/Star.svg',
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

// Interactive Tag Component
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

// Interactive Bottom Navigation Item
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
