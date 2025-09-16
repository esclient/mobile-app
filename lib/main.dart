import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'services/graphql_client.dart';
import 'services/comments.dart';
import 'services/mods_service.dart';
import 'model/comments.dart';
import 'pages/mods_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final client = await initGraphQLClient();
  runApp(MyApp(client: client));
}

class MyApp extends StatelessWidget {
  final GraphQLClient client;
  const MyApp({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    final commentService = CommentService(client);
    final modsService = ModsService(client);
    
    return MaterialApp(
      title: 'ESCLIENT Mobile',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF1F2937),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F2937),
          foregroundColor: Colors.white,
        ),
      ),
      home: ModsListPage(modsService: modsService), // Передаем сервис модов
      routes: {
        '/comments': (context) => Scaffold(
          appBar: AppBar(title: const Text('Комментарии')),
          body: CommentsList(commentService: commentService),
        ),
      },
    );
  }
}

class CommentsList extends StatefulWidget {
  final CommentService commentService;
  const CommentsList({super.key, required this.commentService});

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
          return const Center(child: CircularProgressIndicator());
        } else if (snap.hasError) {
          return Center(child: Text('Ошибка: ${snap.error}'));
        }
        final comments = snap.data!;
        return ListView(
          children: comments
              .map(
                (c) => ListTile(
                  title: Text(
                    c.text,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${c.authorId} • ${DateTime.fromMillisecondsSinceEpoch(c.createdAt * 1000)}',
                    style: const TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
