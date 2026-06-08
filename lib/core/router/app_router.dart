import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/features/auth/bloc/auth_bloc.dart';
import 'package:vitasense/features/auth/bloc/auth_state.dart';

import 'package:vitasense/features/auth/presentation/screens/splash_screen.dart';
import 'package:vitasense/features/auth/presentation/screens/landing_screen.dart';
import 'package:vitasense/features/auth/presentation/screens/onboarding_screen.dart';
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
import 'package:vitasense/features/recipes/presentation/screens/ai_meals_screen.dart';
import 'package:vitasense/features/recipes/presentation/screens/recipe_detail_screen.dart';
import 'package:vitasense/features/macros/presentation/screens/progress_screen.dart';
import 'package:vitasense/features/auth/presentation/screens/profile_screen.dart';
import 'package:vitasense/features/subscription/presentation/screens/settings_screen.dart';
import 'package:vitasense/features/shopping/presentation/screens/shopping_list_screen.dart';
import 'package:vitasense/features/browse/presentation/screens/browse_screen.dart';
import 'package:vitasense/features/family/presentation/screens/family_screen.dart';
import 'package:vitasense/features/extract/presentation/screens/extract_screen.dart';
import 'package:vitasense/features/recipes/presentation/screens/create_recipe_screen.dart';
import 'package:vitasense/features/macros/presentation/screens/progress_history_screen.dart';
import 'package:vitasense/features/voice/presentation/screens/voice_log_screen.dart';
import 'package:vitasense/features/showcase/presentation/screens/vitasense_mockup_screens.dart';
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
          _slideHorizontalPage(state: state, child: const OnboardingScreen()),
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

    // ─── MAIN APP (SHELL ROUTE z bottom navigation) ──────────────────────────
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithBottomNav(child: child);
      },
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) =>
              _fadePage(state: state, child: const HomeScreen()),
        ),
        GoRoute(
          path: AppRoutes.pantry,
          pageBuilder: (context, state) =>
              _fadePage(state: state, child: const PantryScreen()),
        ),
        GoRoute(
          path: AppRoutes.aiMeals,
          pageBuilder: (context, state) => _fadePage(
            state: state,
            child: AiMealsScreen(
              ingredients: state.extra is Map<String, dynamic>
                  ? (state.extra as Map<String, dynamic>)['ingredients']
                        as List<String>?
                  : state.extra is List<String>
                  ? state.extra as List<String>
                  : null,
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.progress,
          pageBuilder: (context, state) =>
              _fadePage(state: state, child: const ProgressScreen()),
        ),
        GoRoute(
          path: AppRoutes.profile,
          pageBuilder: (context, state) =>
              _fadePage(state: state, child: const ProfileScreen()),
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
      pageBuilder: (context, state) {
        final recipe = state.extra as Map<String, dynamic>? ?? {};
        return _fadePage(
          state: state,
          child: RecipeDetailScreen(recipe: recipe),
        );
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
class ScaffoldWithBottomNav extends StatelessWidget {
  const ScaffoldWithBottomNav({super.key, required this.child});

  final Widget child;

  static const List<_NavItem> _tabs = [
    _NavItem(
      label: 'Home',
      icon: CupertinoIcons.house,
      activeIcon: CupertinoIcons.house_fill,
      route: AppRoutes.home,
    ),
    _NavItem(
      label: 'Pantry',
      icon: CupertinoIcons.bag,
      activeIcon: CupertinoIcons.bag_fill,
      route: AppRoutes.pantry,
    ),
    _NavItem(
      label: 'AI Meals',
      icon: CupertinoIcons.sparkles,
      activeIcon: CupertinoIcons.sparkles,
      route: AppRoutes.aiMeals,
    ),
    _NavItem(
      label: 'Progress',
      icon: CupertinoIcons.chart_bar,
      activeIcon: CupertinoIcons.chart_bar_fill,
      route: AppRoutes.progress,
    ),
    _NavItem(
      label: 'Profile',
      icon: CupertinoIcons.person_circle,
      activeIcon: CupertinoIcons.person_circle_fill,
      route: AppRoutes.profile,
    ),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      extendBody: true,
      body: child,
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
              heroTag: 'add_meal_fab',
              onPressed: () => context.go(AppRoutes.aiMeals),
              backgroundColor: AppColors.primary,
              shape: const CircleBorder(),
              elevation: 4,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              border: Border(
                top: BorderSide(
                  color: Colors.black.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textMuted,
              elevation: 0,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              onTap: (index) => context.go(_tabs[index].route),
              items: _tabs.map((tab) {
                return BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Icon(tab.icon, size: 24),
                  ),
                  activeIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Icon(tab.activeIcon, size: 24),
                  ),
                  label: tab.label,
                );
              }).toList(),
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
