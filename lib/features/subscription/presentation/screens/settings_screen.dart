import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/widgets/app_header.dart';
import 'package:vitasense/features/subscription/bloc/subscription_bloc.dart';
import 'package:vitasense/features/subscription/bloc/subscription_event.dart';
import 'package:vitasense/features/subscription/bloc/subscription_state.dart';
import '../widgets/settings/subscription_card_section.dart';
import '../widgets/settings/plan_details_section.dart';
import '../widgets/settings/account_settings_section.dart';
import '../widgets/settings/danger_zone_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubscriptionBloc()..add(const LoadSubscription()),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        if (state is SubscriptionCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription cancelled. Access until end of period.'),
              backgroundColor: AppColors.primary, // Zielony jak prosił user
            ),
          );
          // Odśwież status
          context.read<SubscriptionBloc>().add(const LoadSubscription());
        } else if (state is SubscriptionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── AppHeader: wariant nested (push navigation, back po lewej) ────
              AppHeader(
                title: 'Settings',
                variant: AppHeaderVariant.nested,
                onBack: () => context.pop(),
              ),

              // ── Scrollable body ─────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SubscriptionCardSection(),
                      SizedBox(height: 24.h),
                      const PlanDetailsSection(),
                      SizedBox(height: 24.h),
                      const AccountSettingsSection(),
                      SizedBox(height: 24.h),
                      const DangerZoneSection(),
                      SizedBox(height: 48.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


