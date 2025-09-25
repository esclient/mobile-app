import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_svg/flutter_svg.dart';

import 'search_bar.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onNotificationPressed;

  // For search placeholder (e.g., Profile Screen)
  final VoidCallback? onSearchPlaceholderTap;
  final String? searchPlaceholderText;

  // For actual InteractiveSearchBar (e.g., Mods List Screen)
  final bool showActualSearchBar;
  final String? searchQuery;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback?
  onFilterPressed; // Filter button is part of InteractiveSearchBar

  const AppHeader({
    super.key,
    this.onSettingsPressed,
    this.onNotificationPressed,
    this.onSearchPlaceholderTap,
    this.searchPlaceholderText,
    this.showActualSearchBar = false,
    this.searchQuery,
    this.onSearchSubmitted,
    this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget headerContent;

    if (showActualSearchBar) {
      // Content for ModsListPage: Expanded InteractiveSearchBar + AppHeader's own action buttons
      headerContent = Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SearchBar(
                    initialValue: searchQuery,
                    onSubmitted: onSearchSubmitted ?? (value) {},
                    onFilterPressed: onFilterPressed,
                    hintText: 'Поиск модов...',
                  ),
                ),
              ],
            ),
          ),
          // Action buttons rendered by AppHeader itself
          if (onSettingsPressed != null) ...[
            const SizedBox(width: 8),
            _buildActionButton(
              iconAsset: 'lib/icons/header/gear.svg',
              onTap: onSettingsPressed!,
              context: context,
              tooltip:
                  'Настройки пока не реализованы', // Generic tooltip or could be passed
            ),
          ],
          if (onNotificationPressed != null) ...[
            const SizedBox(width: 8),
            _buildActionButton(
              iconAsset: 'lib/icons/header/notification.svg',
              onTap: onNotificationPressed!,
              context: context,
              tooltip:
                  'Уведомления пока не реализованы', // Generic tooltip or could be passed
            ),
          ],
        ],
      );
    } else if (searchPlaceholderText != null &&
        onSearchPlaceholderTap != null) {
      // Content for ImprovedProfileScreen (Search placeholder + external action buttons)
      headerContent = Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onSearchPlaceholderTap,
              child: Container(
                height: 50, // Matches InteractiveSearchBar internal height
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937), // Background color matching screen background
                  border: Border.all(color: const Color(0xFF374151)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    SvgPicture.asset(
                      'lib/icons/header/search.svg',
                      colorFilter: const ColorFilter.mode(
                        Color(0xBF9B9B9B),
                        BlendMode.srcIn,
                      ),
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      searchPlaceholderText!,
                      style: const TextStyle(
                        color: Color(0xBF9B9B9B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // External action buttons for screens without InteractiveSearchBar
          if (onSettingsPressed != null) ...[
            const SizedBox(width: 8),
            _buildActionButton(
              iconAsset: 'lib/icons/header/gear.svg',
              onTap: onSettingsPressed!,
              context: context,
              tooltip: 'Настройки профиля пока не реализованы',
            ),
          ],
          if (onNotificationPressed != null) ...[
            const SizedBox(width: 8),
            _buildActionButton(
              iconAsset: 'lib/icons/header/notification.svg',
              onTap: onNotificationPressed!,
              context: context,
              tooltip: 'Уведомления пока не реализованы',
            ),
          ],
        ],
      );
    } else {
      // Fallback for a simple title or empty header if needed
      headerContent = const SizedBox.shrink();
    }

    return Container(
      height: preferredSize.height,
      // 74.0
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      // Content area padding
      decoration: const BoxDecoration(
        color: Color(0xFF1F2937),
        border: Border(bottom: BorderSide(color: Color(0xFF374151), width: 1)),
      ),
      child: Center(
        // Added Center to ensure vertical alignment if content is shorter than 50px
        child: SizedBox(
          height: 50, // Explicit height for the content row
          child: headerContent,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String iconAsset,
    required VoidCallback onTap,
    required BuildContext context, // Needed for ScaffoldMessenger
    required String tooltip, // For the SnackBar message
  }) {
    // This button is 46x46, plus SizedBox(width:8) gives 54.
    // The container padding is 12, so total height of AppHeader is 74.
    // The content row is 50px high. This button will be centered within that 50px.
    return SizedBox(
      width: 46, // Standard width for these action buttons
      height: 46, // Standard height for these action buttons
      child: GestureDetector(
        onTap: () {
          // Show the tooltip message (same as notifications behavior)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tooltip),
              duration: const Duration(seconds: 2),
              backgroundColor: const Color(0xFF388E3C),
            ),
          );
          onTap(); // Call the original onTap passed to AppHeader
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF374151)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: SvgPicture.asset(
              iconAsset,
              colorFilter: const ColorFilter.mode(
                Color(0xBF9B9B9B),
                BlendMode.srcIn,
              ),
              width: 20,
              height: 20,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(74.0); // Consistent height
}
