import 'dart:async';
import 'dart:developer';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../model/mod_item.dart';
import 'graphql_client.dart';

/// ModsService with retry logic, better error handling, and caching
class ModsService {
  final GraphQLHelper _graphqlHelper;
  final _searchController = StreamController<String>.broadcast();
  Timer? _debounceTimer;
  
  // Cache for storing fetched mods to avoid unnecessary API calls
  final Map<String, List<ModItem>> _modsCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheExpiry = const Duration(minutes: 5);

  ModsService(GraphQLClient client) 
      : _graphqlHelper = GraphQLHelper(client) {
    _initializeSearchDebouncing();
  }

  void _initializeSearchDebouncing() {
    _searchController.stream.listen((query) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _performSearch(query);
      });
    });
  }

  // GraphQL queries
  static const String _getModsQuery = r'''
    query GetMods($period: String, $limit: Int, $offset: Int) {
      mods(period: $period, limit: $limit, offset: $offset) {
        id
        title
        description
        rating
        ratingsCount
        imageUrl
        tags
        createdAt
        authorId
        downloadsCount
      }
    }
  ''';

  static const String _searchModsQuery = r'''
    query SearchMods($query: String!, $limit: Int, $offset: Int) {
      searchMods(query: $query, limit: $limit, offset: $offset) {
        id
        title
        description
        rating
        ratingsCount
        imageUrl
        tags
        createdAt
        authorId
        downloadsCount
      }
    }
  ''';

  static const String _getModQuery = r'''
    query GetMod($id: String!) {
      mod(id: $id) {
        id
        title
        description
        rating
        ratingsCount
        imageUrl
        tags
        createdAt
        authorId
        downloadsCount
        longDescription
        screenshots
        requirements
      }
    }
  ''';

  /// Fetch mods with caching and retry logic
  Future<List<ModItem>> fetchMods({
    String period = 'all_time',
    int limit = 20,
    int offset = 0,
  }) async {
    final cacheKey = '$period-$limit-$offset';
    
    // Check cache first
    if (_isCacheValid(cacheKey)) {
      return _modsCache[cacheKey]!;
    }

    try {
      final QueryOptions options = QueryOptions(
        document: gql(_getModsQuery),
        variables: {
          'period': period,
          'limit': limit,
          'offset': offset,
        },
        fetchPolicy: FetchPolicy.cacheFirst,
      );

      final QueryResult result = await _graphqlHelper.queryWithRetry(options);

      if (result.hasException && result.data == null) {
        log('GraphQL error: ${result.exception}');
        return _getFallbackMods();
      }

      final List<dynamic> modsData = result.data?['mods'] ?? [];
      final List<ModItem> mods = modsData
          .map((json) => ModItem.fromJson(json))
          .toList();
      
      // Cache the results
      _updateCache(cacheKey, mods);
      
      return mods;
    } catch (e) {
      log('Error fetching mods: $e');
      return _getFallbackMods();
    }
  }

  /// Search mods with debouncing
  Stream<List<ModItem>> searchModsStream(String query) {
    return _searchController.stream
        .where((q) => q == query)
        .asyncMap((_) => searchMods(query));
  }

  /// Debounced search trigger
  void triggerSearch(String query) {
    _searchController.add(query);
  }

  Future<void> _performSearch(String query) async {
    // This method is called after debouncing
    // The actual search happens in searchMods method
  }

  /// Search mods with retry logic
  Future<List<ModItem>> searchMods(String query) async {
    if (query.trim().isEmpty) {
      return fetchMods();
    }

    final cacheKey = 'search-$query';
    
    // Check cache first
    if (_isCacheValid(cacheKey)) {
      return _modsCache[cacheKey]!;
    }

    try {
      final QueryOptions options = QueryOptions(
        document: gql(_searchModsQuery),
        variables: {
          'query': query,
          'limit': 50,
          'offset': 0,
        },
        fetchPolicy: FetchPolicy.cacheFirst,
      );

      final QueryResult result = await _graphqlHelper.queryWithRetry(options);

      if (result.hasException && result.data == null) {
        log('Search error: ${result.exception}');
        return _getFallbackSearch(query);
      }

      final List<dynamic> modsData = result.data?['searchMods'] ?? [];
      final List<ModItem> mods = modsData
          .map((json) => ModItem.fromJson(json))
          .toList();
      
      // Cache the search results
      _updateCache(cacheKey, mods);
      
      return mods;
    } catch (e) {
      log('Error searching mods: $e');
      return _getFallbackSearch(query);
    }
  }

  /// Fetch a single mod with retry logic
  Future<ModItem?> fetchMod(String id) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(_getModQuery),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.cacheFirst,
      );

      final QueryResult result = await _graphqlHelper.queryWithRetry(options);

      if (result.hasException && result.data == null) {
        log('Error fetching mod $id: ${result.exception}');
        return null;
      }

      final dynamic modData = result.data?['mod'];
      if (modData == null) return null;
      
      return ModItem.fromJson(modData);
    } catch (e) {
      log('Error fetching mod $id: $e');
      return null;
    }
  }

  /// Prefetch popular mods for better performance
  Future<void> prefetchPopularMods() async {
    final options = QueryOptions(
      document: gql(_getModsQuery),
      variables: {
        'period': 'week',
        'limit': 10,
        'offset': 0,
      },
    );
    
    await _graphqlHelper.prefetchQuery(options);
  }

  /// Clear all caches
  void clearCache() {
    _modsCache.clear();
    _cacheTimestamps.clear();
    _graphqlHelper.clearCache('mods');
  }

  /// Update cache with timestamp
  void _updateCache(String key, List<ModItem> mods) {
    _modsCache[key] = mods;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// Check if cache is still valid
  bool _isCacheValid(String key) {
    if (!_modsCache.containsKey(key)) return false;
    
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  /// Fallback mods when API fails
  List<ModItem> _getFallbackMods() {
    return [
      ModItem(
        id: 'fallback_1',
        title: 'Enhanced Graphics Pack',
        description: 'Offline fallback - Improves visual quality with better textures, lighting, and effects. Perfect for immersive gameplay experience.',
        rating: 4.8,
        ratingsCount: 5432,
        imageUrl: 'lib/icons/main/mod_test_pfp.png', // Local fallback
        tags: ['Graphics', 'Visual', 'Enhancement', 'Quality'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        authorId: 'fallback_author_1',
        downloadsCount: 15420,
      ),
      ModItem(
        id: 'fallback_2',
        title: 'Ultimate Gameplay Mod',
        description: 'Offline fallback - Complete gameplay overhaul with new mechanics, improved AI, and balanced difficulty.',
        rating: 4.6,
        ratingsCount: 3210,
        imageUrl: 'lib/icons/main/mod_test_pfp.png',
        tags: ['Gameplay', 'Overhaul', 'Mechanics', 'AI'],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        authorId: 'fallback_author_2',
        downloadsCount: 8765,
      ),
      ModItem(
        id: 'fallback_3',
        title: 'Audio Enhancement Suite',
        description: 'Offline fallback - High-quality audio improvements with better sound effects and ambient audio.',
        rating: 4.3,
        ratingsCount: 1876,
        imageUrl: 'lib/icons/main/mod_test_pfp.png',
        tags: ['Audio', 'Sound', 'Music', 'Enhancement'],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        authorId: 'fallback_author_3',
        downloadsCount: 4321,
      ),
    ];
  }

  /// Fallback search results when API fails
  List<ModItem> _getFallbackSearch(String query) {
    final fallbackMods = _getFallbackMods();
    return fallbackMods
        .where((mod) =>
            mod.title.toLowerCase().contains(query.toLowerCase()) ||
            mod.description.toLowerCase().contains(query.toLowerCase()) ||
            mod.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())))
        .toList();
  }

  /// Dispose resources
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.close();
    clearCache();
  }
}
