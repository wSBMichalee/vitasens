import 'package:flutter/material.dart';
import 'profile_shimmer.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/features/auth/data/models/user_model.dart';

class MenuCard extends StatelessWidget {
  const MenuCard({super.key});

  final List<MenuItem> _items = const [
    MenuItem(
      icon: Icons.shopping_cart_outlined,
      iconBg: AppColors.primaryLight,
      iconColor: AppColors.primaryDark,
      label: 'Shopping List',
      route: '/shopping',
    ),
    MenuItem(
      icon: Icons.family_restroom_outlined,
      iconBg: AppColors.secondaryLight,
      iconColor: AppColors.secondary,
      label: 'Family Plan',
      route: null,
      badgeText: 'Coming Soon',
    ),
    MenuItem(
      icon: Icons.menu_book_outlined,
      iconBg: AppColors.warningLight,
      iconColor: AppColors.warning,
      label: 'My Recipes',
      route: AppRoutes.myRecipes,
    ),
    MenuItem(
      icon: Icons.explore_outlined,
      iconBg: AppColors.primaryLight,
      iconColor: AppColors.primaryDark,
      label: 'Browse Recipes',
      route: '/browse-recipes',
    ),

  ];

  @override
  Widget build(BuildContext context) {
    return ProfileShimmerCard(
      child: Column(
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == _items.length - 1;
          return Column(
            children: [
              MenuRow(item: item),
              if (!isLast) const Divider(color: AppColors.border, height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class MenuItem {
  const MenuItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.route,
    this.badgeText,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String? route;
  final String? badgeText;
}

class MenuRow extends StatelessWidget {
  const MenuRow({super.key, required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    final isEnabled = item.route != null;
    return InkWell(
      onTap: isEnabled ? () => context.push(item.route!) : null,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: item.iconBg,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(item.icon, color: item.iconColor, size: 18.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Row(
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: isEnabled
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (item.badgeText != null) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        item.badgeText!,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isEnabled
                  ? AppColors.textSecondary
                  : AppColors.textMuted,
              size: 18.r,
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final isActive = user.subscriptionStatus?.toLowerCase() == 'active';
    final statusLabel = isActive ? 'Active subscription' : 'Upgrade to Pro';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VitaSense Pro',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textWhite,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textWhite.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push(AppRoutes.settings),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.textWhite,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Manage',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

