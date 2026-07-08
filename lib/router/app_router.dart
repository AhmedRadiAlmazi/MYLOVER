import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'scaffold_with_nav_bar.dart';
import '../core/models/app_models.dart';

// Auth
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/pairing_screen.dart';

// Home
import '../features/home/screens/home_screen.dart';

// Chat
import '../features/chat/screens/chat_screen.dart';

// Memories
import '../features/memories/screens/memories_screen.dart';
import '../features/memories/screens/memory_detail_screen.dart';
import '../features/memories/screens/gallery_screen.dart';
import '../features/memories/screens/image_viewer_screen.dart';

// Diary
import '../features/diary/screens/diary_screen.dart';
import '../features/diary/screens/diary_entry_screen.dart';

// Calendar
import '../features/calendar/screens/calendar_screen.dart';

// Wishes & Bucket List
import '../features/wishes/screens/wishes_screen.dart';
import '../features/wishes/screens/add_edit_wish_screen.dart';
import '../features/wishes/screens/complete_wish_screen.dart';
import '../features/bucket_list/screens/bucket_list_screen.dart';

// Games
import '../features/games/screens/games_screen.dart';
import '../features/games/screens/xo_game_screen.dart';
import '../features/games/screens/truth_dare_screen.dart';
import '../features/games/screens/who_knows_screen.dart';
import '../features/games/screens/complete_sentence_screen.dart';
import '../features/games/screens/draw_guess_screen.dart';
import '../features/games/screens/voice_challenge_screen.dart';
import '../features/games/screens/wheel_screen.dart';
import '../features/games/screens/memories_quiz_screen.dart';
import '../features/games/screens/guess_picture_screen.dart';
import '../features/games/screens/achievements_screen.dart';

// Stats & AI
import '../features/stats/screens/stats_screen.dart';
import '../features/ai/screens/ai_screen.dart';

// Profile & Settings
import '../features/profile/screens/profile_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/settings/screens/security_screen.dart';

// Other Features
import '../features/scheduled_messages/screens/scheduled_messages_screen.dart';
import '../features/scheduled_messages/screens/daily_messages_screen.dart';
import '../features/surprise_box/screens/surprise_box_screen.dart';
import '../features/countdown/screens/countdown_screen.dart';
import '../features/map/screens/memory_map_screen.dart';
import '../features/music/screens/music_screen.dart';
import '../features/shared_book/screens/shared_book_screen.dart';
import '../features/shared_book/screens/add_edit_page_screen.dart';
import '../features/shared_book/screens/page_details_screen.dart';
import '../features/secret_box/screens/secret_box_screen.dart';
import '../features/gift_library/screens/gift_library_screen.dart';
import '../features/drawing/screens/drawing_screen.dart';
import '../features/stories/screens/stories_screen.dart';

// ── Custom Page Transition ────────────────────────────────────────
Page<T> _slidePage<T>(BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
  final chatNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'chat');
  final calendarNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'calendar');
  final profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    routes: [
      // ── Auth Routes ──────────────────────────────────────
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) => _slidePage(context, state, const OnboardingScreen()),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => _slidePage(context, state, const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => _slidePage(context, state, const RegisterScreen()),
      ),
      GoRoute(
        path: '/pairing',
        name: 'pairing',
        pageBuilder: (context, state) => _slidePage(context, state, const PairingScreen()),
      ),

      // ── Main Shell Route ─────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: chatNavigatorKey,
            routes: [
              GoRoute(
                path: '/chat',
                name: 'chat',
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: calendarNavigatorKey,
            routes: [
              GoRoute(
                path: '/calendar',
                name: 'calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Memories ─────────────────────────────────────────
      GoRoute(
        path: '/memories',
        name: 'memories',
        pageBuilder: (context, state) => _slidePage(context, state, const MemoriesScreen()),
      ),
      GoRoute(
        path: '/memory-detail',
        name: 'memory-detail',
        builder: (context, state) => const MemoryDetailScreen(),
      ),
      GoRoute(
        path: '/gallery',
        name: 'gallery',
        builder: (context, state) => const GalleryScreen(),
      ),
      GoRoute(
        path: '/image-viewer',
        name: 'image-viewer',
        builder: (context, state) {
          final imageUrl = state.extra as String? ?? '';
          return ImageViewerScreen(imageUrl: imageUrl);
        },
      ),

      // ── Diary ────────────────────────────────────────────
      GoRoute(
        path: '/diary',
        name: 'diary',
        builder: (context, state) => const DiaryScreen(),
      ),
      GoRoute(
        path: '/diary-entry',
        name: 'diary-entry',
        builder: (context, state) {
          final entry = state.extra as DiaryModel?;
          return DiaryEntryScreen(entry: entry);
        },
      ),

      // ── Calendar ─────────────────────────────────────────

      // ── Wishes & Bucket List ─────────────────────────────
      GoRoute(
        path: '/wishes',
        name: 'wishes',
        builder: (context, state) => const WishesScreen(),
      ),
      GoRoute(
        path: '/wishes/new',
        name: 'wishes-new',
        builder: (context, state) => const AddEditWishScreen(),
      ),
      GoRoute(
        path: '/wishes/complete/:id',
        name: 'wishes-complete',
        builder: (context, state) => CompleteWishScreen(wishId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/bucket-list',
        name: 'bucket-list',
        builder: (context, state) => const BucketListScreen(),
      ),

      // ── Games ────────────────────────────────────────────
      GoRoute(
        path: '/games',
        name: 'games',
        builder: (context, state) => const GamesScreen(),
      ),
      GoRoute(
        path: '/xo-game',
        name: 'xo-game',
        builder: (context, state) => const XOGameScreen(),
      ),
      GoRoute(
        path: '/truth-dare',
        name: 'truth-dare',
        builder: (context, state) => const TruthDareScreen(),
      ),
      GoRoute(
        path: '/who-knows',
        name: 'who-knows',
        builder: (context, state) => const WhoKnowsScreen(),
      ),
      GoRoute(
        path: '/complete-sentence',
        name: 'complete-sentence',
        builder: (context, state) => const CompleteSentenceScreen(),
      ),
      GoRoute(
        path: '/draw-guess',
        name: 'draw-guess',
        builder: (context, state) => const DrawGuessScreen(),
      ),
      GoRoute(
        path: '/voice-challenge',
        name: 'voice-challenge',
        builder: (context, state) => const VoiceChallengeScreen(),
      ),
      GoRoute(
        path: '/wheel-surprises',
        name: 'wheel-surprises',
        builder: (context, state) => const WheelScreen(),
      ),
      GoRoute(
        path: '/memories-quiz',
        name: 'memories-quiz',
        builder: (context, state) => const MemoriesQuizScreen(),
      ),
      GoRoute(
        path: '/guess-picture',
        name: 'guess-picture',
        builder: (context, state) => const GuessPictureScreen(),
      ),
      GoRoute(
        path: '/achievements',
        name: 'achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),

      // ── Stats & AI ───────────────────────────────────────
      GoRoute(
        path: '/stats',
        name: 'stats',
        builder: (context, state) => const StatsScreen(),
      ),
      GoRoute(
        path: '/ai',
        name: 'ai',
        builder: (context, state) => const AiScreen(),
      ),

      // ── Profile & Settings ───────────────────────────────
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/security',
        name: 'security',
        builder: (context, state) => const SecurityScreen(),
      ),

      // ── Other Features ───────────────────────────────────
      GoRoute(
        path: '/scheduled-messages',
        name: 'scheduled-messages',
        builder: (context, state) => const ScheduledMessagesScreen(),
      ),
      GoRoute(
        path: '/daily-messages',
        name: 'daily-messages',
        builder: (context, state) => const DailyMessagesScreen(),
      ),
      GoRoute(
        path: '/surprise-box',
        name: 'surprise-box',
        builder: (context, state) => const SurpriseBoxScreen(),
      ),
      GoRoute(
        path: '/countdown',
        name: 'countdown',
        builder: (context, state) => const CountdownScreen(),
      ),
      GoRoute(
        path: '/map',
        name: 'map',
        builder: (context, state) => const MemoryMapScreen(),
      ),
      GoRoute(
        path: '/music',
        name: 'music',
        builder: (context, state) => const MusicScreen(),
      ),
      GoRoute(
        path: '/shared-book',
        name: 'shared-book',
        builder: (context, state) => const SharedBookScreen(),
      ),
      GoRoute(
        path: '/shared-book/page-new',
        name: 'shared-book-new',
        builder: (context, state) => const AddEditPageScreen(),
      ),
      GoRoute(
        path: '/shared-book/page-detail/:id',
        name: 'shared-book-detail',
        builder: (context, state) => PageDetailsScreen(pageId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/shared-book/page-edit/:id',
        name: 'shared-book-edit',
        builder: (context, state) => AddEditPageScreen(pageId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/secret-box',
        name: 'secret-box',
        builder: (context, state) => const SecretBoxScreen(),
      ),
      GoRoute(
        path: '/gift-library',
        name: 'gift-library',
        builder: (context, state) => const GiftLibraryScreen(),
      ),
      GoRoute(
        path: '/drawing',
        name: 'drawing',
        builder: (context, state) => const DrawingScreen(),
      ),
      GoRoute(
        path: '/stories',
        name: 'stories',
        builder: (context, state) => const StoriesScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF080810),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('404', style: TextStyle(fontSize: 48, color: Colors.white)),
            const SizedBox(height: 16),
            Text(
              'الصفحة غير موجودة',
              style: const TextStyle(color: Color(0xFFB0B0CC)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      ),
    ),
  );
});
