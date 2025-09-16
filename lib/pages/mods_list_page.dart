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

class _ModsListPageState extends State<ModsListPage> {
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
    setState(() {
      isLoading = true;
    });

    try {
      final loadedMods = await widget.modsService.fetchMods(
        period: periodKeys[selectedPeriodIndex],
      );
      setState(() {
        mods = loadedMods;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
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

    setState(() {
      isLoading = true;
    });

    try {
      final searchResults = await widget.modsService.searchMods(query);
      setState(() {
        mods = searchResults;
        isLoading = false;
        searchQuery = query;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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
                        Text(
                          searchQuery.isNotEmpty ? searchQuery : 'Поиск модов',
                          style: TextStyle(
                            color: searchQuery.isNotEmpty 
                                ? Colors.white 
                                : const Color(0xBF9B9B9B),
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
              const SizedBox(width: 7),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF374151)),
                ),
                child: const Icon(
                  Icons.filter_list,
                  color: Color(0xBF9B9B9B),
                  size: 24,
                ),
              ),
              const SizedBox(width: 7),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF374151)),
                ),
                child: const Icon(
                  Icons.notifications,
                  color: Color(0xBF9B9B9B),
                  size: 20,
                ),
              ),
            ],
          ),
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
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: periods.asMap().entries.map((entry) {
                  int index = entry.key;
                  String period = entry.value;
                  bool isSelected = selectedPeriodIndex == index;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPeriodIndex = index;
                          searchQuery = '';
                        });
                        _searchController.clear();
                        _loadMods();
                      },
                      child: Container(
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
                            period,
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
                }).toList(),
              ),
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
          const Text(
            'Список модов',
            style: TextStyle(
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
                    ? const Center(
                        child: Text(
                          'Моды не найдены',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: mods.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => ModCard(
                          mod: mods[index],
                          onTap: () => _onModTap(mods[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _onModTap (ModItem mod) {
    return Container(
      height: 134,
      decoration: BoxDecoration(
        color: const Color(0xFF181F2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF374151)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(mod.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(mod.starsCount, (starIndex) {
                  return Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 2),
              Text(
                mod.rating.toStringAsFixed(1),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFF59E0B),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 1.71,
                ),
              ),
              Text(
                mod.formattedRatingsCount,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 7,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 2.29,
                ),
              ),
            ],
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 19),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mod.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      height: 1.50,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      mod.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFD1D5DB),
                        fontSize: 12,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 1.62,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 5,
                    children: mod.tags.take(5).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF374151),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF374151)),
                        ),
                        child: Text(
                          tag,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFD1D5DB),
                            fontSize: 10,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            height: 1.33,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem('Главная', Icons.home, true, () {}),
          _buildNavItem('Закладки', Icons.bookmark, false, () {}),
          _buildNavItem('Профиль', Icons.person, false, () {
            Navigator.pushNamed(context, '/comments');
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}
