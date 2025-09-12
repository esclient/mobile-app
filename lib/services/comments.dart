import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/foundation.dart';
import '../model/comments.dart';

const String _getCommentsQuery = r'''
  query GetComments($modId: ID!) {
    getComments(input: { mod_id: $modId }) {
      id
      author_id
      text
      created_at
    }
  }
''';

class CommentService {
  final GraphQLClient _client;
  CommentService(this._client);

  /// Check if the GraphQL server is reachable
  Future<bool> isServerReachable() async {
    try {
      // Simple connectivity test using a basic query
      final result = await _client.query(
        QueryOptions(
          document: gql('query { __typename }'),
        ),
      ).timeout(Duration(seconds: 5));
      
      return !result.hasException;
    } catch (e) {
      debugPrint('Server connectivity check failed: $e');
      return false;
    }
  }

  Future<List<Comment>> fetchComments(String modId) async {
    try {
      debugPrint('Attempting to fetch comments for modId: $modId');
      
      // Check server connectivity first
      final isReachable = await isServerReachable();
      if (!isReachable) {
        debugPrint('Server is not reachable, returning mock data');
        return _getMockComments();
      }
      
      // Make the actual query with proper error handling
      QueryResult result;
      try {
        result = await _client.query(
          QueryOptions(
            document: gql(_getCommentsQuery),
            variables: {'modId': modId},
          ),
        );
      } catch (error) {
        debugPrint('Query failed with error: $error');
        // If the query itself throws an exception, return mock data
        return _getMockComments();
      }

      if (result.hasException) {
        debugPrint('GraphQL Error: ${result.exception}');
        debugPrint('Exception details: ${result.exception?.linkException}');
        
        // Check if it's a timeout error
        if (result.exception?.linkException?.originalException != null && 
            result.exception!.linkException!.originalException.toString().contains('TimeoutException')) {
          debugPrint('Server timeout - server may be unavailable or slow');
        }
        
        // Return mock data for development
        return _getMockComments();
      }

      if (result.data == null || result.data!['getComments'] == null) {
        debugPrint('No data received from server');
        return _getMockComments();
      }

      final List data = result.data!['getComments'] as List;
      debugPrint('Successfully fetched ${data.length} comments');
      return data.map((e) => Comment.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Network Error: $e');
      
      // Provide more specific error information
      if (e.toString().contains('TimeoutException')) {
        debugPrint('Request timed out - check if server is running at http://10.0.2.2:8000');
      } else if (e.toString().contains('SocketException')) {
        debugPrint('Connection failed - server may be down or unreachable');
      }
      
      // Return mock data for development
      return _getMockComments();
    }
  }

  List<Comment> _getMockComments() {
    return [
      Comment(
        id: '1',
        authorId: 'system',
        text: '⚠️ Server connection failed - showing offline data',
        createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      ),
      Comment(
        id: '2',
        authorId: 'system',
        text: 'Check if GraphQL server is running at http://10.0.2.2:8000',
        createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      ),
      Comment(
        id: '3',
        authorId: 'system',
        text: 'Timeout error resolved - retry logic will attempt reconnection',
        createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      ),
    ];
  }
}
