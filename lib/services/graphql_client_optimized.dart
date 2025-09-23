import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Optimized GraphQL client with better caching and error handling
Future<GraphQLClient> initGraphQLClient() async {
  await initHiveForFlutter();
  
  // Configure the HTTP link with timeout
  final HttpLink httpLink = HttpLink(
    'http://10.0.2.2:8000',
    defaultHeaders: {
      'Content-Type': 'application/json',
    },
  );
  
  // Add auth link if needed (placeholder for future auth implementation)
  final Link link = httpLink;
  
  // Configure optimized cache
  final GraphQLCache cache = GraphQLCache(
    store: HiveStore(),
    partialDataPolicy: PartialDataCachePolicy.accept, // Accept partial data for better UX
  );
  
  // Create client with optimizations
  return GraphQLClient(
    link: link,
    cache: cache,
    defaultPolicies: DefaultPolicies(
      query: Policies(
        fetch: FetchPolicy.cacheFirst, // Try cache first for better performance
        error: ErrorPolicy.all, // Return both data and errors
        cacheReread: CacheRereadPolicy.mergeOptimistic, // Merge cache updates
      ),
      mutate: Policies(
        fetch: FetchPolicy.noCache,
        error: ErrorPolicy.all,
      ),
    ),
    queryRequestTimeout: const Duration(seconds: 30), // Add timeout
    connectFn: (uri, protocols) async {
      // Custom connection function if needed for WebSocket
      return null;
    },
  );
}

/// Helper class for managing GraphQL operations with retry logic
class GraphQLHelper {
  final GraphQLClient client;
  
  GraphQLHelper(this.client);
  
  /// Execute a query with automatic retry on failure
  Future<QueryResult> queryWithRetry(
    QueryOptions options, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    QueryResult? lastResult;
    
    while (attempts < maxRetries) {
      try {
        lastResult = await client.query(options);
        
        // If successful or has data (even with errors), return
        if (!lastResult.hasException || lastResult.data != null) {
          return lastResult;
        }
        
        // Check if it's a network error that's worth retrying
        if (_shouldRetry(lastResult.exception)) {
          attempts++;
          if (attempts < maxRetries) {
            await Future.delayed(retryDelay * attempts); // Exponential backoff
            continue;
          }
        }
        
        return lastResult;
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          rethrow;
        }
        await Future.delayed(retryDelay * attempts);
      }
    }
    
    return lastResult!;
  }
  
  /// Check if an exception is worth retrying
  bool _shouldRetry(OperationException? exception) {
    if (exception == null) return false;
    
    // Retry on network errors
    if (exception.linkException != null) {
      return true;
    }
    
    // Don't retry on GraphQL errors (like validation errors)
    if (exception.graphqlErrors.isNotEmpty) {
      return false;
    }
    
    return true;
  }
  
  /// Clear cache for a specific query
  Future<void> clearCache(String queryId) async {
    await client.cache.store.reset();
  }
  
  /// Prefetch data for better performance
  Future<void> prefetchQuery(QueryOptions options) async {
    try {
      await client.query(options.copyWith(
        fetchPolicy: FetchPolicy.networkOnly,
      ));
    } catch (e) {
      // Silently fail prefetch
      print('Prefetch failed: $e');
    }
  }
}