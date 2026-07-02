import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/features/auth/bloc/auth_bloc.dart';
import 'package:vitasense/features/auth/bloc/auth_event.dart';
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
            onTap: () => context.push(AppRoutes.changePassword),
          ),
          const Divider(color: AppColors.border),
          ActionRow(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            onTap: () => context.push(AppRoutes.privacyPolicy),
          ),
          const Divider(color: AppColors.border),
          ActionRow(
            icon: Icons.description_outlined,
            label: 'Terms of Service',
            onTap: () => context.push(AppRoutes.termsOfService),
          ),
          const Divider(color: AppColors.border),
          ActionRow(
            icon: Icons.logout_rounded,
            label: 'Sign Out',
            onTap: () {
              context.read<AuthBloc>().add(const SignOutRequested());
            },
          ),
          const Divider(color: AppColors.border),
          ActionRow(
            icon: Icons.delete_outline,
            label: 'Delete Account',
            onTap: () => context.push(AppRoutes.deleteAccount),
            isDestructive: true,
          ),
        ],
      ),
    );
  }
}
