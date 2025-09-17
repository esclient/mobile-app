import 'package:graphql_flutter/graphql_flutter.dart';
import '../model/mod_item.dart';

class ModsService {
  final GraphQLClient client;

  ModsService(this.client);

  // Запрос для получения списка модов
  static const String getModsQuery = r'''
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

  Future<List<ModItem>> fetchMods({
    String period = 'all_time',
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(getModsQuery),
        variables: {
          'period': period,
          'limit': limit,
          'offset': offset,
        },
      );

      final QueryResult result = await client.query(options);

      if (result.hasException) {
        print('GraphQL Exception: ${result.exception}');
        // Возвращаем моковые данные в случае ошибки
        return _getMockMods();
      }

      final List<dynamic> modsData = result.data?['mods'] ?? [];
      return modsData.map((json) => ModItem.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching mods: $e');
      // Возвращаем моковые данные в случае ошибки
      return _getMockMods();
    }
  }

  // Моковые данные для демонстрации
  List<ModItem> _getMockMods() {
    return [
      ModItem(
        id: '1',
        title: 'Better Graphics Mod',
        description: 'This mod enhances the visual experience with improved graphics, better lighting, and enhanced textures. Perfect for players who want a more immersive gaming experience.',
        rating: 4.8,
        ratingsCount: 5432,
        imageUrl: 'https://picsum.photos/48/48?random=1',
        tags: ['Graphics', 'Visual', 'Enhancement', 'Quality', 'Immersion'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        authorId: 'author_1',
        downloadsCount: 15420,
      ),
      ModItem(
        id: '2',
        title: 'Ultimate Gameplay Overhaul',
        description: 'Complete gameplay transformation with new mechanics, improved AI, and balanced difficulty settings. A must-have for experienced players.',
        rating: 4.6,
        ratingsCount: 3210,
        imageUrl: 'https://picsum.photos/48/48?random=2',
        tags: ['Gameplay', 'Overhaul', 'Mechanics', 'AI'],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        authorId: 'author_2',
        downloadsCount: 8765,
      ),
      ModItem(
        id: '3',
        title: 'Audio Enhancement Pack',
        description: 'High-quality audio improvements including better sound effects, ambient sounds, and music tracks.',
        rating: 4.3,
        ratingsCount: 1876,
        imageUrl: 'https://picsum.photos/48/48?random=3',
        tags: ['Audio', 'Sound', 'Music'],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        authorId: 'author_3',
        downloadsCount: 4321,
      ),
      ModItem(
        id: '4',
        title: 'Performance Optimizer',
        description: 'Optimizes game performance for better FPS and reduced loading times on lower-end systems.',
        rating: 4.1,
        ratingsCount: 987,
        imageUrl: 'https://picsum.photos/48/48?random=4',
        tags: ['Performance', 'Optimization'],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        authorId: 'author_4',
        downloadsCount: 2109,
      ),
      ModItem(
        id: '5',
        title: 'Content Expansion',
        description: 'Adds new content including quests, items, and characters to extend your gaming experience.',
        rating: 4.9,
        ratingsCount: 7654,
        imageUrl: 'https://picsum.photos/48/48?random=5',
        tags: ['Content', 'Expansion', 'Quests', 'Items', 'Characters'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        authorId: 'author_5',
        downloadsCount: 23456,
      ),
    ];
  }

  // Поиск модов
  Future<List<ModItem>> searchMods(String query) async {
    // Здесь должен быть реальный поиск через GraphQL
    // Пока возвращаем фильтрованные моковые данные
    final allMods = await fetchMods();
    return allMods
        .where((mod) =>
            mod.title.toLowerCase().contains(query.toLowerCase()) ||
            mod.description.toLowerCase().contains(query.toLowerCase()) ||
            mod.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())))
        .toList();
  }
}
