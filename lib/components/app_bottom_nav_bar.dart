import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';
import '../pages/login_page.dart'; // Assuming LoginPage is in lib/pages/
import '../utils/constants.dart'; // Added for AppRoutes

class AppBottomNavBar extends StatelessWidget {
  final int activeIndex;
  final AuthService authService;

  const AppBottomNavBar({
    super.key,
    required this.activeIndex,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF1F2937),
        border: Border(
          top: BorderSide(color: Color(0xFF374151), width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              context: context,
              label: 'Главная',
              iconPath: 'lib/icons/footer/home.svg',
              isActive: activeIndex == 0,
              onTap: () {
                if (activeIndex != 0) {
                  // Pop all routes until the first one (ModsListPage)
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              },
            ),
            _buildNavItem(
              context: context,
              label: 'Закладки',
              iconPath: 'lib/icons/footer/favorite.svg',
              isActive: activeIndex == 1,
              onTap: () {
                // Placeholder for Bookmarks page navigation if it existed
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Раздел "Закладки" пока не реализован'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Color(0xFF388E3C),
                  ),
                );
                // if (activeIndex != 1) {
                //   Navigator.pushNamed(context, '/bookmarks_page'); // Example
                // }
              },
            ),
            _buildNavItem(
              context: context,
              label: 'Профиль',
              iconPath: 'lib/icons/footer/profile.svg',
              isActive: activeIndex == 2,
              onTap: () {
                if (activeIndex != 2) {
                  if (authService.isLoggedIn) {
                    Navigator.pushNamed(context, AppRoutes.profile); // Changed to AppRoutes.profile
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(authService: authService),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required String label,
    required String iconPath,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final Color iconColor = isActive ? const Color(0xFF388E3C) : const Color(0xFF9CA3AF);
    return Expanded(
      child: GestureDetector(
        onTap: isActive ? null : onTap, // Only allow tap if not already on this screen
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              width: 24,
              height: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: iconColor,
                fontSize: 12,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
