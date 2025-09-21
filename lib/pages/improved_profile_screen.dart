import 'package:flutter/material.dart';

class ImprovedProfileScreen extends StatelessWidget {
  const ImprovedProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      body: SafeArea(
        child: Column(
          children: [
            // Header with search
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                border: Border(
                  bottom: BorderSide(color: const Color(0xFF374151), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF374151)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(Icons.search, color: const Color(0xBF9B9B9B), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Поиск по профилю',
                            style: TextStyle(
                              color: const Color(0xBF9B9B9B),
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF374151)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.tune, color: const Color(0xBF9B9B9B)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF374151)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.menu, color: const Color(0xBF9B9B9B)),
                  ),
                ],
              ),
            ),
            
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profile header
                    _buildProfileHeader(),
                    
                    const SizedBox(height: 32),
                    
                    // My mods section
                    _buildSection(
                      title: 'My mods',
                      count: 14,
                      children: _buildModCards(),
                    ),
                    
                    _buildSectionDivider(),
                    
                    // My reviews section  
                    _buildSection(
                      title: 'My reviews',
                      count: 1337,
                      children: _buildReviewCards(),
                    ),
                    
                    _buildSectionDivider(),
                    
                    // My comments section
                    _buildSection(
                      title: 'My comments', 
                      count: 228,
                      children: _buildCommentCards(),
                    ),
                    
                    _buildSectionDivider(),
                    
                    // My downloaded mods section
                    _buildSection(
                      title: 'My downloaded mods',
                      count: 88,
                      children: _buildModCards(),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // History section
                    _buildHistorySection(),
                  ],
                ),
              ),
            ),
            
            // Bottom navigation
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
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
            _buildActionButton(Icons.edit),
            const SizedBox(width: 12),
            _buildActionButton(Icons.share),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF374151)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
    );
  }

  Widget _buildSection({
    required String title,
    required int count,
    required List<Widget> children,
  }) {
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
          Text(
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

  Widget _buildHistorySection() {
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
          
          // Last downloaded
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
          
          // Last viewed
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

  Widget _buildBottomNavigation() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        border: Border(
          top: BorderSide(color: const Color(0xFF374151), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem('Главная', Icons.home, false),
          _buildNavItem('Закладки', Icons.bookmark_border, false),
          _buildNavItem('Профиль', Icons.person, true),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF388E3C) : const Color(0xFF9CA3AF),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF388E3C) : const Color(0xFF9CA3AF),
            fontSize: 12,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
