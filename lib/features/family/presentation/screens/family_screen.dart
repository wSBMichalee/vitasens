import 'package:vitasense/core/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/core/widgets/app_header.dart';
import 'package:vitasense/features/auth/bloc/auth_bloc.dart';
import 'package:vitasense/features/auth/bloc/auth_state.dart';
import 'package:vitasense/features/family/bloc/family_bloc.dart';
import 'package:vitasense/features/family/bloc/family_event.dart';
import 'package:vitasense/features/family/bloc/family_state.dart';
import 'package:vitasense/features/family/data/models/family_model.dart';

part '../widgets/family_no_group_view.dart';
part '../widgets/family_loaded_view.dart';
part '../widgets/family_member_card.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FamilyBloc()..add(const LoadFamily()),
      child: const _FamilyView(),
    );
  }
}

class _FamilyView extends StatelessWidget {
  const _FamilyView();

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Family Group'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Family name',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(dialogContext);
                context.read<FamilyBloc>().add(CreateFamily(name));
              }
            },
            child: const Text('Create', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showJoinDialog(BuildContext context) {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Join Family Group'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(
            hintText: 'Enter invite code',
          ),
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(letterSpacing: 2),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final code = codeController.text.trim().toUpperCase();
              if (code.isNotEmpty) {
                Navigator.pop(dialogContext);
                context.read<FamilyBloc>().add(JoinFamily(code));
              }
            },
            child: const Text('Join', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.select<AuthBloc, String?>((bloc) {
      if (bloc.state is AuthAuthenticated) {
        return (bloc.state as AuthAuthenticated).user.id;
      }
      return null;
    }) ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppHeader: wariant nested ─────────────────────────────────────
            AppHeader(
              title: 'Plan Rodzinny',
              variant: AppHeaderVariant.nested,
              onBack: () => context.pop(),
              actions: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundWhite,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.people, color: AppColors.textPrimary, size: 22.r),
                ),
              ],
            ),
            
            Expanded(
              child: BlocConsumer<FamilyBloc, FamilyState>(
                listener: (context, state) {
                  if (state is FamilyError) {
                    SnackbarUtils.showError(context, state.message);
                  } else if (state is FamilyLoaded) {
                    SnackbarUtils.showSuccess(context, 'Success!');
                  }
                },
                builder: (context, state) {
                  if (state is FamilyLoading || state is FamilyInitial) {
                    return _buildShimmerLoading();
                  }

                  if (state is FamilyNoGroup) {
                    return FamilyNoGroupView(
                      onCreateGroup: () => _showCreateDialog(context),
                      onJoinGroup: () => _showJoinDialog(context),
                    );
                  }

                  if (state is FamilyLoaded) {
                    return FamilyLoadedView(
                      family: state.family,
                      currentUserId: currentUserId,
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: AppColors.borderLight,
      highlightColor: AppColors.border,
      child: Column(
        children: [
          Container(height: 120.h, margin: EdgeInsets.all(20.w), color: AppColors.backgroundWhite),
          Container(height: 80.h, margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h), color: AppColors.backgroundWhite),
        ],
      ),
    );
  }
}
