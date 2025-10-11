import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Optimized search input with debouncing
class OptimizedSearchInput extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String> onSubmitted;
  final Duration debounceDelay;

  const OptimizedSearchInput({
    super.key,
    this.initialValue,
    required this.onSubmitted,
    this.debounceDelay = const Duration(milliseconds: 500),
  });

  @override
  State<OptimizedSearchInput> createState() => _OptimizedSearchInputState();
}

class _OptimizedSearchInputState extends State<OptimizedSearchInput> {
  late TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDelay, () {
      widget.onSubmitted(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4B5563), width: 1),
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onTextChanged,
        onSubmitted: widget.onSubmitted,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: 'Поиск модов...',
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.all(12),
            child: SvgIcon(
              assetPath: 'lib/icons/header/search.svg',
              size: 20,
              color: Color(0xFF9CA3AF),
            ),
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
                  onPressed: () {
                    _controller.clear();
                    widget.onSubmitted('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

/// Optimized SVG icon with caching
class SvgIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color? color;

  const SvgIcon({
    super.key,
    required this.assetPath,
    required this.size,
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
      // Enable caching for better performance
      placeholderBuilder: (context) => SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          strokeWidth: 1,
          color: Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}

/// Optimized star rating widget using custom SVG icon
class StarRating extends StatelessWidget {
  final double rating;
  final double starSize;
  final int maxStars;
  final Color activeColor;
  final Color inactiveColor;

  const StarRating({
    super.key,
    required this.rating,
    this.starSize = 16,
    this.maxStars = 5,
    this.activeColor = const Color(0xFFF59E0B),
    this.inactiveColor = const Color(0xFF6B7280),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final starRating = index + 1;
        final isFilled = starRating <= rating;
        return SvgIcon(
          assetPath: 'lib/icons/rating/star.svg',
          size: starSize,
          color: isFilled ? activeColor : inactiveColor,
        );
      }),
    );
  }
}

/// Optimized period button with const constructor
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
    return SizedBox(
      height: 54,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isSelected
                ? const Color(0xFF388E3C)
                : const Color(0xFF374151),
            foregroundColor: Colors.white,
            side: _isHovered && !widget.isSelected
                ? const BorderSide(
                    color: Color(0xFF388E3C),
                    width: 2,
                  )
                : BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
              height: 1.50,
            ),
          ),
        ),
      ),
    );
  }
}

/// Optimized interactive tag with const constructor
class InteractiveTag extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSelected;

  const InteractiveTag({
    super.key,
    required this.text,
    this.onPressed,
    this.isSelected = false,
  });

  @override
  State<InteractiveTag> createState() => _InteractiveTagState();
}

class _InteractiveTagState extends State<InteractiveTag> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isSelected
                ? const Color(0xFF388E3C)
                : const Color(0xFF374151),
            foregroundColor: Colors.white,
            side: _isHovered && !widget.isSelected
                ? const BorderSide(
                    color: Color(0xFF388E3C),
                    width: 2,
                  )
                : BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            elevation: 0,
            shadowColor: Colors.transparent,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              height: 1.17,
            ),
          ),
        ),
      ),
    );
  }
}

/// Optimized loading indicator
class OptimizedLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;

  const OptimizedLoadingIndicator({super.key, this.message, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              color: Color(0xFF388E3C),
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}

/// Optimized error widget
class OptimizedErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String retryButtonText;

  const OptimizedErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.retryButtonText = 'Попробовать снова',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            PeriodButton(text: retryButtonText, onPressed: onRetry),
          ],
        ],
      ),
    );
  }
}

/// Optimized empty state widget
class OptimizedEmptyWidget extends StatelessWidget {
  final String message;
  final String iconPath;
  final VoidCallback? onAction;
  final String? actionText;

  const OptimizedEmptyWidget({
    super.key,
    required this.message,
    this.iconPath = 'lib/icons/footer/home.svg',
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgIcon(
            assetPath: iconPath,
            size: 64,
            color: const Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (onAction != null && actionText != null) ...[
            const SizedBox(height: 16),
            PeriodButton(text: actionText!, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}

/// Optimized shimmer loading effect for better UX
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
              colors: const [
                Color(0xFF374151),
                Color(0xFF4B5563),
                Color(0xFF374151),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
