import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'pantry_quick_action_card.dart';

class PantryQuickActions extends StatelessWidget {
  const PantryQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: QuickActionCard(
            icon: Icons.camera_alt_outlined,
            label: 'SCAN FRIDGE',
            onTap: () => context.push(AppRoutes.scanning),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: QuickActionCard(
            icon: Icons.receipt_long_outlined,
            label: 'SCAN RECEIPT',
            onTap: () => context.push(AppRoutes.scanning),
          ),
        ),
      ],
    );
  }
}
