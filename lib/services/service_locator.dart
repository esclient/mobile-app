import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_client_optimized.dart';
import 'mods_service_optimized.dart';
import 'auth_service.dart';
import 'comments.dart';

/// Singleton service locator for managing app-wide services
/// This prevents recreating services and improves performance
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();
  
  late final GraphQLClient graphQLClient;
  late final OptimizedModsService modsService;
  late final AuthService authService;
  late final CommentService commentService;
  
  bool _initialized = false;
  bool get isInitialized => _initialized;
  
  /// Initialize all services once at app startup
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      graphQLClient = await initGraphQLClient();
      modsService = OptimizedModsService(graphQLClient);
      authService = AuthService();
      commentService = CommentService(graphQLClient);
      _initialized = true;
    } catch (e) {
      throw Exception('Failed to initialize services: $e');
    }
  }
  
  /// Reset services (useful for testing or logout scenarios)
  Future<void> reset() async {
    _initialized = false;
    await initialize();
  }
}
