import 'package:graphql_flutter/graphql_flutter.dart';
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

  Future<List<Comment>> fetchComments(String modId) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_getCommentsQuery),
        variables: {'modId': modId},
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final List data = result.data!['getComments'] as List;
    return data.map((e) => Comment.fromJson(e)).toList();
  }
}
