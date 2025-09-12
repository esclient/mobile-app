import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:flutter/foundation.dart';

Future<GraphQLClient> initGraphQLClient() async {
  await initHiveForFlutter();
  
  // For development, use a reasonable timeout and better error handling
  final HttpLink httpLink = HttpLink(
    'http://10.0.2.2:8000',
    httpClient: HttpClientWithTimeout(
      timeout: Duration(seconds: 30), // Increased timeout for better reliability
    ),
  );

  return GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(store: InMemoryStore()), // Use in-memory cache for development
  );
}

// Custom HTTP client with timeout and retry logic
class HttpClientWithTimeout extends IOClient {
  final Duration timeout;
  final int maxRetries;
  
  HttpClientWithTimeout({
    required this.timeout,
    this.maxRetries = 3,
  });
  
  @override
  Future<IOStreamedResponse> send(http.BaseRequest request) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        // Create a fresh request for each attempt to avoid "finalized request" errors
        final requestToSend = attempts == 0 ? request : _cloneRequest(request);
        return await super.send(requestToSend).timeout(timeout);
      } catch (e) {
        attempts++;
        debugPrint('Request attempt $attempts failed: $e');
        
        if (attempts >= maxRetries) {
          debugPrint('All $maxRetries attempts failed, giving up');
          rethrow;
        }
        
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(milliseconds: 500 * attempts));
      }
    }
    
    throw Exception('Unexpected error in HttpClientWithTimeout');
  }
  
  /// Clone a request to avoid "finalized request" errors during retries
  http.BaseRequest _cloneRequest(http.BaseRequest original) {
    final cloned = http.Request(original.method, original.url);
    cloned.headers.addAll(original.headers);
    
    // Handle body for different request types
    if (original is http.Request) {
      cloned.body = original.body;
    } else if (original is http.MultipartRequest) {
      // For multipart requests, we can't easily clone, so create a basic request
      debugPrint('Warning: Cannot clone multipart request, using basic request');
    }
    
    return cloned;
  }
}
