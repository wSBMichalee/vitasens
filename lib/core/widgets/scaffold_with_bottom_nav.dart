import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import '../router/app_routes.dart';

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
    _NavItem(label: 'Home',     icon: Icons.home_outlined,              activeIcon: Icons.home_rounded,            route: AppRoutes.home),
    _NavItem(label: 'Pantry',   icon: Icons.shopping_bag_outlined,      activeIcon: Icons.shopping_bag_rounded,    route: AppRoutes.pantry),
    _NavItem(label: 'AI Meals', icon: Icons.auto_awesome_outlined,      activeIcon: Icons.auto_awesome,            route: AppRoutes.aiMeals),
    _NavItem(label: 'Shop',     icon: Icons.shopping_basket_outlined,   activeIcon: Icons.shopping_basket_rounded, route: '/shopping'),
    _NavItem(label: 'Profile',  icon: Icons.person_outline,             activeIcon: Icons.person_rounded,          route: AppRoutes.profile),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: widget.navigationShell,
      bottomNavigationBar: NativeGlassNavBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTap(index, context),
        tabs: const [
          NativeGlassNavBarItem(label: 'Home',     symbol: 'house.fill'),
          NativeGlassNavBarItem(label: 'Pantry',   symbol: 'cart.fill'),
          NativeGlassNavBarItem(label: 'AI Meals', symbol: 'sparkles'),
          NativeGlassNavBarItem(label: 'Shop',     symbol: 'basket.fill'),
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