import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';
import '../components/app_bottom_nav_bar.dart';
import '../components/app_header.dart'; // Added import for AppHeader

class ProfilePage extends StatelessWidget { // Renamed from ImprovedProfileScreen
  final AuthService authService;

  const ProfilePage({super.key, required this.authService}); // Renamed constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      appBar: AppHeader(
        showActualSearchBar: false,
        searchPlaceholderText: 'Поиск по профилю',
        onSearchPlaceholderTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Поиск по профилю пока не реализован'),
              backgroundColor: Color(0xFF388E3C),
              duration: Duration(seconds: 2),
            ),
          );
        },
        onSettingsPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Настройки профиля пока не реализованы'),
              backgroundColor: Color(0xFF388E3C),
              duration: Duration(seconds: 2),
            ),
          );
        },
        onNotificationPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Уведомления пока не реализованы'),
              backgroundColor: Color(0xFF388E3C),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileHeader(context),
                    const SizedBox(height: 32),
                    _buildSection(
                        context: context,
                        title: 'My mods',
                        count: 14,
                        children: _buildModCards(),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Раздел "My mods" пока не реализован'),
                              backgroundColor: Color(0xFF388E3C),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }),
                    _buildSectionDivider(),
                    _buildSection(
                        context: context,
                        title: 'My reviews',
                        count: 1337,
                        children: _buildReviewCards(),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Раздел "My reviews" пока не реализован'),
                              backgroundColor: Color(0xFF388E3C),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }),
                    _buildSectionDivider(),
                    _buildSection(
                        context: context,
                        title: 'My comments',
                        count: 228,
                        children: _buildCommentCards(),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Раздел "My comments" пока не реализован'),
                              backgroundColor: Color(0xFF388E3C),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }),
                    _buildSectionDivider(),
                    _buildSection(
                        context: context,
                        title: 'My downloaded mods',
                        count: 88,
                        children: _buildModCards(),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Раздел "My downloaded mods" пока не реализован'),
                              backgroundColor: Color(0xFF388E3C),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }),
                    const SizedBox(height: 32),
                    _buildHistorySection(context),
                  ],
                ),
              ),
            ),
            AppBottomNavBar(activeIndex: 2, authService: authService),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF181F2A),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF374151), width: 2),
          ),
          child: Icon(
            Icons.person,
            size: 60,
            color: const Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
                context,
                Icon(Icons.edit, color: const Color(0xFF9CA3AF), size: 20),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Редактирование профиля пока не реализовано'),
                        backgroundColor: Color(0xFF388E3C),
                        duration: Duration(seconds: 2)),
                  );
                }),
            const SizedBox(width: 12),
            _buildActionButton(
                context,
                SvgPicture.asset(
                  'lib/icons/profile/friends.svg',
                  colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn),
                  width: 20,
                  height: 20,
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Раздел "Друзья" пока не реализован'),
                        backgroundColor: Color(0xFF388E3C),
                        duration: Duration(seconds: 2)),
                  );
                }),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, Widget iconWidget, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Действие для этой кнопки не определено'),
                  backgroundColor: Color(0xFF388E3C),
                  duration: Duration(seconds: 2)),
            );
          },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF374151)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: iconWidget),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required int count,
    required List<Widget> children,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Переход к разделу "$title" пока не реализован'),
                  backgroundColor: const Color(0xFF388E3C),
                  duration: const Duration(seconds: 2)),
            );
          },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF374151), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF374151),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      color: const Color(0xFFE5E7EB),
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: const Color(0xFF9CA3AF),
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: children),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF374151),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  List<Widget> _buildModCards() {
    final modNames = ['Реалистичная физика', 'Новые автомобили', 'Улучшенная графика', 'Дополнительные карты', 'Новые звуки'];
    return List.generate(5, (index) {
      return Container(
        margin: const EdgeInsets.only(right: 12),
        child: _buildModCard(
          title: modNames[index % modNames.length],
          imageAsset: 'lib/icons/main/mod_test_pfp.png',
        ),
      );
    });
  }

  List<Widget> _buildReviewCards() {
    return List.generate(5, (index) {
      return Container(
        margin: const EdgeInsets.only(right: 12),
        child: _buildReviewCard(
          title: 'Reviewed Mod ${index + 1}',
          rating: 4 + (index % 2),
          imageAsset: 'lib/icons/main/mod_test_pfp.png',
        ),
      );
    });
  }

  List<Widget> _buildCommentCards() {
    return List.generate(5, (index) {
      return Container(
        margin: const EdgeInsets.only(right: 12),
        child: _buildCommentCard(
          title: 'Commented Mod ${index + 1}',
          comment: 'Great mod!',
          imageAsset: 'lib/icons/main/mod_test_pfp.png',
        ),
      );
    });
  }

  Widget _buildModCard({required String title, required String imageAsset}) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF374151)),
              color: const Color(0xFF1F2937),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF374151),
                    child: Icon(
                      Icons.image,
                      color: const Color(0xFF9CA3AF),
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container( 
            height: 40.0, 
            alignment: Alignment.topLeft, 
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({required String title, required int rating, required String imageAsset}) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF374151)),
              color: const Color(0xFF1F2937),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF374151),
                    child: Icon(
                      Icons.image,
                      color: const Color(0xFF9CA3AF),
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                Icons.star,
                size: 12,
                color: index < rating ? Colors.amber : const Color(0xFF374151),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard({required String title, required String comment, required String imageAsset}) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF374151)),
              color: const Color(0xFF1F2937),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF374151),
                    child: Icon(
                      Icons.image,
                      color: const Color(0xFF9CA3AF),
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            comment,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xBF9B9B9B),
              fontSize: 11,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF374151), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Last downloaded',
            style: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _buildModCards().take(3).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Last viewed',
            style: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _buildModCards().take(3).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
