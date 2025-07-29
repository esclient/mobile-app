import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'services/graphql_client.dart';
import 'services/comments.dart';
import 'model/comments.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final client = await initGraphQLClient();
  runApp(MyApp(client: client));
}

class MyApp extends StatelessWidget {
  final GraphQLClient client;
  MyApp({required this.client});

  @override
  Widget build(BuildContext context) {
    final commentService = CommentService(client);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Комментарии')),
        body: CommentsList(commentService: commentService),
      ),
    );
  }
}

class CommentsList extends StatefulWidget {
  final CommentService commentService;
  CommentsList({required this.commentService});

  @override
  _CommentsListState createState() => _CommentsListState();
}

class _CommentsListState extends State<CommentsList> {
  late Future<List<Comment>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.commentService.fetchComments('69');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Comment>>(
      future: _future,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snap.hasError) {
          return Center(child: Text('Ошибка: ${snap.error}'));
        }
        final comments = snap.data!;
        return ListView(
          children: comments
              .map(
                (c) => ListTile(
                  title: Text(c.text),
                  subtitle: Text(
                    '${c.authorId} • ${DateTime.fromMillisecondsSinceEpoch(c.createdAt * 1000)}',
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
