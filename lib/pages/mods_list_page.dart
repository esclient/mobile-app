import 'package:flutter/material.dart';
import '../model/mod_item.dart';
import '../services/mods_service.dart';
import '../widgets/mod_card.dart';
import '../components/interactive_widgets.dart';

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
  
  final List<String> periods = ['За всё время', 'За месяц', 'За неделю', 'Недавние'];
  final List<String> periodKeys = ['all_time', 'month', 'week', 'recent'];

  @override
  void initState() {
    super.initState();
    _loadMods();
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
      setState(() {
        searchQuery = '';
      });
      _loadMods();
      return;
    }

    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      searchQuery = query;
    });

    try {
      final searchResults = await widget.modsService.searchMods(query);
      
      if (mounted) {
        setState(() {
          mods = searchResults;
          isLoading = false;
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
      body: SafeArea(
        child: Column(
          children: [
            // Header with search bar
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1F2937),
                border: Border(
                  bottom: BorderSide(color: Color(0xFF374151), width: 1),
                ),
              ),
              child: InteractiveSearchBar(
                placeholder: 'Поиск модов',
                searchQuery: searchQuery.isNotEmpty ? searchQuery : null,
                onSearchPressed: _searchMods,
                onFilterPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Фильтры пока не реализованы'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Color(0xFF388E3C),
                    ),
                  );
                },
                onNotificationPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Уведомления пока не реализованы'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Color(0xFF388E3C),
                    ),
                  );
                },
              ),
            ),

            // Period selector
            _buildPeriodSelector(),

            // Main content - Mods list
            Expanded(
              child: _buildModsList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
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
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: PeriodButton(
                    text: periods[index],
                    isSelected: selectedPeriodIndex == index,
                    onPressed: () {
                      if (selectedPeriodIndex != index) {
                        setState(() {
                          selectedPeriodIndex = index;
                          searchQuery = '';
                        });
                        _loadMods();
                      }
                    },
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
                ? 'Результаты поиска "$searchQuery"'
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
                            SvgIcon(
                              assetPath: searchQuery.isNotEmpty 
                                  ? 'lib/icons/main/Search.svg'
                                  : 'lib/icons/main/Home.svg',
                              size: 64,
                              color: const Color(0xFF9CA3AF),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.isNotEmpty 
                                  ? 'По запросу "$searchQuery" ничего не найдено'
                                  : 'Моды не найдены',
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              PeriodButton(
                                text: 'Показать все моды',
                                onPressed: () {
                                  setState(() {
                                    searchQuery = '';
                                  });
                                  _loadMods();
                                },
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
                                image: const DecorationImage(
                                  image: AssetImage('lib/icons/main/mod_test_pfp.png'),
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
                                    StarRating(rating: mod.rating, starSize: 12),
                                    const SizedBox(width: 5),
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
                            return InteractiveTag(
                              text: tag,
                              onPressed: () {
                                Navigator.of(context).pop();
                                _searchMods('#$tag');
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: PeriodButton(
                          text: 'Скачать мод',
                          isSelected: true,
                          onPressed: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Скачивание "${mod.title}" началось'),
                                backgroundColor: const Color(0xFF388E3C),
                              ),
                            );
                          },
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
      height: 80, // Увеличил высоту
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
            BottomNavItem(
              label: 'Главная',
              iconPath: 'lib/icons/main/Home.svg',
              isActive: true,
              onPressed: () {},
            ),
            BottomNavItem(
              label: 'Закладки',
              iconPath: 'lib/icons/main/Favorite.svg',
              isActive: false,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Закладки пока не реализованы'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Color(0xFF388E3C),
                  ),
                );
              },
            ),
            BottomNavItem(
              label: 'Профиль',
              iconPath: 'lib/icons/main/Profile.svg',
              isActive: false,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Профиль пока не реализован'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Color(0xFF388E3C),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
