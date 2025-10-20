import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
import 'utils/app_config.dart';
import 'utils/performance_utils.dart';
import 'widgets/comment_card.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set frame scheduling priority for smoother animations
  SchedulerBinding.instance.scheduleForcedFrame();

  // Initialize Hive in background
  final hiveFuture = Hive.initFlutter();
  
  // Initialize app configuration
  await AppConfig.initialize();

  // Create service locator but don't wait for full initialization
  final serviceLocator = ServiceLocator();
  
  // Run app immediately with splash screen while loading
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(
      hiveFuture: hiveFuture,
      serviceLocator: serviceLocator,
    ),
  ));
}

class SplashScreen extends StatefulWidget {
  final Future hiveFuture;
  final ServiceLocator serviceLocator;

  const SplashScreen({super.key, required this.hiveFuture, required this.serviceLocator});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await widget.hiveFuture;
      
      // Initialize services in parallel for faster startup
      await Future.wait([
        widget.serviceLocator.initialize(),
        // Add small delay to ensure smooth animation
        Future.delayed(const Duration(milliseconds: 500)),
      ]);
      
      widget.serviceLocator.authService.login('test@example.com', userId: '999');
      
      if (mounted) {
        // Schedule navigation to next frame for smoother transition
        PerformanceUtils.runInNextFrame(() {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => 
                MyApp(serviceLocator: widget.serviceLocator),
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        });
      }
    } catch (e) {
      // Handle initialization error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Initialization failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF374151),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.rocket_launch,
                size: 60,
                color: Color(0xFF388E3C),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'ESClient',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Loading mods...',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),
            const SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                color: Color(0xFF388E3C),
                backgroundColor: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
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