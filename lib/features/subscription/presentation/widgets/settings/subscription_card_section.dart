import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/subscription/bloc/subscription_bloc.dart';
import 'package:vitasense/features/subscription/bloc/subscription_event.dart';
import 'package:vitasense/features/subscription/bloc/subscription_state.dart';

class SubscriptionCardSection extends StatelessWidget {
  const SubscriptionCardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionLoading || state is SubscriptionInitial) {
          return Shimmer.fromColors(
            baseColor: AppColors.borderLight,
            highlightColor: AppColors.border,
            child: Container(
              height: 120.h,
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          );
        }

        if (state is SubscriptionLoaded) {
          final sub = state.subscription;
          final isActive = sub.isActive;
          
          return Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isActive 
                  ? [AppColors.primary, AppColors.primaryDark]
                  : [AppColors.textMuted, AppColors.textSecondary],
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
                        isActive ? 'VitaSense Pro ✓' : 'Subscription Expired',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textWhite,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        isActive ? sub.planName : 'Renew to continue using VitaSense',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textWhite.withValues(alpha: 0.9),
                        ),
                      ),
                      if (isActive) ...[
                        SizedBox(height: 4.h),
                        Text(
                          sub.isTrialActive 
                            ? 'Trial ends in ${sub.trialDaysRemaining} days'
                            : 'Expires in ${sub.daysRemaining} days',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textWhite.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isActive)
                  SizedBox(
                    height: 44.h,
                    child: OutlinedButton(
                      onPressed: () => context.read<SubscriptionBloc>().add(const SyncSubscription()),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.textWhite),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      ),
                      child: Text(
                        'Sync',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 44.h,
                    child: FilledButton(
                      onPressed: () => context.push(AppRoutes.paywall),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.textWhite,
                        foregroundColor: AppColors.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                      child: Text(
                        'Renew Now',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}
