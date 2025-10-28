import 'package:flutter/foundation.dart';
import '../model/mod_item.dart';
import '../services/mods_service.dart';
import 'dart:developer';
import 'dart:async';

class ModsProvider extends ChangeNotifier {
  final ModsService _modsService;
  StreamSubscription? _searchSubscription;
  
  Timer? _searchDebounceTimer;
  Timer? _scrollDebounceTimer; // ✅ FIX: Added scroll debouncing
  static const Duration _searchDebounce = Duration(milliseconds: 300);
  
  ModsProvider(this._modsService) {
    _initializeProvider();
  }

  List<ModItem> _mods = [];
  List<ModItem> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  bool _isLoadingMore = false; // ✅ FIX: Separate loading state for pagination
  String? _error;
  String _currentSearchQuery = '';
  String _currentPeriod = 'all_time';
  int _currentOffset = 0;
  final int _pageSize = 20;
  bool _hasMoreMods = true;

  List<ModItem> get mods => _mods;
  List<ModItem> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isLoadingMore => _isLoadingMore; // ✅ FIX: Expose loading more state
  String? get error => _error;
  String get currentSearchQuery => _currentSearchQuery;
  bool get hasMoreMods => _hasMoreMods;
  bool get isSearchMode => _currentSearchQuery.isNotEmpty;

  void _initializeProvider() {
    _modsService.prefetchPopularMods();
  }

  Future<void> loadMods({String period = 'all_time'}) async {
    if (_isLoading && _currentPeriod == period) return;
    
    _isLoading = true;
    _error = null;
    _currentPeriod = period;
    _currentOffset = 0;
    _hasMoreMods = true;
    
    notifyListeners();
    
    try {
      final newMods = await _modsService.fetchMods(
        period: period,
        limit: _pageSize,
        offset: 0,
      );
      
      // ✅ FIX: Check if period still matches before updating
      if (_currentPeriod != period) return;
      
      _mods = newMods;
      _hasMoreMods = newMods.length == _pageSize;
      _currentOffset = newMods.length;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      log('Error loading mods: $e', name: 'ModsProvider');
      _error = 'Failed to load mods: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreMods() async {
    // ✅ FIX: Use separate loading state to prevent blocking
    if (_isLoading || _isLoadingMore || !_hasMoreMods || _currentSearchQuery.isNotEmpty) {
      return;
    }
    
    _isLoadingMore = true;
    _error = null;
    notifyListeners();
    
    try {
      final newMods = await _modsService.fetchMods(
        period: _currentPeriod,
        limit: _pageSize,
        offset: _currentOffset,
      );
      
      if (newMods.isNotEmpty) {
        // ✅ FIX: Batch list operations
        final updatedMods = [..._mods, ...newMods];
        _mods = updatedMods;
        _hasMoreMods = newMods.length == _pageSize;
        _currentOffset = _mods.length;
      } else {
        _hasMoreMods = false;
      }
      
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      log('Error loading more mods: $e', name: 'ModsProvider');
      _error = 'Failed to load more mods: ${e.toString()}';
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // ✅ FIX: Added debounced wrapper for scroll loading
  void requestLoadMoreMods() {
    _scrollDebounceTimer?.cancel();
    _scrollDebounceTimer = Timer(const Duration(milliseconds: 100), () {
      loadMoreMods();
    });
  }

  void searchMods(String query) {
    _currentSearchQuery = query;
    
    if (query.trim().isEmpty) {
      _clearSearch();
      return;
    }
    
    // Cancel previous search timer
    _searchDebounceTimer?.cancel();
    
    // ✅ FIX: Only notify after debounce completes
    _searchDebounceTimer = Timer(_searchDebounce, () {
      // Set searching state right before performing search
      _isSearching = true;
      _error = null;
      notifyListeners();
      
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    _searchSubscription?.cancel();
    
    _modsService.triggerSearch(query);
    
    _searchSubscription = _modsService.searchModsStream(query).listen(
      (results) {
        // ✅ FIX: Early return if query changed
        if (_currentSearchQuery != query) return;
        
        _searchResults = results;
        _isSearching = false;
        notifyListeners();
      },
      onError: (error) {
        // ✅ FIX: Early return if query changed
        if (_currentSearchQuery != query) return;
        
        log('Search error: $error', name: 'ModsProvider');
        _error = 'Search failed: ${error.toString()}';
        _isSearching = false;
        notifyListeners();
      },
    );
  }

  void clearSearch() {
    _searchDebounceTimer?.cancel();
    _searchSubscription?.cancel();
    _clearSearch();
    notifyListeners();
  }

  void _clearSearch() {
    _currentSearchQuery = '';
    _searchResults = [];
    _isSearching = false;
    _error = null;
  }

  Future<void> refreshMods() async {
    _modsService.clearCache();
    await loadMods(period: _currentPeriod);
  }

  Future<ModItem?> getModById(String id) async {
    // Try to find in current mods first
    try {
      return _mods.firstWhere((m) => m.id == id);
    } catch (_) {
      // Not found in mods
    }
    
    // Try search results
    try {
      return _searchResults.firstWhere((m) => m.id == id);
    } catch (_) {
      // Not found in search results
    }
    
    // Fetch from service as last resort
    try {
      return await _modsService.fetchMod(id);
    } catch (e) {
      log('Error fetching mod: $e', name: 'ModsProvider');
      _error = 'Failed to fetch mod: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  Future<void> toggleFavorite(String modId) async {
    log('Toggle favorite for mod: $modId', name: 'ModsProvider');
    // TODO: Implement favorite toggle
  }

  Future<void> reportMod(String modId, String reason) async {
    log('Report mod $modId for: $reason', name: 'ModsProvider');
    // TODO: Implement mod reporting
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _scrollDebounceTimer?.cancel();
    _searchSubscription?.cancel();
    _modsService.dispose();
    super.dispose();
  }
}