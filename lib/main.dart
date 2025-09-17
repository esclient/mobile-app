import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'services/graphql_client.dart';
import 'services/comments.dart';
import 'services/mods_service.dart';
import 'model/comments.dart';
import 'pages/mods_list_page.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';

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
      title: AppStrings.appTitle,
      theme: AppTheme.darkTheme,
      home: ModsListPage(modsService: modsService),
      routes: {
        AppRoutes.comments: (context) => Scaffold(
          appBar: AppBar(title: const Text(AppStrings.navComments)),
          body: CommentsList(commentService: commentService),
        ),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class CommentsList extends StatefulWidget {
  final CommentService commentService;
  const CommentsList({super.key, required this.commentService});

  @override
  State<CommentsList> createState() => _CommentsListState();
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(height: 16),
                Text(
                  'Ошибка: ${snap.error}',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
        final comments = snap.data!;
        
        if (comments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.comment_outlined,
                  size: 64,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(height: 16),
                Text(
                  'Комментарии не найдены',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _future = widget.commentService.fetchComments('69');
            });
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            itemCount: comments.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSizes.spacing),
            itemBuilder: (context, index) {
              final comment = comments[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.text,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSizes.spacing),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            comment.authorId,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateTime.fromMillisecondsSinceEpoch(comment.createdAt * 1000)
                                .toString()
                                .substring(0, 16),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
