import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../model/mod_item.dart';
import 'graphql_client.dart';

/// Parse mods data in isolate for better performance on large datasets
List<ModItem> _parseModsInIsolate(List<dynamic> jsonList) {
  return jsonList.map((json) => ModItem.fromJson(json)).toList();
}

class ModsService {
  final GraphQLHelper _graphqlHelper;
  final _searchController = StreamController<String>.broadcast();
  Timer? _debounceTimer;

  final Map<String, List<ModItem>> _modsCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheExpiry = const Duration(minutes: 5);
  List<ModItem>? _cachedFallbackMods;

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

  static const String _getModsQuery = r'''
    query GetMods {
      mod {
        getMods {
          id
          author_id
          title
          description
          version
          status
          created_at
        }
      }
    }
  ''';

  static const String _searchModsQuery = r'''
    query SearchMods {
      mod {
        getMods {
          id
          author_id
          title
          description
          version
          status
          created_at
        }
      }
    }
  ''';

  static const String _getModQuery = r'''
    query GetMod($modId: ID!) {
      mod {
        getMod(input: { mod_id: $modId }) {
          id
          author_id
          title
          description
          version
          status
          created_at
        }
      }
    }
  ''';

  Future<List<ModItem>> fetchMods({
    String period = 'all_time',
    int limit = 20,
    int offset = 0,
  }) async {
    const cacheKey = 'all_mods';

    // Return cache immediately if valid for instant display
    if (_isCacheValid(cacheKey)) {
      return _modsCache[cacheKey]!;
    }
    
    try {
      final QueryOptions options = QueryOptions(
        document: gql(_getModsQuery),
        fetchPolicy: FetchPolicy.cacheFirst, // Try cache first
      );

      final QueryResult result = await _graphqlHelper.queryWithRetry(options);

      if (result.hasException && result.data == null) {
        log('GraphQL error: ${result.exception}');
        return _getFallbackMods();
      }

      final List<dynamic> modsData = result.data?['mod']?['getMods'] ?? [];
      
      // Parse in isolate only for large datasets (> 10 items)
      final List<ModItem> mods;
      if (modsData.length > 10) {
        mods = await compute(_parseModsInIsolate, modsData);
      } else {
        mods = _parseModsInIsolate(modsData);
      }
      
      _updateCache(cacheKey, mods);

      return mods;
    } catch (e) {
      log('Error fetching mods: $e');
      return _getFallbackMods();
    }
  }

  Stream<List<ModItem>> searchModsStream(String query) {
    return _searchController.stream
        .where((q) => q == query)
        .asyncMap((_) => searchMods(query));
  }

  void triggerSearch(String query) {
    _searchController.add(query);
  }

  Future<void> _performSearch(String query) async {}

  Future<List<ModItem>> searchMods(String query) async {
    if (query.trim().isEmpty) {
      return fetchMods();
    }

    final cacheKey = 'search-$query';

    // Return cache immediately if valid
    if (_isCacheValid(cacheKey)) {
      return _modsCache[cacheKey]!;
    }

    try {
      final QueryOptions options = QueryOptions(
        document: gql(_searchModsQuery),
        fetchPolicy: FetchPolicy.cacheFirst, // Try cache first
      );

      final QueryResult result = await _graphqlHelper.queryWithRetry(options);

      if (result.hasException && result.data == null) {
        log('Search error: ${result.exception}');
        return _getFallbackSearch(query);
      }

      final List<dynamic> modsData = result.data?['mod']?['getMods'] ?? [];
      
      // Parse and filter - use isolate only for large datasets
      final List<ModItem> allMods;
      if (modsData.length > 10) {
        allMods = await compute(_parseModsInIsolate, modsData);
      } else {
        allMods = _parseModsInIsolate(modsData);
      }
      
      // Filter locally for better performance
      final lowerQuery = query.toLowerCase();
      final List<ModItem> filteredMods = allMods.where((mod) {
        return mod.title.toLowerCase().contains(lowerQuery) ||
               mod.description.toLowerCase().contains(lowerQuery) ||
               mod.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      }).toList();
      
      _updateCache(cacheKey, filteredMods);

      return filteredMods;
    } catch (e) {
      log('Error searching mods: $e');
      return _getFallbackSearch(query);
    }
  }

  Future<ModItem?> fetchMod(String id) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(_getModQuery),
        variables: {'modId': id},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await _graphqlHelper.queryWithRetry(options);

      if (result.hasException && result.data == null) {
        log('Error fetching mod $id: ${result.exception}');
        return null;
      }

      final dynamic modData = result.data?['mod']?['getMod'];
      if (modData == null) return null;

      return ModItem.fromJson(modData);
    } catch (e) {
      log('Error fetching mod $id: $e');
      return null;
    }
  }

  Future<void> prefetchPopularMods() async {
    final options = QueryOptions(
      document: gql(_getModsQuery),
    );

    await _graphqlHelper.prefetchQuery(options);
  }

  void clearCache() {
    _modsCache.clear();
    _cacheTimestamps.clear();
    _graphqlHelper.clearCache('mods');
  }

  void _updateCache(String key, List<ModItem> mods) {
    _modsCache[key] = mods;
    _cacheTimestamps[key] = DateTime.now();
  }

  bool _isCacheValid(String key) {
    if (!_modsCache.containsKey(key)) return false;

    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;

    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  List<ModItem> _getFallbackMods() {
    if (_cachedFallbackMods != null) {
      return _cachedFallbackMods!;
    }
    
    final now = DateTime.now();
    _cachedFallbackMods = [
      ModItem(
        id: '-1',
        title: 'Enhanced Graphics Pack',
        description: 'Offline fallback - Improves visual quality with better textures, lighting, and effects. Perfect for immersive gameplay experience.',
        rating: 4.8,
        ratingsCount: 5432,
        imageUrl: 'lib/icons/main/mod_test_pfp.png',
        tags: ['Graphics', 'Visual', 'Enhancement', 'Quality'],
        createdAt: now.subtract(const Duration(days: 30)),
        authorId: 'fallback_author_1',
        downloadsCount: 15420,
      ),
      ModItem(
        id: '-2',
        title: 'Ultimate Gameplay Mod',
        description: 'Offline fallback - Complete gameplay overhaul with new mechanics, improved AI, and balanced difficulty.',
        rating: 4.6,
        ratingsCount: 3210,
        imageUrl: 'lib/icons/main/mod_test_pfp.png',
        tags: ['Gameplay', 'Overhaul', 'Mechanics', 'AI'],
        createdAt: now.subtract(const Duration(days: 15)),
        authorId: 'fallback_author_2',
        downloadsCount: 8765,
      ),
      ModItem(
        id: '-3',
        title: 'Audio Enhancement Suite',
        description: 'Offline fallback - High-quality audio improvements with better sound effects and ambient audio.',
        rating: 4.3,
        ratingsCount: 1876,
        imageUrl: 'lib/icons/main/mod_test_pfp.png',
        tags: ['Audio', 'Sound', 'Music', 'Enhancement'],
        createdAt: now.subtract(const Duration(days: 7)),
        authorId: 'fallback_author_3',
        downloadsCount: 4321,
      ),
    ];
    
    return _cachedFallbackMods!;
  }

  List<ModItem> _getFallbackSearch(String query) {
    final fallbackMods = _getFallbackMods();
    final lowerQuery = query.toLowerCase();
    
    return fallbackMods.where((mod) {
      return mod.title.toLowerCase().contains(lowerQuery) ||
             mod.description.toLowerCase().contains(lowerQuery) ||
             mod.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  void dispose() {
    _debounceTimer?.cancel();
    _searchController.close();
    clearCache();
    _cachedFallbackMods = null;
  }
}