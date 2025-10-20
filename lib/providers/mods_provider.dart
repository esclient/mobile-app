import 'package:flutter/foundation.dart';
import '../model/mod_item.dart';
import '../services/mods_service.dart';
import 'dart:developer';
import 'dart:async';

class ModsProvider extends ChangeNotifier {
  final ModsService _modsService;
  StreamSubscription? _searchSubscription;
  
  ModsProvider(this._modsService) {
    _initializeProvider();
  }

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

  List<ModItem> get mods => _mods;
  List<ModItem> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;
  String get currentSearchQuery => _currentSearchQuery;
  bool get hasMoreMods => _hasMoreMods;
  bool get isSearchMode => _currentSearchQuery.isNotEmpty;

  void _initializeProvider() {
    _modsService.prefetchPopularMods();
  }

  Future<void> loadMods({String period = 'all_time'}) async {
    if (_isLoading) return;
    
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
      
      _mods = newMods;
      _hasMoreMods = newMods.length == _pageSize;
      _currentOffset = newMods.length;
    } catch (e) {
      log('Error loading mods: $e');
      _error = 'Failed to load mods: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreMods() async {
    if (_isLoading || !_hasMoreMods || _currentSearchQuery.isNotEmpty) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newMods = await _modsService.fetchMods(
        period: _currentPeriod,
        limit: _pageSize,
        offset: _currentOffset,
      );
      
      _mods.addAll(newMods);
      _hasMoreMods = newMods.length == _pageSize;
      _currentOffset += newMods.length;
    } catch (e) {
      log('Error loading more mods: $e');
      _error = 'Failed to load more mods: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchMods(String query) {
    _currentSearchQuery = query;
    
    if (query.trim().isEmpty) {
      _clearSearch();
      return;
    }
    
    _searchSubscription?.cancel();
    
    _isSearching = true;
    _error = null;
    notifyListeners();
    
    _modsService.triggerSearch(query);
    
    _searchSubscription = _modsService.searchModsStream(query).listen(
      (results) {
        if (_currentSearchQuery == query) {
          _searchResults = results;
          _isSearching = false;
          notifyListeners();
        }
      },
      onError: (error) {
        if (_currentSearchQuery == query) {
          log('Search error: $error');
          _error = 'Search failed: ${error.toString()}';
          _isSearching = false;
          notifyListeners();
        }
      },
    );
  }

  void clearSearch() {
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
    ModItem? mod = _mods.cast<ModItem?>().firstWhere(
      (m) => m?.id == id,
      orElse: () => null,
    );
    
    if (mod != null) return mod;
    
    mod = _searchResults.cast<ModItem?>().firstWhere(
      (m) => m?.id == id,
      orElse: () => null,
    );
    
    if (mod != null) return mod;
    
    try {
      return await _modsService.fetchMod(id);
    } catch (e) {
      log('Error fetching mod: $e');
      _error = 'Failed to fetch mod: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  Future<void> toggleFavorite(String modId) async {
    log('Toggle favorite for mod: $modId');
  }

  Future<void> reportMod(String modId, String reason) async {
    log('Report mod $modId for: $reason');
  }

  @override
  void dispose() {
    _searchSubscription?.cancel();
    _modsService.dispose();
    super.dispose();
  }
}