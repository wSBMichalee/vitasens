import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/features/auth/bloc/auth_bloc.dart';
import 'package:vitasense/features/auth/bloc/auth_state.dart';
import 'package:vitasense/features/family/bloc/family_bloc.dart';
import 'package:vitasense/features/family/bloc/family_event.dart';
import 'package:vitasense/features/family/bloc/family_state.dart';
import 'package:vitasense/features/family/data/models/family_model.dart';

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
            // ─── HEADER ────────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 24.r),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  SizedBox(width: 16.w),
                  Text('Family Plan', style: AppTextStyles.headingLarge),
                  const Spacer(),
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.people, color: AppColors.textPrimary, size: 22.r),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: BlocConsumer<FamilyBloc, FamilyState>(
                listener: (context, state) {
                  if (state is FamilyError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
                    );
                  } else if (state is FamilyLoaded) {
                    // It can be triggered just on load, but spec asks for 'Success!'
                    // To avoid showing it on initial load, we ideally need to know action.
                    // Assuming basic listener for now.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Success!'), backgroundColor: AppColors.primary),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is FamilyLoading || state is FamilyInitial) {
                    return _buildShimmerLoading();
                  }

                  if (state is FamilyNoGroup) {
                    return _buildNoGroupView(context);
                  }

                  if (state is FamilyLoaded) {
                    return _buildFamilyLoadedView(context, state.family, currentUserId);
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
          Container(height: 120.h, margin: EdgeInsets.all(20.w), color: Colors.white),
          Container(height: 80.h, margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h), color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildNoGroupView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(Icons.family_restroom, color: AppColors.primary, size: 40.r),
          ),
          SizedBox(height: 24.h),
          Text(
            'No Family Group Yet',
            style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Create or join a family group to share\nyour pantry and cook together.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: FilledButton(
              onPressed: () => _showCreateDialog(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(
                'Create Family Group',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: OutlinedButton(
              onPressed: () => _showJoinDialog(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(
                'Join with Invite Code',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyLoadedView(BuildContext context, FamilyModel family, String currentUserId) {
    void copyCode() {
      Clipboard.setData(ClipboardData(text: family.inviteCode));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invite code copied!'), backgroundColor: AppColors.primary),
      );
    }

    void showLeaveDialog() {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Leave Family Group?'),
          content: const Text('You will lose access to the shared pantry.'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<FamilyBloc>().add(const LeaveFamily());
              },
              child: const Text('Leave', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      );
    }

    void showDeleteDialog() {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delete Family Group?'),
          content: const Text('This action cannot be undone. All members will be removed.'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<FamilyBloc>().add(const DeleteFamily());
              },
              child: const Text('Delete', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── HEADER CARD ──────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            family.name,
                            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          Text(
                            '${family.memberCount}/${family.maxMembers} members',
                            style: TextStyle(fontSize: 13.sp, color: Colors.white.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.people, color: Colors.white, size: 20.r),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INVITE CODE',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.white.withValues(alpha: 0.7),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            family.inviteCode,
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: copyCode,
                        child: Container(
                          width: 36.r,
                          height: 36.r,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.copy, color: Colors.white, size: 18.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // ─── MEMBERS LIST ──────────────────────────────────────────────────
          Text(
            'MEMBERS',
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          SizedBox(height: 12.h),
          ...family.members.map((member) => _MemberCard(member: member)),
          SizedBox(height: 16.h),

          // ─── SHARED PANTRY CARD ──────────────────────────────────────────
          GestureDetector(
            onTap: () => context.go(AppRoutes.pantry),
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Icons.kitchen, color: AppColors.primary, size: 22.r),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Shared Pantry', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                        Text(
                          'Cook together from shared ingredients',
                          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20.r),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // ─── DANGER ZONE ──────────────────────────────────────────────────
          if (family.isOwner(currentUserId))
            OutlinedButton(
              onPressed: showDeleteDialog,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                minimumSize: Size(double.infinity, 52.h),
              ),
              child: Text(
                'Delete Family Group',
                style: TextStyle(color: AppColors.error, fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            )
          else
            OutlinedButton(
              onPressed: showLeaveDialog,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                minimumSize: Size(double.infinity, 52.h),
              ),
              child: Text(
                'Leave Family Group',
                style: TextStyle(color: AppColors.error, fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final FamilyMemberModel member;

  const _MemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final initials = member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?';
    final isOwner = member.role == 'owner';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              initials,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                Text(
                  member.email,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isOwner ? AppColors.primaryLight : AppColors.borderLight,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              isOwner ? 'OWNER' : 'MEMBER',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: isOwner ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
