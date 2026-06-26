import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/auth/bloc/auth_bloc.dart';
import 'package:vitasense/features/auth/bloc/auth_state.dart';
import 'package:vitasense/features/auth/data/models/user_model.dart';
import 'package:vitasense/features/subscription/bloc/subscription_bloc.dart';
import 'package:vitasense/features/subscription/bloc/subscription_event.dart';
import 'package:vitasense/core/widgets/gradient_scaffold.dart';
import 'package:vitasense/core/widgets/app_header.dart';
import '../widgets/profile/profile_daily_targets_card.dart';
import '../widgets/profile/profile_goals_card.dart';
import '../widgets/profile/profile_menu_card.dart';
import '../widgets/profile/profile_personal_info_card.dart';
import '../widgets/profile/profile_shimmer.dart';


// ─── ENTRY POINT ─────────────────────────────────────────────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SubscriptionBloc>(
      create: (context) => SubscriptionBloc()..add(const LoadSubscription()),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading || state is AuthInitial) {
            return const ProfileShimmer();
          }
          if (state is AuthAuthenticated) {
            return _ProfileView(user: state.user);
          }
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}

// ─── MAIN VIEW ────────────────────────────────────────────────────────────────

class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    debugPrint('goalPace: ${user.goalPace}, activityLevel: ${user.activityLevel}');
    
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Profile',
              variant: AppHeaderVariant.main,
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── DAILY TARGETS ────────────────────────────────
                          DailyTargetsCard(user: user),
                          SizedBox(height: 16.h),

                          // ── MY GOALS ─────────────────────────────────────
                          MyGoalsCard(user: user),
                          SizedBox(height: 16.h),

                          // ── PERSONAL INFO ────────────────────────────────
                          PersonalInfoCard(user: user),
                          SizedBox(height: 16.h),

                          // ── NAVIGATION MENU ───────────────────────────────
                          const MenuCard(),
                          SizedBox(height: 16.h),
                          const SettingsMenuCard(),
                          SizedBox(height: 120.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SLIVER APP BAR (HERO) ────────────────────────────────────────────────────





// ─── DAILY TARGETS CARD ───────────────────────────────────────────────────────







// ─── MY GOALS CARD ───────────────────────────────────────────────────────────











// ─── NAVIGATION MENU CARD ─────────────────────────────────────────────────────







// ─── SUBSCRIPTION CARD ────────────────────────────────────────────────────────




// ─── SHIMMER LOADING ──────────────────────────────────────────────────────────


// ─── SETTINGS MENU CARD ───────────────────────────────────────────────────────



// ─── SHARED CARD WRAPPER ──────────────────────────────────────────────────────



// ─── LOCAL TEXT STYLE HELPERS ─────────────────────────────────────────────────
// (używamy TextStyle bezpośrednio bo AppTextStyles nie ma wariantu białego)



// ─── PERSONAL INFO CARD ───────────────────────────────────────────────────────








