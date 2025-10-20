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

const String _createCommentMutation = r'''
  mutation CreateComment($mod_id: ID!, $author_id: ID!, $text: String!) {
    comment {
      createComment(input: { mod_id: $mod_id, author_id: $author_id, text: $text })
    }
  }
''';

const String _deleteCommentMutation = r'''
  mutation DeleteComment($comment_id: ID!) {
    comment {
      deleteComment(input: { comment_id: $comment_id })
    }
  }
''';

const String _editCommentMutation = r'''
  mutation EditComment($comment_id: ID!, $text: String!) {
    comment {
      editComment(input: { comment_id: $comment_id, text: $text })
    }
  }
''';

class CommentService {
  final GraphQLClient _client;

  CommentService(this._client);

  Future<List<Comment>> fetchComments(String modId) async {
    dev.log('Fetching comments for modId: $modId');
    
    if (_isFallbackMod(modId)) {
      dev.log('Fallback mod detected ($modId), returning empty comments');
      return [];
    }
   
    try {
      dev.log('Executing GraphQL query...');
      final result = await _client.query(
        QueryOptions(
          document: gql(_getCommentsQuery),
          variables: {'modId': modId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      
      dev.log('Response received');
      dev.log('Has exception: ${result.hasException}');
      dev.log('Data: ${result.data}');
     
      if (result.hasException) {
        dev.log('Exception: ${result.exception}');
        
        if (_isValidationError(result.exception)) {
          dev.log('Validation error detected, throwing exception');
          throw result.exception!;
        }
        
        dev.log('Network error, returning mock comments');
        return _mockComments(modId);
      }
      
      final List data = result.data?['comment']?['getComments'] as List? ?? [];
      dev.log('Successfully parsed ${data.length} comments');
     
      return data.map((e) => Comment.fromJson(e)).toList();
    } catch (e) {
      dev.log('Error: $e');
      
      if (e is OperationException && _isValidationError(e)) {
        dev.log('Rethrowing validation error');
        rethrow;
      }
      
      dev.log('Returning mock comments due to error');
      return _mockComments(modId);
    }
  }

  Future<String> createComment({
    required String modId,
    required String authorId,
    required String text,
  }) async {
    try {
      dev.log('Creating comment for mod: $modId by author: $authorId');
      
      final result = await _client.mutate(
        MutationOptions(
          document: gql(_createCommentMutation),
          variables: {
            'mod_id': modId,
            'author_id': authorId,
            'text': text,
          },
        ),
      );

      dev.log('Response received');
      dev.log('Has exception: ${result.hasException}');
      dev.log('Data: ${result.data}');
    
      if (result.hasException) {
        dev.log('Exception: ${result.exception}');
        throw result.exception!;
      }
      
      final commentId = result.data?['comment']?['createComment'] as String? ?? '';
      dev.log('Successfully created comment with ID: $commentId');
      return commentId;
    } catch(e) {
      dev.log('Error creating comment: $e');
      rethrow;
    }
  }

  Future<bool> deleteComment(String commentId) async {
    try {
      dev.log('Deleting comment: $commentId');
      final result = await _client.mutate(
        MutationOptions(
          document: gql(_deleteCommentMutation),
          variables: {'comment_id': commentId},
        ),
      );

      dev.log('Response received');
      dev.log('Has exception: ${result.hasException}');
      dev.log('Data: ${result.data}');
    
      if (result.hasException) {
        dev.log('Exception: ${result.exception}');
        throw result.exception!;
      }
      
      final success = result.data?['comment']?['deleteComment'] ?? false;
      dev.log('Successfully deleted comment: $success');
      return success;
    } catch(e) {
      dev.log('Error deleting comment: $e');
      rethrow;
    }
  }

  Future<bool> editComment({
    required String commentId,
    required String text,
  }) async {
    try {
      dev.log('Editing comment: $commentId');
      final result = await _client.mutate(
        MutationOptions(
          document: gql(_editCommentMutation),
          variables: {
            'comment_id': commentId,
            'text': text,
          },
        ),
      );

      dev.log('Response received');
      dev.log('Has exception: ${result.hasException}');
      dev.log('Data: ${result.data}');
    
      if (result.hasException) {
        dev.log('Exception: ${result.exception}');
        throw result.exception!;
      }
      
      final success = result.data?['comment']?['editComment'] ?? false;
      dev.log('Successfully edited comment: $success');
      return success;
    } catch(e) {
      dev.log('Error editing comment: $e');
      rethrow;
    }
  }
  
  /// Check if mod ID belongs to a fallback mod
  bool _isFallbackMod(String modId) {
    return modId.startsWith('fallback_') || 
           modId.startsWith('-');
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