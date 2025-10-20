import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:developer';

/// Optimized GraphQL client with better caching and error handling
Future<GraphQLClient> initGraphQLClient() async {
  // Hive is already initialized in main.dart, don't block here
  try {
    await initHiveForFlutter();
  } catch (e) {
    // Already initialized, continue
    log('Hive already initialized: $e');
  }
  
  // Configure the HTTP link with shorter timeout for better responsiveness
  final HttpLink httpLink = HttpLink(
    'http://10.0.2.2:8000/graphql', 
    defaultHeaders: {
      'Content-Type': 'application/json',
      'Keep-Alive': 'timeout=15, max=100', // Keep connections alive
    },
  );
  
  // Add auth link if needed (placeholder for future auth implementation)
  final Link link = httpLink;
  
  // Configure optimized cache with memory-first strategy
  final GraphQLCache cache = GraphQLCache(
    store: HiveStore(),
    partialDataPolicy: PartialDataCachePolicy.accept, // Accept partial data for better UX
    dataIdFromObject: (data) {
      // Optimize cache key generation
      if (data.containsKey('id')) {
        return data['id'] as String?;
      }
      return null;
    },
  );
  
  // Create client with aggressive caching for performance
  return GraphQLClient(
    link: link,
    cache: cache,
    defaultPolicies: DefaultPolicies(
      query: Policies(
        fetch: FetchPolicy.cacheAndNetwork, // Return cache immediately, then update
        error: ErrorPolicy.all, // Return both data and errors
        cacheReread: CacheRereadPolicy.mergeOptimistic, // Merge cache updates
      ),
      mutate: Policies(
        fetch: FetchPolicy.noCache,
        error: ErrorPolicy.all,
      ),
      subscribe: Policies(
        fetch: FetchPolicy.noCache,
        error: ErrorPolicy.all,
      ),
    ),
    queryRequestTimeout: const Duration(seconds: 15), // Reduced timeout for better UX
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
    client.cache.store.reset();
  }
  
  /// Prefetch data for better performance
  Future<void> prefetchQuery(QueryOptions options) async {
    try {
      await client.query(QueryOptions(
        document: options.document,
        variables: options.variables,
        fetchPolicy: FetchPolicy.networkOnly,
      ));
    } catch (e) {
      // Silently fail prefetch
      log('Prefetch failed: $e');
    }
  }
}