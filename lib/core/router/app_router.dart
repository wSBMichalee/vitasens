import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/supabase/supabase_client.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';

import 'package:vitasense/features/auth/presentation/screens/splash_screen.dart';
import 'package:vitasense/features/auth/presentation/screens/onboarding_screen.dart';

// ─── STAŁE NAZWY TRAS ─────────────────────────────────────────────────────────
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String valueExplanation = '/value-explanation';
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
  static const String familyInvite = '/family-invite';
}

// ─── INSTANCJA ROUTERA ────────────────────────────────────────────────────────
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,

  // ─── REDIRECT LOGIC ─────────────────────────────────────────────────────────
  redirect: (BuildContext context, GoRouterState state) {
    final isAuthenticated = SupabaseClientService.instance.isAuthenticated;
    final currentPath = state.matchedLocation;

    // Trasy dostępne bez logowania
    final publicRoutes = [
      AppRoutes.onboarding,
      AppRoutes.valueExplanation,
      AppRoutes.socialProof,
      AppRoutes.reinforcement,
      AppRoutes.paywall,
      AppRoutes.paywallDiscount,
      AppRoutes.successPurchase,
    ];

    final isPublicRoute = publicRoutes.any(
      (route) => currentPath.startsWith(route),
    );

    // Niezalogowany + trasa chroniona → onboarding
    if (!isAuthenticated && !isPublicRoute && currentPath != AppRoutes.splash) {
      return AppRoutes.onboarding;
    }

    // Zalogowany + splash → home
    if (isAuthenticated && currentPath == AppRoutes.splash) {
      return AppRoutes.home;
    }

    return null; // bez przekierowania
  },

  // ─── DEFINICJE TRAS ──────────────────────────────────────────────────────────
  routes: [
    // SPLASH
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (context, state) => _fadePage(
        state: state,
        child: const SplashScreen(),
      ),
    ),

    // ─── ONBOARDING FLOW ─────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.onboarding,
      pageBuilder: (context, state) => _slideHorizontalPage(
        state: state,
        child: const OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.valueExplanation,
      pageBuilder: (context, state) => _slideHorizontalPage(
        state: state,
        child: const _PlaceholderScreen(name: 'Why VitaSense?'),
      ),
    ),
    GoRoute(
      path: AppRoutes.socialProof,
      pageBuilder: (context, state) => _slideHorizontalPage(
        state: state,
        child: const _PlaceholderScreen(name: '50,000+ Social Proof'),
      ),
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
      pageBuilder: (context, state) => _slideUpPage(
        state: state,
        child: const _PlaceholderScreen(name: 'Paywall — Standard'),
      ),
    ),
    GoRoute(
      path: AppRoutes.paywallDiscount,
      pageBuilder: (context, state) => _slideUpPage(
        state: state,
        child: const _PlaceholderScreen(name: 'Paywall — 50% Discount'),
      ),
    ),
    GoRoute(
      path: AppRoutes.successPurchase,
      pageBuilder: (context, state) => _slideUpPage(
        state: state,
        child: const _PlaceholderScreen(name: 'Purchase Success 🎉'),
      ),
    ),

    // ─── MAIN APP (SHELL ROUTE z bottom navigation) ──────────────────────────
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithBottomNav(child: child);
      },
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) => _fadePage(
            state: state,
            child: const _PlaceholderScreen(name: 'Home 🏠'),
          ),
        ),
        GoRoute(
          path: AppRoutes.pantry,
          pageBuilder: (context, state) => _fadePage(
            state: state,
            child: const _PlaceholderScreen(name: 'Pantry 🥗'),
          ),
        ),
        GoRoute(
          path: AppRoutes.aiMeals,
          pageBuilder: (context, state) => _fadePage(
            state: state,
            child: const _PlaceholderScreen(name: 'AI Meals ✨'),
          ),
        ),
        GoRoute(
          path: AppRoutes.progress,
          pageBuilder: (context, state) => _fadePage(
            state: state,
            child: const _PlaceholderScreen(name: 'Progress 📊'),
          ),
        ),
        GoRoute(
          path: AppRoutes.profile,
          pageBuilder: (context, state) => _fadePage(
            state: state,
            child: const _PlaceholderScreen(name: 'Profile 👤'),
          ),
        ),
      ],
    ),

    // ─── FULLSCREEN ROUTES (poza shell) ──────────────────────────────────────
    GoRoute(
      path: AppRoutes.addIngredient,
      pageBuilder: (context, state) => _slideUpPage(
        state: state,
        child: const _PlaceholderScreen(name: 'Add Ingredient'),
      ),
    ),
    GoRoute(
      path: AppRoutes.scanning,
      pageBuilder: (context, state) => _slideUpPage(
        state: state,
        child: const _PlaceholderScreen(name: 'Scanning 📷'),
      ),
    ),
    GoRoute(
      path: AppRoutes.recipeDetails,
      pageBuilder: (context, state) => _fadePage(
        state: state,
        child: _PlaceholderScreen(
          name: 'Recipe Details — ${state.pathParameters['id']}',
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.progressHistory,
      pageBuilder: (context, state) => _fadePage(
        state: state,
        child: const _PlaceholderScreen(name: 'Progress History'),
      ),
    ),
    GoRoute(
      path: AppRoutes.settings,
      pageBuilder: (context, state) => _fadePage(
        state: state,
        child: const _PlaceholderScreen(name: 'Settings ⚙️'),
      ),
    ),
    GoRoute(
      path: AppRoutes.familyInvite,
      pageBuilder: (context, state) => _slideUpPage(
        state: state,
        child: const _PlaceholderScreen(name: 'Family Invite 👨‍👩‍👧'),
      ),
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
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
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
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

// ─── SCAFFOLD Z BOTTOM NAVIGATION ────────────────────────────────────────────
class ScaffoldWithBottomNav extends StatelessWidget {
  const ScaffoldWithBottomNav({super.key, required this.child});

  final Widget child;

  static const List<_NavItem> _tabs = [
    _NavItem(
      label: 'HOME',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      route: AppRoutes.home,
    ),
    _NavItem(
      label: 'PANTRY',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      route: AppRoutes.pantry,
    ),
    _NavItem(
      label: 'AI',
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome,
      route: AppRoutes.aiMeals,
    ),
    _NavItem(
      label: 'PROGRESS',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
      route: AppRoutes.progress,
    ),
    _NavItem(
      label: 'PROFILE',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
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
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.bottomNavBg,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.bottomNavBg,
          selectedItemColor: AppColors.bottomNavSelected,
          unselectedItemColor: AppColors.bottomNavUnselected,
          elevation: 0,
          selectedLabelStyle: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: AppTextStyles.caption,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: (index) => context.go(_tabs[index].route),
          items: _tabs.map((tab) {
            return BottomNavigationBarItem(
              icon: Icon(tab.icon),
              activeIcon: Icon(tab.activeIcon),
              label: tab.label,
            );
          }).toList(),
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
// Zostaną zastąpione prawdziwymi ekranami w Krokach 2-5
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
            const Icon(Icons.construction, size: 48, color: AppColors.textMuted),
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
