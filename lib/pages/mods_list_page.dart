import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/mod_item.dart';
import '../providers/mods_provider.dart';
import '../widgets/mod_card.dart';
import '../components/interactive_widgets.dart';
import '../components/app_bottom_nav_bar.dart';
import '../components/app_header.dart';
import '../services/service_locator.dart';
import '../widgets/comment_card.dart';
import '../providers/comments_provider.dart';
import '../widgets/comment_input_widget.dart';

class ModsListPage extends StatefulWidget {
  const ModsListPage({super.key});

  @override
  State<ModsListPage> createState() => _ModsListPageState();
}

class _ModsListPageState extends State<ModsListPage> 
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  
  int selectedPeriodIndex = 0;
  final ScrollController _scrollController = ScrollController();
  TextEditingController? _searchController;
  
  static const List<String> periods = ['За всё время', 'За месяц', 'За неделю', 'Недавние'];
  static const List<String> periodKeys = ['all_time', 'month', 'week', 'recent'];
  static const double modCardHeight = 134.0;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ModsProvider>().loadMods();
    });
    
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    final modsProvider = context.read<ModsProvider>();
    
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      modsProvider.loadMoreMods();
    }
  }

  void _onSearchChanged(String query) {
    final modsProvider = context.read<ModsProvider>();
    
    if (query.trim().isEmpty) {
      modsProvider.clearSearch();
      modsProvider.loadMods(period: periodKeys[selectedPeriodIndex]);
    } else {
      modsProvider.searchMods(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      appBar: AppHeader(
        showActualSearchBar: true,
        searchQuery: context.watch<ModsProvider>().currentSearchQuery.isEmpty 
          ? null 
          : context.watch<ModsProvider>().currentSearchQuery,
        onSearchSubmitted: _onSearchChanged,
        onSearchControllerCreated: (controller) {
          _searchController = controller;
        },
        onFilterPressed: _showFilterDialog,
        onSettingsPressed: _showSettings,
        onNotificationPressed: _showNotifications,
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          Expanded(
            child: _buildModsList(),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        activeIndex: 0, 
        authService: ServiceLocator().authService,
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Consumer<ModsProvider>(
      builder: (context, modsProvider, child) {
        if (modsProvider.isSearchMode) {
          return const SizedBox.shrink();
        }
        
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
                        onPressed: () => _onPeriodChanged(index),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _onPeriodChanged(int index) {
    if (selectedPeriodIndex != index) {
      setState(() {
        selectedPeriodIndex = index;
      });
      
      final modsProvider = context.read<ModsProvider>();
      modsProvider.clearSearch();
      _searchController?.clear();
      modsProvider.loadMods(period: periodKeys[index]);
    }
  }

  Widget _buildModsList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<ModsProvider>(
            builder: (context, modsProvider, child) {
              return Text(
                modsProvider.isSearchMode 
                    ? 'Результаты поиска "${modsProvider.currentSearchQuery}"'
                    : 'Список модов',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 1.40,
                ),
              );
            },
          ),
          const SizedBox(height: 9),
          Expanded(
            child: _buildListContent(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildListContent() {
    return Consumer<ModsProvider>(
      builder: (context, modsProvider, child) {
        if (modsProvider.isLoading && 
            (modsProvider.mods.isEmpty && modsProvider.searchResults.isEmpty)) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF388E3C),
            ),
          );
        }
        
        if (modsProvider.error != null) {
          return _buildErrorWidget(modsProvider.error!);
        }
        
        final List<ModItem> currentMods = modsProvider.isSearchMode 
            ? modsProvider.searchResults 
            : modsProvider.mods;
        
        if (currentMods.isEmpty) {
          return _buildEmptyWidget(modsProvider.isSearchMode, modsProvider.currentSearchQuery);
        }
        
        return RefreshIndicator(
          onRefresh: () => modsProvider.refreshMods(),
          color: const Color(0xFF388E3C),
          backgroundColor: const Color(0xFF374151),
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: currentMods.length + (modsProvider.isLoading ? 1 : 0),
            itemExtent: modCardHeight + 10,
            cacheExtent: 1000,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: false,
            itemBuilder: (context, index) {
              if (index >= currentMods.length) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF388E3C),
                    ),
                  ),
                );
              }
              
              final mod = currentMods[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ModCard(
                  key: ValueKey('mod_${mod.id}'),
                  mod: mod,
                  onTap: () => _onModTap(mod),
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 16),
          Text(
            error,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PeriodButton(
            text: 'Попробовать снова',
            onPressed: () {
              final modsProvider = context.read<ModsProvider>();
              if (modsProvider.isSearchMode) {
                modsProvider.searchMods(modsProvider.currentSearchQuery);
              } else {
                modsProvider.loadMods(period: periodKeys[selectedPeriodIndex]);
              }
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyWidget(bool isSearchMode, String searchQuery) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgIcon(
            assetPath: isSearchMode 
                ? 'lib/icons/header/search.svg'
                : 'lib/icons/footer/home.svg',
            size: 64,
            color: const Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 16),
          Text(
            isSearchMode 
                ? 'По запросу "$searchQuery" ничего не найдено'
                : 'Моды не найдены',
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          if (isSearchMode) 
            PeriodButton(
              text: 'Показать все моды',
              onPressed: () {
                final modsProvider = context.read<ModsProvider>();
                modsProvider.clearSearch();
                _searchController?.clear();
                modsProvider.loadMods(period: periodKeys[selectedPeriodIndex]);
              },
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
        return _ModDetailsSheet(
          mod: mod, 
          onTagPressed: (tag) => _onSearchChanged(tag),
        );
      },
    );
  }
  
  void _showFilterDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Фильтры пока не реализованы'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF388E3C),
      ),
    );
  }
  
  void _showSettings() {}
  
  void _showNotifications() {}
}

class _ModDetailsSheet extends StatefulWidget {
  final ModItem mod;
  final ValueChanged<String> onTagPressed;
  
  const _ModDetailsSheet({
    required this.mod,
    required this.onTagPressed,
  });

  @override
  State<_ModDetailsSheet> createState() => _ModDetailsSheetState();
}

class _ModDetailsSheetState extends State<_ModDetailsSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommentsProvider>().loadComments(widget.mod.id);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Container(
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      Text(
                        widget.mod.description,
                        style: const TextStyle(
                          color: Color(0xFFD1D5DB),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (widget.mod.tags.isNotEmpty) ...[
                        _buildTags(context),
                        const SizedBox(height: 20),
                      ],
                      _buildDownloadButton(context),
                      const SizedBox(height: 20),
                      _buildCommentsHeader(),
                      const SizedBox(height: 10),
                      _buildCommentsSection(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CommentInputWidget(modId: widget.mod.id),
      ),
    );
  }
  
  Widget _buildCommentsSection() {
    return Consumer<CommentsProvider>(
      builder: (context, commentsProvider, child) {
        if (commentsProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                color: Color(0xFF388E3C),
              ),
            ),
          );
        }
        
        if (commentsProvider.error != null) {
          return Center(
            child: Column(
              children: [
                Text(
                  commentsProvider.error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                PeriodButton(
                  text: 'Попробовать снова',
                  onPressed: () {
                    commentsProvider.loadComments(widget.mod.id);
                  },
                ),
              ],
            ),
          );
        }
        
        if (commentsProvider.comments.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Нет комментариев',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
              ),
            ),
          );
        }
        
        final authService = ServiceLocator().authService;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: commentsProvider.comments.length,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          itemBuilder: (context, index) {
            return CommentCard(
              comment: commentsProvider.comments[index],
              currentUserId: authService.currentUserId,
            );
          },
        );
      },
    );
  }

  Widget _buildCommentsHeader() {
    return Consumer<CommentsProvider>(
      builder: (context, commentsProvider, child) {
        final count = commentsProvider.comments.length;
        return Row(
          children: [
            const Text(
              'Комментарии',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF374151),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Color(0xFFE5E7EB),
                  fontSize: 12,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildHeader() {
    return Row(
      children: [
        Hero(
          tag: 'mod_image_${widget.mod.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'lib/icons/main/mod_test_pfp.png',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: const Color(0xFF374151),
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Color(0xFF9CA3AF),
                    size: 40,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.mod.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF374151), width: 1),
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFF1F2937),
                      child: Icon(Icons.person, size: 16, color: Color(0xFF9CA3AF)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.mod.authorId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  StarRating(rating: widget.mod.rating, starSize: 12),
                  const SizedBox(width: 4),
                  Text(
                    widget.mod.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '(${widget.mod.formattedRatingsCount})',
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.download_rounded,
                        size: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.mod.formattedDownloadsCount,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTags(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.mod.tags.map((tag) {
        return InteractiveTag(
          text: tag,
          onPressed: () {
            Navigator.of(context).pop();
            widget.onTagPressed('#$tag');
          },
        );
      }).toList(),
    );
  }
  
  Widget _buildDownloadButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: PeriodButton(
        text: 'Скачать мод',
        isSelected: true,
        onPressed: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Скачивание "${widget.mod.title}" началось'),
              backgroundColor: const Color(0xFF388E3C),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}
