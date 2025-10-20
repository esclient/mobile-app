import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../model/mod_item.dart';
import '../providers/mods_provider.dart';
import '../providers/comments_provider.dart';
import '../services/auth_service.dart';
import '../services/service_locator.dart';
import '../widgets/mod_card.dart';
import '../widgets/comment_card.dart';
import '../widgets/comment_input_widget.dart';
import '../components/interactive_widgets.dart';
import '../components/app_bottom_nav_bar.dart';
import '../components/app_header.dart';

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
    
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ModsProvider>().loadMods();
      }
    });
    
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  // ✅ FIX: Use debounced method from provider
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ModsProvider>().requestLoadMoreMods();
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

  // ✅ FIX: Method to update period selection
  void _onPeriodChanged(int index) {
    if (selectedPeriodIndex != index) {
      setState(() {
        selectedPeriodIndex = index;
      });
      
      final modsProvider = context.read<ModsProvider>();
      modsProvider.clearSearch();
      modsProvider.loadMods(period: periodKeys[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      appBar: AppHeader(
        showActualSearchBar: true,
        searchQuery: context.select<ModsProvider, String?>(
          (provider) => provider.currentSearchQuery.isEmpty 
            ? null 
            : provider.currentSearchQuery,
        ),
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
          // ✅ FIX: Pass period state to child
          _PeriodSelectorWrapper(
            selectedPeriodIndex: selectedPeriodIndex,
            onPeriodChanged: _onPeriodChanged,
          ),
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

  Widget _buildModsList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Selector<ModsProvider, ({bool isSearchMode, String searchQuery})>(
            selector: (_, provider) => (
              isSearchMode: provider.isSearchMode,
              searchQuery: provider.currentSearchQuery,
            ),
            builder: (context, data, child) {
              return Text(
                data.isSearchMode 
                    ? 'Результаты поиска "${data.searchQuery}"'
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
            child: _ModsListContent(
              scrollController: _scrollController,
              selectedPeriodIndex: selectedPeriodIndex,
              onModTap: _onModTap,
              onSearchChanged: _onSearchChanged,
              searchController: _searchController,
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

// ✅ FIX: Period selector with proper state management
class _PeriodSelectorWrapper extends StatelessWidget {
  final int selectedPeriodIndex;
  final ValueChanged<int> onPeriodChanged;

  const _PeriodSelectorWrapper({
    required this.selectedPeriodIndex,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<ModsProvider, bool>(
      selector: (_, provider) => provider.isSearchMode,
      builder: (context, isSearchMode, child) {
        if (isSearchMode) {
          return const SizedBox.shrink();
        }
        return _PeriodSelector(
          selectedPeriodIndex: selectedPeriodIndex,
          onPeriodChanged: onPeriodChanged,
        );
      },
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final int selectedPeriodIndex;
  final ValueChanged<int> onPeriodChanged;
  
  static const List<String> periods = ['За всё время', 'За месяц', 'За неделю', 'Недавние'];

  const _PeriodSelector({
    required this.selectedPeriodIndex,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
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
              // ✅ FIX: Added cacheExtent
              cacheExtent: 200,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: PeriodButton(
                    text: periods[index],
                    isSelected: selectedPeriodIndex == index,
                    onPressed: () => onPeriodChanged(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ FIX: Optimized mods list content with Selector
class _ModsListContent extends StatelessWidget {
  final ScrollController scrollController;
  final int selectedPeriodIndex;
  final Function(ModItem) onModTap;
  final Function(String) onSearchChanged;
  final TextEditingController? searchController;

  const _ModsListContent({
    required this.scrollController,
    required this.selectedPeriodIndex,
    required this.onModTap,
    required this.onSearchChanged,
    this.searchController,
  });

  static const List<String> periodKeys = ['all_time', 'month', 'week', 'recent'];
  static const double modCardHeight = 134.0;

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: Use Selector instead of Consumer for granular rebuilds
    return Selector<ModsProvider, ({
      List<ModItem> mods,
      List<ModItem> searchResults,
      bool isLoading,
      bool isLoadingMore,
      bool isSearchMode,
      String? error,
      String searchQuery,
    })>(
      selector: (_, provider) => (
        mods: provider.mods,
        searchResults: provider.searchResults,
        isLoading: provider.isLoading,
        isLoadingMore: provider.isLoadingMore,
        isSearchMode: provider.isSearchMode,
        error: provider.error,
        searchQuery: provider.currentSearchQuery,
      ),
      builder: (context, data, child) {
        if (data.isLoading && 
            (data.mods.isEmpty && data.searchResults.isEmpty)) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF388E3C),
            ),
          );
        }
        
        if (data.error != null && data.mods.isEmpty && data.searchResults.isEmpty) {
          return _buildErrorWidget(context, data.error!, data.isSearchMode);
        }
        
        final List<ModItem> currentMods = data.isSearchMode 
            ? data.searchResults 
            : data.mods;
        
        if (currentMods.isEmpty) {
          return _buildEmptyWidget(
            context, 
            data.isSearchMode, 
            data.searchQuery,
          );
        }
        
        return RefreshIndicator(
          onRefresh: () => context.read<ModsProvider>().refreshMods(),
          color: const Color(0xFF388E3C),
          backgroundColor: const Color(0xFF374151),
          child: ListView.builder(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            itemCount: currentMods.length + (data.isLoadingMore ? 1 : 0),
            itemExtent: modCardHeight + 10,
            cacheExtent: 2000, // ✅ FIX: Increased for better performance
            addAutomaticKeepAlives: true,
            addRepaintBoundaries: true,
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
                key: ValueKey('mod_padding_${mod.id}'),
                padding: const EdgeInsets.only(bottom: 10),
                child: ModCard(
                  key: ValueKey('mod_${mod.id}'),
                  mod: mod,
                  onTap: () => onModTap(mod),
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  Widget _buildErrorWidget(BuildContext context, String error, bool isSearchMode) {
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
              final provider = context.read<ModsProvider>();
              if (isSearchMode) {
                provider.searchMods(provider.currentSearchQuery);
              } else {
                provider.loadMods(period: periodKeys[selectedPeriodIndex]);
              }
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyWidget(
    BuildContext context, 
    bool isSearchMode, 
    String searchQuery,
  ) {
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
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: PeriodButton(
                text: 'Показать все моды',
                onPressed: () {
                  final provider = context.read<ModsProvider>();
                  provider.clearSearch();
                  searchController?.clear();
                  provider.loadMods(period: periodKeys[selectedPeriodIndex]);
                },
              ),
            ),
        ],
      ),
    );
  }
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
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = ServiceLocator().authService;
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
                      const _CommentsHeaderWidget(),
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
  
  // ✅ FIX: Use Selector instead of Consumer
  Widget _buildCommentsSection() {
    return Selector<CommentsProvider, ({
      List comments,
      bool isLoading,
      String? error,
    })>(
      selector: (_, provider) => (
        comments: provider.comments,
        isLoading: provider.isLoading,
        error: provider.error,
      ),
      builder: (context, data, child) {
        if (data.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                color: Color(0xFF388E3C),
              ),
            ),
          );
        }
        
        if (data.error != null) {
          return Center(
            child: Column(
              children: [
                Text(
                  data.error!,
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
                    context.read<CommentsProvider>().loadComments(widget.mod.id);
                  },
                ),
              ],
            ),
          );
        }
        
        if (data.comments.isEmpty) {
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
        
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.comments.length,
          addAutomaticKeepAlives: true,
          addRepaintBoundaries: true,
          // ✅ FIX: Added cacheExtent
          cacheExtent: 500,
          itemBuilder: (context, index) {
            final comment = data.comments[index];
            return CommentCard(
              key: ValueKey('comment_detail_${comment.id}'),
              comment: comment,
              currentUserId: _authService.currentUserId,
            );
          },
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
              cacheWidth: 240,
              cacheHeight: 240,
              gaplessPlayback: true,
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

class _CommentsHeaderWidget extends StatelessWidget {
  const _CommentsHeaderWidget();

  @override
  Widget build(BuildContext context) {
    return Selector<CommentsProvider, int>(
      selector: (_, provider) => provider.comments.length,
      builder: (context, count, child) {
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
}