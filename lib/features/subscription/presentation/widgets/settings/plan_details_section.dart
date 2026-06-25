import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/subscription/bloc/subscription_bloc.dart';
import 'package:vitasense/features/subscription/bloc/subscription_state.dart';
import 'base_card.dart';
import 'detail_row.dart';

class PlanDetailsSection extends StatelessWidget {
  const PlanDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      title: 'Plan Details',
      child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionLoaded) {
            final sub = state.subscription;
            return Column(
              children: [
                DetailRow(
                  label: 'Status',
                  value: sub.statusLabel,
                  valueColor: sub.isActive ? AppColors.primary : AppColors.error,
                ),
                const Divider(color: AppColors.border),
                DetailRow(
                  label: 'Plan',
                  value: sub.planName,
                ),
                const Divider(color: AppColors.border),
                DetailRow(
                  label: 'Price',
                  value: sub.priceLabel,
                ),
                const Divider(color: AppColors.border),
                DetailRow(
                  label: 'Next billing',
                  value: sub.expiresAtFormatted,
                ),
                const Divider(color: AppColors.border),
                DetailRow(
                  label: 'Trial',
                  value: sub.isTrialActive 
                    ? 'Active (${sub.trialDaysRemaining} days left)' 
                    : 'Not active',
                ),
              ],
            );
          }
          if (state is SubscriptionLoading || state is SubscriptionInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          return const SizedBox();
        },
      ),
    );
  }
}
