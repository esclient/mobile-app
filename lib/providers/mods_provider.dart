import 'package:flutter/foundation.dart';
import '../model/mod_item.dart';
import '../services/mods_service_optimized.dart';
import 'dart:developer';

/// Provider for managing mods state with optimized data handling
class ModsProvider extends ChangeNotifier {
  final OptimizedModsService _modsService;
  
  ModsProvider(this._modsService) {
    _initializeProvider();
  }

  // State variables
  List<ModItem> _mods = [];
  List<ModItem> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;
  String _currentSearchQuery = '';
  String _currentPeriod = 'all_time';
  int _currentOffset = 0;
  final int _pageSize = 20;
  bool _hasMoreMods = true;

  // Getters
  List<ModItem> get mods => _mods;
  List<ModItem> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;
  String get currentSearchQuery => _currentSearchQuery;
  bool get hasMoreMods => _hasMoreMods;
  bool get isSearchMode => _currentSearchQuery.isNotEmpty;

  void _initializeProvider() {
    // Prefetch popular mods for better initial loading
    _modsService.prefetchPopularMods();
  }

  /// Load initial mods
  Future<void> loadMods({String period = 'all_time'}) async {
    if (_isLoading) return;
    
    _setLoading(true);
    _error = null;
    _currentPeriod = period;
    _currentOffset = 0;
    _hasMoreMods = true;
    
    try {
      final newMods = await _modsService.fetchMods(
        period: period,
        limit: _pageSize,
        offset: 0,
      );
      
      _mods = newMods;
      _hasMoreMods = newMods.length == _pageSize;
      _currentOffset = newMods.length;
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load mods: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Load more mods for pagination
  Future<void> loadMoreMods() async {
    if (_isLoading || !_hasMoreMods || _currentSearchQuery.isNotEmpty) return;
    
    _setLoading(true);
    
    try {
      final newMods = await _modsService.fetchMods(
        period: _currentPeriod,
        limit: _pageSize,
        offset: _currentOffset,
      );
      
      _mods.addAll(newMods);
      _hasMoreMods = newMods.length == _pageSize;
      _currentOffset += newMods.length;
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load more mods: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Search mods with debouncing
  void searchMods(String query) {
    _currentSearchQuery = query;
    
    if (query.trim().isEmpty) {
      _clearSearch();
      return;
    }
    
    _setSearching(true);
    _modsService.triggerSearch(query);
    
    // Listen to search results
    _modsService.searchModsStream(query).listen(
      (results) {
        if (_currentSearchQuery == query) { // Only update if still current query
          _searchResults = results;
          _setSearching(false);
          notifyListeners();
        }
      },
      onError: (error) {
        if (_currentSearchQuery == query) {
          _setError('Search failed: ${error.toString()}');
          _setSearching(false);
        }
      },
    );
  }

  /// Clear search and return to main mods list
  void clearSearch() {
    _clearSearch();
    notifyListeners();
  }

  void _clearSearch() {
    _currentSearchQuery = '';
    _searchResults = [];
    _isSearching = false;
    _error = null;
  }

  /// Refresh mods (pull to refresh)
  Future<void> refreshMods() async {
    _modsService.clearCache();
    await loadMods(period: _currentPeriod);
  }

  /// Get mod by ID
  Future<ModItem?> getModById(String id) async {
    // First check if mod is already in memory
    ModItem? mod = _mods.cast<ModItem?>().firstWhere(
      (m) => m?.id == id,
      orElse: () => null,
    );
    
    if (mod != null) return mod;
    
    // Check search results
    mod = _searchResults.cast<ModItem?>().firstWhere(
      (m) => m?.id == id,
      orElse: () => null,
    );
    
    if (mod != null) return mod;
    
    // Fetch from API if not in memory
    try {
      return await _modsService.fetchMod(id);
    } catch (e) {
      _setError('Failed to fetch mod: ${e.toString()}');
      return null;
    }
  }

  /// Toggle favorite status (placeholder for future implementation)
  Future<void> toggleFavorite(String modId) async {
    // TODO: Implement favorite functionality
    log('Toggle favorite for mod: $modId');
  }

  /// Report a mod (placeholder for future implementation)
  Future<void> reportMod(String modId, String reason) async {
    // TODO: Implement reporting functionality
    log('Report mod $modId for: $reason');
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSearching(bool searching) {
    _isSearching = searching;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _modsService.dispose();
    super.dispose();
  }
}
