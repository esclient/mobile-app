import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/comments_provider.dart';

import 'pages/mods_list_page.dart';
import 'pages/profile_page.dart';
import 'pages/search_test_page.dart';
import 'providers/mods_provider.dart';
import 'services/auth_service.dart';
import 'services/service_locator.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';
import 'widgets/comment_card.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  final serviceLocator = ServiceLocator();
  await serviceLocator.initialize();

  serviceLocator.authService.login('test@example.com', userId: '999');

  runApp(MyApp(serviceLocator: serviceLocator));
}

class MyApp extends StatelessWidget {
  final ServiceLocator serviceLocator;

  const MyApp({super.key, required this.serviceLocator});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ServiceLocator>.value(value: serviceLocator),
        Provider.value(value: serviceLocator.modsService),
        ChangeNotifierProvider.value(value: serviceLocator.authService),
        Provider.value(value: serviceLocator.commentService),
        
        ChangeNotifierProvider<ModsProvider>(
          create: (context) => ModsProvider(serviceLocator.modsService),
          lazy: true,
        ),
        
        ChangeNotifierProvider<CommentsProvider>(
          create: (context) => CommentsProvider(serviceLocator.commentService),
          lazy: true,
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appTitle,
        theme: AppTheme.darkTheme,
        home: const ModsListPage(),
        routes: {
          AppRoutes.comments: (context) => const CommentsPage(),
          AppRoutes.profile: (context) =>
              ProfilePage(authService: context.read<AuthService>()),
          '/search-test': (context) => const SearchTestPage(),
        },
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: child!,
          );
        },
      ),
    );
  }
}

class CommentsPage extends StatelessWidget {
  const CommentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: _CommentsAppBar(),
      ),
      body: CommentsList(),
    );
  }
}

class _CommentsAppBar extends StatelessWidget {
  const _CommentsAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(AppStrings.navComments),
    );
  }
}

class CommentsList extends StatefulWidget {
  const CommentsList({super.key});

  @override
  State<CommentsList> createState() => _CommentsListState();
}

class _CommentsListState extends State<CommentsList>
    with AutomaticKeepAliveClientMixin {
  
  static const String _modId = '69';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommentsProvider>().loadComments(_modId);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final authService = context.read<AuthService>();

    // ✅ FIX: Use Selector to only rebuild on specific changes
    return Selector<CommentsProvider, ({List comments, bool isLoading, String? error})>(
      selector: (_, provider) => (
        comments: provider.comments,
        isLoading: provider.isLoading,
        error: provider.error,
      ),
      builder: (context, data, child) {
        final header = child!;

        if (data.isLoading && data.comments.isEmpty) {
          return Column(
            children: [
              header,
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF388E3C)),
                ),
              ),
            ],
          );
        }

        if (data.error != null && data.comments.isEmpty) {
          return Column(
            children: [
              header,
              Expanded(child: _buildErrorWidget(data.error!)),
            ],
          );
        }

        if (data.comments.isEmpty) {
          return Column(
            children: [
              header,
              const Expanded(child: _EmptyCommentsWidget()),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await context.read<CommentsProvider>().loadComments(_modId);
                },
                color: const Color(0xFF388E3C),
                backgroundColor: const Color(0xFF374151),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                    vertical: 0,
                  ),
                  itemCount: data.comments.length,
                  cacheExtent: 1000, // ✅ FIX: Increased cache
                  addAutomaticKeepAlives: true,
                  addRepaintBoundaries: true,
                  itemBuilder: (context, index) {
                    final comment = data.comments[index];
                    return Padding(
                      key: ValueKey('comment_${comment.id}'),
                      padding: EdgeInsets.only(
                        bottom: index < data.comments.length - 1
                            ? AppSizes.spacing
                            : 0,
                      ),
                      child: CommentCard(
                        comment: comment,
                        currentUserId: authService.currentUserId,
                        onTap: () {
                          // Handle comment tap if needed
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
      child: const _CommentsHeader(), // ✅ FIX: Made const
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
              context.read<CommentsProvider>().loadComments(_modId);
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
}

// ✅ FIX: Extracted empty widget as const
class _EmptyCommentsWidget extends StatelessWidget {
  const _EmptyCommentsWidget();

  @override
  Widget build(BuildContext context) {
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
}

class _CommentsHeader extends StatelessWidget {
  const _CommentsHeader(); // ✅ FIX: Made const constructor

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text(
            'Комментарии',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Selector<CommentsProvider, int>(
            selector: (_, provider) => provider.comments.length,
            builder: (context, count, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF374151),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Color(0xFFE5E7EB),
                    fontSize: 12,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}