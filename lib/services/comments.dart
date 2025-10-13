import 'package:graphql_flutter/graphql_flutter.dart';
import '../model/comments.dart';
import 'dart:developer';

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

const String _getDeleteCommentMutation = r'''
  mutation DeleteComment($comment_id: ID!) {
    deleteComment(input: { comment_id: $comment_id})
  }
''';

class CommentService {
  final GraphQLClient _client;
  CommentService(this._client);

  Future<List<Comment>> fetchComments(String modId) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(_getCommentsQuery),
          variables: {'modId': modId},
        ),
      );

      if (result.hasException) {
        log('GraphQL exception while loading comments for mod $modId: ${result.exception}');
        return _mockComments(modId);
      }

      final List data = result.data?['getComments'] as List? ?? [];
      return data.map((e) => Comment.fromJson(e)).toList();
    } catch (e) {
      log('Error loading comments for mod $modId: $e');
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

    return result.data?['deleteComment'] ?? false;
  } catch(e) {
    log('Error deleting comment: $e');
    rethrow;
  }
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
