import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/auth/data/auth_repository.dart';
import 'base_card.dart';
import 'action_row.dart';

class AccountSettingsSection extends StatelessWidget {
  const AccountSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      title: 'Account Settings',
      child: Column(
        children: [
          ActionRow(
            icon: Icons.lock_outline,
            label: 'Change Password',
            onTap: () => _showComingSoon(context),
          ),
          const Divider(color: AppColors.border),
          ActionRow(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            onTap: () => _showComingSoon(context),
          ),
          const Divider(color: AppColors.border),
          ActionRow(
            icon: Icons.description_outlined,
            label: 'Terms of Service',
            onTap: () => _showComingSoon(context),
          ),
          const Divider(color: AppColors.border),
          ActionRow(
            icon: Icons.logout_rounded,
            label: 'Sign Out',
            onTap: () async {
              await AuthRepository().signOut();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),
          const Divider(color: AppColors.border),
          ActionRow(
            icon: Icons.delete_outline,
            label: 'Delete Account',
            onTap: () => _showComingSoon(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }
}
