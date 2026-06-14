
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
export 'app_routes.dart';
import 'app_routes.dart';
import '../widgets/scaffold_with_bottom_nav.dart';
import '../widgets/placeholder_screen.dart';

// ─── STAŁE NAZWY TRAS ─────────────────────────────────────────────────────────


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
        // Wymuszenie Home Page'a do testów widoku!
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
        child: const PlaceholderScreen(name: "We've got this!"),
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






// ─── PLACEHOLDER SCREENS ──────────────────────────────────────────────────────

