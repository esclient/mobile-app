import 'package:flutter/material.dart';
import '../model/mod_item.dart';
import '../services/mods_service.dart';
import '../widgets/mod_card.dart';

class ModsListPage extends StatefulWidget {
  final ModsService modsService;
  
  const ModsListPage({super.key, required this.modsService});

  @override
  State<ModsListPage> createState() => _ModsListPageState();
}

class _ModsListPageState extends State<ModsListPage> with TickerProviderStateMixin {
  int selectedPeriodIndex = 0;
  List<ModItem> mods = [];
  bool isLoading = true;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> periods = ['За всё время', 'За месяц', 'За неделю', 'Недавние'];
  final List<String> periodKeys = ['all_time', 'month', 'week', 'recent'];

  @override
  void initState() {
    super.initState();
    _loadMods();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMods() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      final loadedMods = await widget.modsService.fetchMods(
        period: periodKeys[selectedPeriodIndex],
      );
      
      if (mounted) {
        setState(() {
          mods = loadedMods;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки модов: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _searchMods(String query) async {
    if (query.isEmpty) {
      _loadMods();
      return;
    }

    if (!mounted) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      final searchResults = await widget.modsService.searchMods(query);
      
      if (mounted) {
        setState(() {
          mods = searchResults;
          isLoading = false;
          searchQuery = query;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildPeriodSelector(),
          Expanded(child: _buildModsList()),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1F2937),
      elevation: 0,
      toolbarHeight: 83,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF374151), width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _showSearchDialog,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF374151)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.search,
                            color: Color(0xBF9B9B9B),
                            size: 20,
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Text(
                              searchQuery.isNotEmpty ? searchQuery : 'Поиск модов',
                              style: TextStyle(
                                color: searchQuery.isNotEmpty 
                                    ? Colors.white 
                                    : const Color(0xBF9B9B9B),
                                fontSize: 16,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                _buildActionButton(
                  icon: Icons.filter_list,
                  onTap: () {
                    // TODO: Implement filter functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Фильтры пока не реализованы'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 7),
                _buildActionButton(
                  icon: Icons.notifications,
                  onTap: () {
                    // TODO: Implement notifications
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Уведомления пока не реализованы'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon, 
    required VoidCallback onTap,
    double size = 20,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF374151)),
        ),
        child: Icon(
          icon,
          color: const Color(0xBF9B9B9B),
          size: size,
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF374151),
          title: const Text(
            'Поиск модов',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Введите название или описание мода...',
              hintStyle: TextStyle(color: Color(0xBF9B9B9B)),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF9CA3AF)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF388E3C)),
              ),
            ),
            onSubmitted: (value) {
              Navigator.of(context).pop();
              _searchMods(value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _searchController.clear();
                Navigator.of(context).pop();
                setState(() {
                  searchQuery = '';
                });
                _loadMods();
              },
              child: const Text(
                'Очистить',
                style: TextStyle(color: Color(0xFF9CA3AF)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _searchMods(_searchController.text);
              },
              child: const Text(
                'Поиск',
                style: TextStyle(color: Color(0xFF388E3C)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Топ за период',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              height: 1.40,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 54,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: periods.length,
              itemBuilder: (context, index) {
                final isSelected = selectedPeriodIndex == index;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      if (selectedPeriodIndex != index) {
                        setState(() {
                          selectedPeriodIndex = index;
                          searchQuery = '';
                        });
                        _searchController.clear();
                        _loadMods();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 43,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF388E3C) : null,
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFF388E3C) 
                              : const Color(0xFF374151),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          periods[index],
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
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModsList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            searchQuery.isNotEmpty 
                ? 'Результаты поиска "${searchQuery}"'
                : 'Список модов',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 1.40,
            ),
          ),
          const SizedBox(height: 9),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF388E3C),
                    ),
                  )
                : mods.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              searchQuery.isNotEmpty 
                                  ? Icons.search_off 
                                  : Icons.inventory_2_outlined,
                              size: 64,
                              color: const Color(0xFF9CA3AF),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.isNotEmpty 
                                  ? 'По запросу "${searchQuery}" ничего не найдено'
                                  : 'Моды не найдены',
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    searchQuery = '';
                                  });
                                  _searchController.clear();
                                  _loadMods();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF388E3C),
                                ),
                                child: const Text(
                                  'Показать все моды',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMods,
                        color: const Color(0xFF388E3C),
                        backgroundColor: const Color(0xFF374151),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: mods.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final mod = mods[index];
                            return ModCard(
                              key: ValueKey(mod.id),
                              mod: mod,
                              onTap: () => _onModTap(mod),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _onModTap(ModItem mod) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Color(0xFF1F2937),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF9CA3AF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Hero(
                            tag: 'mod_image_${mod.id}',
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: NetworkImage(mod.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mod.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Автор: ${mod.authorId}',
                                  style: const TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Text(
                                      mod.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: Color(0xFFF59E0B),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '(${mod.formattedRatingsCount})',
                                      style: const TextStyle(
                                        color: Color(0xFF9CA3AF),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${mod.formattedDownloadsCount} загрузок',
                                      style: const TextStyle(
                                        color: Color(0xFF9CA3AF),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Описание:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            mod.description,
                            style: const TextStyle(
                              color: Color(0xFFD1D5DB),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (mod.tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: mod.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF374151),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Скачивание "${mod.title}" началось'),
                                backgroundColor: const Color(0xFF388E3C),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF388E3C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Скачать мод',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 69,
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
            _buildNavItem('Главная', Icons.home, true, () {}),
            _buildNavItem('Закладки', Icons.bookmark, false, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Закладки пока не реализованы'),
                  duration: Duration(seconds: 2),
                ),
              );
            }),
            _buildNavItem('Профиль', Icons.person, false, () {
              Navigator.pushNamed(context, '/comments');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String title, IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? const Color(0xFF388E3C) : const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isActive ? const Color(0xFF388E3C) : const Color(0xFF9CA3AF),
                fontSize: 12,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                height: 1.33,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
