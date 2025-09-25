import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'model/comments.dart';
import 'pages/mods_list_page.dart';
import 'pages/profile_page.dart';
import 'pages/search_test_page.dart';
import 'providers/mods_provider.dart';
import 'services/auth_service.dart';
import 'services/comments.dart';
import 'services/service_locator.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for caching
  await Hive.initFlutter();

  // Initialize services once at startup
  final serviceLocator = ServiceLocator();
  await serviceLocator.initialize();

  runApp(MyApp(serviceLocator: serviceLocator));
}

class MyApp extends StatelessWidget {
  final ServiceLocator serviceLocator;

  const MyApp({super.key, required this.serviceLocator});

  @override
  Widget build(BuildContext context) {
    // Use MultiProvider for better state management
    return MultiProvider(
      providers: [
        // Service providers
        Provider<ServiceLocator>.value(value: serviceLocator),
        Provider.value(value: serviceLocator.modsService),
        ChangeNotifierProvider.value(value: serviceLocator.authService),
        Provider.value(value: serviceLocator.commentService),

        // State providers
        ChangeNotifierProvider<ModsProvider>(
          create: (context) => ModsProvider(serviceLocator.modsService),
          lazy: false, // Initialize immediately for better performance
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appTitle,
        theme: AppTheme.darkTheme,
        home: const ModsListPage(),
        routes: {
          AppRoutes.comments: (context) => Scaffold(
            appBar: AppBar(title: const Text(AppStrings.navComments)),
            body: Builder(
              builder: (context) => CommentsList(
                commentService: Provider.of<CommentService>(context, listen: false)
              ),
            ),
          ),
          AppRoutes.profile: (context) =>
              ProfilePage(authService: context.read<AuthService>()),
          '/search-test': (context) => const SearchTestPage(),
        },
        debugShowCheckedModeBanner: false,

        // Performance optimizations
        builder: (context, child) {
          // Disable glow effect on Android for better performance
          return ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: child!,
          );
        },
      ),
    );
  }
}

class CommentsList extends StatefulWidget {
  final CommentService commentService;

  const CommentsList({super.key, required this.commentService});

  @override
  State<CommentsList> createState() => _CommentsListState();
}

class _CommentsListState extends State<CommentsList>
    with AutomaticKeepAliveClientMixin {
  late Future<List<Comment>> _future;
  final String _commentId = '69';

  // Keep state alive for better performance
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    _future = widget.commentService.fetchComments(_commentId);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return FutureBuilder<List<Comment>>(
      future: _future,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF388E3C)),
          );
        } else if (snap.hasError) {
          return _buildErrorWidget(snap.error.toString());
        }

        final comments = snap.data!;

        if (comments.isEmpty) {
          return _buildEmptyWidget();
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _loadComments();
            });
          },
          color: const Color(0xFF388E3C),
          backgroundColor: const Color(0xFF374151),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            itemCount: comments.length,
            // Optimizations for better performance
            itemExtent: null,
            // Let items size themselves
            cacheExtent: 500,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            itemBuilder: (context, index) {
              final comment = comments[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < comments.length - 1 ? AppSizes.spacing : 0,
                ),
                child: _buildCommentCard(comment),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCommentCard(Comment comment) {
    return Card(
      key: ValueKey('comment_${comment.authorId}_${comment.createdAt}'),
      color: const Color(0xFF181F2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF374151), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              comment.text,
              style: const TextStyle(
                color: Color(0xFFD1D5DB),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSizes.spacing),
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 16,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 4),
                Text(
                  comment.authorId,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(comment.createdAt),
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 16),
          Text(
            'Ошибка: $error',
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _loadComments();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF388E3C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.comment_outlined, size: 64, color: Color(0xFF9CA3AF)),
          SizedBox(height: 16),
          Text(
            'Комментарии не найдены',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
