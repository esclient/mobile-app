import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

/// Enum for different search bar states
enum SearchBarStates {
  idle,
  searching,
  results,
  noResults,
  error,
}

/// Main search bar component used throughout the app
class SearchBar extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onFilterPressed;
  final Duration debounceDelay;
  final String hintText;
  final ValueChanged<TextEditingController>? onControllerCreated;
  
  const SearchBar({
    super.key,
    this.initialValue,
    required this.onSubmitted,
    this.onFilterPressed,
    this.debounceDelay = const Duration(milliseconds: 500),
    this.hintText = 'Find something',
    this.onControllerCreated,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> 
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _filterAnimationController;
  late Animation<double> _filterAnimation;
  Timer? _debounceTimer;
  bool _isSearchFocused = false;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _focusNode = FocusNode();
    
    // Notify parent about controller creation
    widget.onControllerCreated?.call(_controller);
    
    // Animation controller for filter button
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _filterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }
  
  void _onFocusChange() {
    final bool newFocusState = _focusNode.hasFocus;
    if (newFocusState != _isSearchFocused) {
      setState(() {
        _isSearchFocused = newFocusState;
      });
      
      if (_isSearchFocused) {
        _filterAnimationController.forward();
      } else {
        _filterAnimationController.reverse();
      }
    }
  }

  void _onTextChanged(String value) {
    // Removed auto-search functionality
    // Search will only happen on submit (Enter press)
    _debounceTimer?.cancel();
    setState(() {}); // Rebuild to update UI
  }
  
  @override
  void didUpdateWidget(SearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller text if initialValue changes
    if (widget.initialValue != oldWidget.initialValue && 
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: ShapeDecoration(
              color: const Color(0xFF1F2937), // Background color matching screen background
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: _isSearchFocused 
                      ? const Color(0xFF388E3C) // Green border when focused
                      : const Color(0xFF374151), // Gray border when not focused
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Search icon with proper padding
                const SizedBox(width: 10),
                SvgPicture.asset(
                  'lib/icons/header/search.svg',
                  width: 20.88,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    Color(0xBF9B9B9B), 
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 13),
                // Text field without any borders
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: _onTextChanged,
                    onSubmitted: widget.onSubmitted,
                    style: const TextStyle(
                      color: Color(0xFF9C9C9C), // Text color from mockup
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: const TextStyle(
                        color: Color(0xBF9B9B9B), // Hint color from mockup
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                      // Completely remove all borders
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      // Remove background fill
                      filled: false,
                      fillColor: Colors.transparent,
                      // Remove all padding - we handle it with Row layout
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      // Remove default constraints
                      isCollapsed: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
        // Animated filter button
        AnimatedBuilder(
          animation: _filterAnimation,
          builder: (context, child) {
            if (_filterAnimation.value == 0.0) {
              return const SizedBox.shrink();
            }
            
            return Row(
              children: [
                SizedBox(width: 8 * _filterAnimation.value),
                Transform.scale(
                  scale: _filterAnimation.value,
                  child: Opacity(
                    opacity: _filterAnimation.value,
                    child: Container(
                      width: 44.29,
                      height: 46,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1,
                            color: Color(0xFF374151),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: widget.onFilterPressed,
                        child: Center(
                          child: SvgPicture.asset(
                            'lib/icons/header/filter.svg',
                            width: 19.26,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              Color(0xBF9B9B9B), 
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Demo widget showing different search bar states for testing
class SearchBarDemo extends StatelessWidget {
  const SearchBarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Default state
        const Text(
          '1. Неактивное состояние:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _buildSearchBarState(
          isActive: false,
          hasText: false,
          showFilter: false,
          borderColor: const Color(0xFF374151),
          hintText: 'Find something',
        ),
        const SizedBox(height: 20),
        
        // Active state with green border
        const Text(
          '2. Активное состояние (зеленая граница):',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _buildSearchBarState(
          isActive: true,
          hasText: false,
          showFilter: false,
          borderColor: const Color(0xFF388E3C),
          hintText: 'Find something',
        ),
        const SizedBox(height: 20),
        
        // Active state with filter button and text input
        const Text(
          '3. Активное с кнопкой фильтра и курсором:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _buildSearchBarState(
          isActive: true,
          hasText: true,
          showFilter: true,
          borderColor: const Color(0xFF388E3C),
          hintText: '',
          textValue: '|', // Cursor representation
        ),
        const SizedBox(height: 20),
        
        // Input value state
        const Text(
          '4. С введенным значением:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _buildSearchBarState(
          isActive: false,
          hasText: true,
          showFilter: false,
          borderColor: const Color(0xFF374151),
          hintText: '',
          textValue: 'Input value',
        ),
      ],
    );
  }
  
  Widget _buildSearchBarState({
    required bool isActive,
    required bool hasText,
    required bool showFilter,
    required Color borderColor,
    required String hintText,
    String? textValue,
  }) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: borderColor,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'lib/icons/header/search.svg',
                    width: 20.88,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Color(0xBF9B9B9B), 
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      hasText ? (textValue ?? '') : hintText,
                      style: TextStyle(
                        color: hasText 
                            ? (textValue == '|' ? const Color(0xFF9C9C9C) : const Color(0xBF9B9B9B))
                            : const Color(0xBF9B9B9B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showFilter) ...[ 
          const SizedBox(width: 8),
          Container(
            width: 44.29,
            height: 46,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1,
                  color: Color(0xFF374151),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Center(
              child: SvgPicture.asset(
                'lib/icons/header/filter.svg',
                width: 19.26,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  Color(0xBF9B9B9B), 
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
