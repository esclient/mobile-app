import 'package:graphql_flutter/graphql_flutter.dart';
import '../model/comments.dart';
import 'dart:developer' as dev;

const String _getCommentsQuery = r'''
    query GetComments($modId: ID!) {
    comment {
      getComments(input: { mod_id: $modId }) {
        id
        author_id
        text
        created_at
      }
    }
  }
''';

const String _getDeleteCommentMutation = r'''
  mutation DeleteComment($comment_id: ID!) {
    comment {
      deleteComment(input: { comment_id: $comment_id })
    }
  }
''';

class CommentService {
  final GraphQLClient _client;

  CommentService(this._client);

  Future<List<Comment>> fetchComments(String modId) async {
    print('🔵 CommentService: Fetching comments for modId: $modId');
    
    // Check if this is a fallback mod - return empty list immediately
    if (_isFallbackMod(modId)) {
      print('⚠️ Fallback mod detected ($modId), returning empty comments');
      return [];
    }
   
    try {
      print('🔵 Executing GraphQL query...');
      final result = await _client.query(
        QueryOptions(
          document: gql(_getCommentsQuery),
          variables: {'modId': modId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      
      print('🔵 Response received');
      print('🔵 Has exception: ${result.hasException}');
      print('🔵 Data: ${result.data}');
     
      if (result.hasException) {
        print('🔴 Exception: ${result.exception}');
        
        // Check if it's a validation error (not a network error)
        if (_isValidationError(result.exception)) {
          print('🔴 Validation error detected, throwing exception');
          throw result.exception!;
        }
        
        // Only return mocks for network errors
        print('⚠️ Network error, returning mock comments');
        return _mockComments(modId);
      }
      
      final List data = result.data?['comment']?['getComments'] as List? ?? [];
      print('🟢 Successfully parsed ${data.length} comments');
     
      return data.map((e) => Comment.fromJson(e)).toList();
    } catch (e) {
      print('🔴 Error: $e');
      
      // If it's already an OperationException, check if it's a validation error
      if (e is OperationException && _isValidationError(e)) {
        print('🔴 Rethrowing validation error');
        rethrow;
      }
      
      // For other errors (network, timeout, etc.), return mocks
      print('⚠️ Returning mock comments due to error');
      return _mockComments(modId);
    }
  }

  Future<bool> deleteComment(String commentId) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(_getDeleteCommentMutation),
          variables: {'comment_id': commentId},
        ),
      );
   
      if (result.hasException) {
        throw result.exception!;
      }
     
      return result.data?['comment']?['deleteComment'] ?? false;
    } catch(e) {
      dev.log('Error deleting comment: $e');
      rethrow;
    }
  }

  /// Check if mod ID belongs to a fallback mod
  bool _isFallbackMod(String modId) {
    return modId.startsWith('fallback_') || 
           modId.startsWith('-') ||
           modId == '1' || 
           modId == '2' || 
           modId == '3';
  }

  /// Check if the exception is a validation error (not a network error)
  bool _isValidationError(OperationException? exception) {
    if (exception == null) return false;
    
    // Check if there are GraphQL errors (validation/business logic errors)
    if (exception.graphqlErrors.isNotEmpty) {
      // Look for validation-related error messages
      final hasValidationError = exception.graphqlErrors.any((error) {
        final message = error.message.toLowerCase();
        return message.contains('неверное поле') || 
               message.contains('должно быть целым числом') ||
               message.contains('invalid') ||
               message.contains('validation');
      });
      
      if (hasValidationError) return true;
    }
    
    // If there's a linkException, it's likely a network error
    return exception.linkException == null && exception.graphqlErrors.isNotEmpty;
  }

  List<Comment> _mockComments(String modId) {
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return [
      Comment(
        id: 'mock-$modId-1',
        authorId: 'mock_user_1',
        text: 'Мок‑комментарий к моду $modId: всё работает офлайн.',
        createdAt: nowSeconds - 3600,
      ),
      Comment(
        id: 'mock-$modId-2',
        authorId: 'mock_user_2',
        text: 'Ещё один тестовый комментарий. Подключение недоступно, показаны заглушки.',
        createdAt: nowSeconds - 7200,
      ),
      Comment(
        id: 'mock-$modId-3',
        authorId: 'mock_user_3',
        text: 'Обновите страницу позже, чтобы загрузить реальные данные.',
        createdAt: nowSeconds - 10800,
      ),
    ];
  }
}