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
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.navComments)),
      body: const CommentsList(),
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
  final String _modId = '69';

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

    return Consumer<CommentsProvider>(
      builder: (context, provider, child) {
        final header = Container(
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF374151),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  provider.comments.length.toString(),
                  style: const TextStyle(
                    color: Color(0xFFE5E7EB),
                    fontSize: 12,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );

        if (provider.isLoading && provider.comments.isEmpty) {
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

        if (provider.error != null && provider.comments.isEmpty) {
          return Column(
            children: [
              header,
              Expanded(child: _buildErrorWidget(provider.error!, provider)),
            ],
          );
        }

        if (provider.comments.isEmpty) {
          return Column(
            children: [
              header,
              Expanded(child: _buildEmptyWidget()),
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
                  await provider.loadComments(_modId);
                },
                color: const Color(0xFF388E3C),
                backgroundColor: const Color(0xFF374151),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                    vertical: 0,
                  ),
                  itemCount: provider.comments.length,
                  cacheExtent: 1000,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: false,
                  itemBuilder: (context, index) {
                    final comment = provider.comments[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < provider.comments.length - 1
                            ? AppSizes.spacing
                            : 0,
                      ),
                      child: CommentCard(
                        comment: comment,
                        currentUserId: ServiceLocator().authService.currentUserId,
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
    );
  }

  Widget _buildErrorWidget(String error, CommentsProvider provider) {
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
              provider.loadComments(_modId);
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
}