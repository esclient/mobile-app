import 'package:flutter/material.dart';
import '../components/interactive_widgets.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  final AuthService authService;

  const ProfilePage({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const SvgIcon(
                      assetPath: 'lib/icons/Return.svg',
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Профиль',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 24), // Для симметрии
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Profile avatar
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF374151),
                        borderRadius: BorderRadius.circular(60),
                        border: Border.all(
                          color: const Color(0xFF388E3C),
                          width: 3,
                        ),
                      ),
                      child: const Center(
                        child: SvgIcon(
                          assetPath: 'lib/icons/main/Profile.svg',
                          size: 60,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // User name
                    Text(
                      authService.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // User email
                    Text(
                      authService.userEmail,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Profile options
                    _buildProfileOption(
                      'Мои модификации',
                      'lib/icons/main/Gear.svg',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Мои модификации пока не реализованы'),
                            backgroundColor: Color(0xFF388E3C),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildProfileOption(
                      'Настройки',
                      'lib/icons/main/Gear.svg',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Настройки пока не реализованы'),
                            backgroundColor: Color(0xFF388E3C),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildProfileOption(
                      'Уведомления',
                      'lib/icons/main/Notification.svg',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Уведомления пока не реализованы'),
                            backgroundColor: Color(0xFF388E3C),
                          ),
                        );
                      },
                    ),

                    const Spacer(),

                    // Logout button
                    GestureDetector(
                      onTap: () {
                        authService.logout();
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Вы вышли из аккаунта'),
                            backgroundColor: Color(0xFF388E3C),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            width: 1,
                            color: Colors.red,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Выйти',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(String title, String iconPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF374151),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF4B5563),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            SvgIcon(
              assetPath: iconPath,
              size: 24,
              color: const Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const SvgIcon(
              assetPath: 'lib/icons/Return.svg',
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}
