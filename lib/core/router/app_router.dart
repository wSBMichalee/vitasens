import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/features/auth/bloc/auth_bloc.dart';
import 'package:vitasense/features/auth/bloc/auth_state.dart';

import 'package:vitasense/features/auth/presentation/screens/splash_screen.dart';
import 'package:vitasense/features/auth/presentation/screens/landing_screen.dart';
import 'package:vitasense/features/auth/presentation/screens/login_screen.dart';
import 'package:vitasense/features/auth/presentation/screens/signup_screen.dart';
import 'package:vitasense/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:vitasense/features/auth/presentation/screens/user_onboarding_screen.dart';
import 'package:vitasense/features/subscription/presentation/screens/paywall_screen.dart';
import 'package:vitasense/features/subscription/presentation/screens/paywall_discount_screen.dart';
import 'package:vitasense/features/subscription/presentation/screens/social_proof_screen.dart';
import 'package:vitasense/features/subscription/presentation/screens/success_purchase_screen.dart';
import 'package:vitasense/features/macros/presentation/screens/home_screen.dart';
import 'package:vitasense/features/pantry/presentation/screens/pantry_screen.dart';
import 'package:vitasense/features/pantry/presentation/screens/add_ingredient_screen.dart';
import 'package:vitasense/features/detect/presentation/screens/scanning_screen.dart';
import 'package:vitasense/features/detect/presentation/screens/food_detected_screen.dart';
import 'package:vitasense/features/recipes/presentation/screens/ai_meals_screen.dart';
import 'package:vitasense/features/recipes/presentation/screens/recipe_detail_screen.dart';
import 'package:vitasense/features/auth/presentation/screens/profile_screen.dart';
import 'package:vitasense/features/subscription/presentation/screens/settings_screen.dart';
import 'package:vitasense/features/shopping/presentation/screens/shopping_list_screen.dart';
import 'package:vitasense/features/browse/presentation/screens/browse_screen.dart';
import 'package:vitasense/features/family/presentation/screens/family_screen.dart';
import 'package:vitasense/features/extract/presentation/screens/extract_screen.dart';
import 'package:vitasense/features/recipes/presentation/screens/create_recipe_screen.dart';
import 'package:vitasense/features/macros/presentation/screens/progress_history_screen.dart';
import 'package:vitasense/features/voice/presentation/screens/voice_log_screen.dart';
import 'package:vitasense/features/showcase/presentation/screens/problem_fatigue_screen.dart';
import 'package:vitasense/features/showcase/presentation/screens/feature_matcher_screen.dart';
import 'package:vitasense/features/showcase/presentation/screens/results_analysis_screen.dart';
import 'package:vitasense/features/recipes/presentation/screens/saved_recipes_screen.dart';

// ─── STAŁE NAZWY TRAS ─────────────────────────────────────────────────────────
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String landing = '/landing';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String userOnboarding = '/user-onboarding';
  static const String onboarding = '/onboarding';
  static const String valueExplanation = '/value-explanation';
  static const String problemFatigue = '/problem-fatigue';
  static const String featureMatcher = '/feature-matcher';
  static const String resultsAnalysis = '/results-analysis';
  static const String socialProof = '/social-proof';
  static const String reinforcement = '/reinforcement';
  static const String paywall = '/paywall';
  static const String paywallDiscount = '/paywall-discount';
  static const String successPurchase = '/success-purchase';
  static const String home = '/home';
  static const String pantry = '/pantry';
  static const String addIngredient = '/add-ingredient';
  static const String scanning = '/scanning';
  static const String aiMeals = '/ai-meals';
  static const String foodDetected = '/food-detected';
  static const String recipeDetails = '/recipe-details/:id';
  static const String progress = '/progress';
  static const String progressHistory = '/progress-history';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String family = '/family';
  static const String extract = '/extract';
  static const String myRecipes = '/my-recipes';
  static const String voiceLog = '/voice-log';
  static const String subscription = '/subscription';
  static const String changePassword = '/change-password';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfService = '/terms-of-service';
  static const String deleteAccount = '/delete-account';
  static const String savedRecipes = '/saved-recipes';
}

// ─── INSTANCJA ROUTERA ────────────────────────────────────────────────────────
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,

  // ─── REDIRECT LOGIC ─────────────────────────────────────────────────────────
  redirect: (BuildContext context, GoRouterState state) {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;
    final location = state.matchedLocation;

    final publicRoutes = [
      AppRoutes.splash,
      AppRoutes.landing,
      AppRoutes.login,
      AppRoutes.signup,
      AppRoutes.forgotPassword,
      AppRoutes.onboarding,
      AppRoutes.userOnboarding,
      AppRoutes.valueExplanation,
      AppRoutes.problemFatigue,
      AppRoutes.featureMatcher,
      AppRoutes.resultsAnalysis,
      AppRoutes.socialProof,
      AppRoutes.reinforcement,
      AppRoutes.paywall,
      AppRoutes.paywallDiscount,
      AppRoutes.successPurchase,
    ];

    final isPublic = publicRoutes.contains(location);

    if (authState is AuthInitial || authState is AuthLoading) {
      return location == AppRoutes.splash ? null : AppRoutes.splash;
    }

    if (authState is AuthUnauthenticated) {
      return isPublic ? null : AppRoutes.landing;
    }

    if (authState is AuthAuthenticated) {
      final user = authState.user;

      if (location == AppRoutes.splash ||
          location == AppRoutes.landing ||
          location == AppRoutes.login ||
          location == AppRoutes.signup) {
        if (!user.onboardingCompleted) {
          return AppRoutes.userOnboarding;
        }
        return AppRoutes.home;
      }
    }

    return null;
  },

  // ─── DEFINICJE TRAS ──────────────────────────────────────────────────────────
  routes: [
    // SPLASH
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (context, state) =>
          _fadePage(state: state, child: const SplashScreen()),
    ),

    // LANDING
    GoRoute(
      path: AppRoutes.landing,
      pageBuilder: (context, state) =>
          _fadePage(state: state, child: const LandingScreen()),
    ),

    // ─── AUTH FLOW ───────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.login,
      pageBuilder: (context, state) =>
          _slideHorizontalPage(state: state, child: const LoginScreen()),
    ),
    GoRoute(
      path: AppRoutes.signup,
      pageBuilder: (context, state) =>
          _slideHorizontalPage(state: state, child: const SignupScreen()),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      pageBuilder: (context, state) => _slideHorizontalPage(
        state: state,
        child: const ForgotPasswordScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.userOnboarding,
      pageBuilder: (context, state) => _slideHorizontalPage(
        state: state,
        child: const UserOnboardingScreen(),
      ),
    ),

    // ─── ONBOARDING FLOW ─────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.onboarding,
      pageBuilder: (context, state) =>
          _slideHorizontalPage(state: state, child: const UserOnboardingScreen()),
    ),
    GoRoute(
      path: AppRoutes.valueExplanation,
      pageBuilder: (context, state) => _slideHorizontalPage(
        state: state,
        child: const ProblemFatigueScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.problemFatigue,
      pageBuilder: (context, state) => _slideHorizontalPage(
        state: state,
        child: const ProblemFatigueScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.featureMatcher,
      pageBuilder: (context, state) => _slideHorizontalPage(
        state: state,
        child: const FeatureMatcherScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.resultsAnalysis,
      pageBuilder: (context, state) => _slideHorizontalPage(
        state: state,
        child: const ResultsAnalysisScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.socialProof,
      pageBuilder: (context, state) =>
          _slideHorizontalPage(state: state, child: const SocialProofScreen()),
    ),
    GoRoute(
      path: AppRoutes.reinforcement,
      pageBuilder: (context, state) => _slideHorizontalPage(
        state: state,
        child: const _PlaceholderScreen(name: "We've got this!"),
      ),
    ),

    // ─── PAYWALL FLOW ────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.paywall,
      pageBuilder: (context, state) =>
          _slideUpPage(state: state, child: const PaywallScreen()),
    ),
    GoRoute(
      path: AppRoutes.paywallDiscount,
      pageBuilder: (context, state) =>
          _slideUpPage(state: state, child: const PaywallDiscountScreen()),
    ),
    GoRoute(
      path: AppRoutes.successPurchase,
      pageBuilder: (context, state) =>
          _slideUpPage(state: state, child: const SuccessPurchaseScreen()),
    ),

    // ─── MAIN APP (STATEFUL SHELL ROUTE z bottom navigation) ──────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithBottomNav(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.pantry,
              builder: (context, state) => const PantryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.aiMeals,
              builder: (context, state) => AiMealsScreen(
                ingredients: state.extra is Map<String, dynamic>
                    ? (state.extra as Map<String, dynamic>)['ingredients']
                        as List<String>?
                    : state.extra is List<String>
                        ? state.extra as List<String>
                        : null,
              ),
            ),
            GoRoute(
              path: AppRoutes.foodDetected,
              builder: (context, state) => FoodDetectedScreen(
                result: state.extra as Map<String, dynamic>? ?? {},
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // ─── FULLSCREEN ROUTES (poza shell) ──────────────────────────────────────
    GoRoute(
      path: '/browse-recipes',
      pageBuilder: (context, state) =>
          _slideUpPage(state: state, child: const BrowseScreen()),
    ),
    GoRoute(
      path: '/shopping',
      pageBuilder: (context, state) =>
          _slideUpPage(state: state, child: const ShoppingListScreen()),
    ),
    GoRoute(
      path: AppRoutes.addIngredient,
      pageBuilder: (context, state) =>
          _slideUpPage(state: state, child: const AddIngredientScreen()),
    ),
    GoRoute(
      path: AppRoutes.scanning,
      pageBuilder: (context, state) =>
          _slideUpPage(state: state, child: const ScanningScreen()),
    ),
    GoRoute(
      path: AppRoutes.recipeDetails,
      builder: (context, state) {
        final recipe = state.extra as Map<String, dynamic>? ?? {};
        return RecipeDetailScreen(recipe: recipe);
      },
    ),
    GoRoute(
      path: AppRoutes.progressHistory,
      pageBuilder: (context, state) =>
          _fadePage(state: state, child: const ProgressHistoryScreen()),
    ),
    GoRoute(
      path: AppRoutes.settings,
      pageBuilder: (context, state) =>
          _fadePage(state: state, child: const SettingsScreen()),
    ),
    GoRoute(
      path: AppRoutes.family,
      pageBuilder: (context, state) =>
          _slideUpPage(state: state, child: const FamilyScreen()),
    ),
    GoRoute(
      path: AppRoutes.extract,
      pageBuilder: (context, state) =>
          _slideUpPage(state: state, child: const ExtractScreen()),
    ),
    GoRoute(
      path: AppRoutes.myRecipes,
      pageBuilder: (context, state) =>
          _slideUpPage(state: state, child: const CreateRecipeScreen()),
    ),
    GoRoute(
      path: AppRoutes.voiceLog,
      pageBuilder: (context, state) =>
          _slideUpPage(state: state, child: const VoiceLogScreen()),
    ),
    GoRoute(
      path: AppRoutes.savedRecipes,
      builder: (context, state) => const SavedRecipesScreen(),
    ),
  ],
);

// ─── PAGE TRANSITIONS ─────────────────────────────────────────────────────────

/// FadeTransition (300ms) — domyślne przejście między ekranami
CustomTransitionPage<void> _fadePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

/// SlideTransition od dołu — modals (paywall, skanowanie, formularze)
CustomTransitionPage<void> _slideUpPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

/// SlideTransition poziomy — onboarding flow (lewa → prawa)
CustomTransitionPage<void> _slideHorizontalPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

// ─── SCAFFOLD Z BOTTOM NAVIGATION ────────────────────────────────────────────
class ScaffoldWithBottomNav extends StatefulWidget {
  const ScaffoldWithBottomNav({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  State<ScaffoldWithBottomNav> createState() => _ScaffoldWithBottomNavState();
}

class _ScaffoldWithBottomNavState extends State<ScaffoldWithBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const List<_NavItem> _tabs = [
    _NavItem(label: 'Home',     icon: Icons.home_outlined,         activeIcon: Icons.home_rounded,            route: AppRoutes.home),
    _NavItem(label: 'Pantry',   icon: Icons.shopping_bag_outlined, activeIcon: Icons.shopping_bag_rounded,    route: AppRoutes.pantry),
    _NavItem(label: 'AI Meals', icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome,            route: AppRoutes.aiMeals),
    _NavItem(label: 'Profile',  icon: Icons.person_outline,        activeIcon: Icons.person_rounded,          route: AppRoutes.profile),
  ];

  int _currentIndex(BuildContext context) {
    return widget.navigationShell.currentIndex;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap(int index, BuildContext context) {
    _controller.forward().then((_) => _controller.reverse());
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: widget.navigationShell,
      floatingActionButton: currentIndex == 0
          ? SpeedDial(
              icon: Icons.add,
              activeIcon: Icons.add, // keeps the add icon and just rotates it
              iconTheme: const IconThemeData(color: Colors.white, size: 28),
              backgroundColor: AppColors.primary,
              shape: const CircleBorder(),
              elevation: 4,
              animationDuration: const Duration(milliseconds: 200),
              animationAngle: 3.14159 / 4, // 45 degrees
              overlayColor: Colors.black,
              overlayOpacity: 0.15,
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.menu_book, color: Colors.white),
                  backgroundColor: AppColors.primary,
                  label: 'Scan Recipe',
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  labelBackgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  onTap: () => context.go(AppRoutes.extract),
                ),
                SpeedDialChild(
                  child: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  backgroundColor: AppColors.primary,
                  label: 'Scan Food',
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  labelBackgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  onTap: () => context.go(AppRoutes.scanning),
                ),
                SpeedDialChild(
                  child: const Icon(Icons.restaurant_menu, color: Colors.white),
                  backgroundColor: AppColors.primary,
                  label: 'Log Meal',
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  labelBackgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  onTap: () => context.go(AppRoutes.aiMeals),
                ),
              ],
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NativeGlassNavBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTap(index, context),
        tabs: const [
          NativeGlassNavBarItem(label: 'Home',     symbol: 'house.fill'),
          NativeGlassNavBarItem(label: 'Pantry',   symbol: 'cart.fill'),
          NativeGlassNavBarItem(label: 'AI Meals', symbol: 'sparkles'),
          NativeGlassNavBarItem(label: 'Profile',  symbol: 'person.fill'),
        ],
        fallback: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                height: 60.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF111111).withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(32.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: List.generate(_tabs.length, (i) {
                    final isActive = currentIndex == i;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onTap(i, context),
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          height: 60.h,
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.white.withValues(alpha: 0.18)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Icon(
                                isActive
                                    ? _tabs[i].activeIcon
                                    : _tabs[i].icon,
                                size: 24.r,
                                color: isActive
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
}

// ─── PLACEHOLDER SCREENS ──────────────────────────────────────────────────────
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(name, style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            Text('— coming soon —', style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}
