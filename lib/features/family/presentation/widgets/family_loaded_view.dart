part of '../screens/family_screen.dart';

class FamilyLoadedView extends StatelessWidget {
  final FamilyModel family;
  final String currentUserId;

  const FamilyLoadedView({
    super.key,
    required this.family,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    void copyCode() {
      Clipboard.setData(ClipboardData(text: family.inviteCode));
      SnackbarUtils.showSuccess(context, 'Invite code copied!');
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
          _FamilyHeader(
            family: family,
            currentUserId: currentUserId,
            onCopyCode: copyCode,
          ),
          SizedBox(height: 24.h),

          // ─── MEMBERS LIST ──────────────────────────────────────────────────
          _FamilyMembersList(
            family: family,
            currentUserId: currentUserId,
          ),
          SizedBox(height: 16.h),

          // ─── SHARED PANTRY CARD ──────────────────────────────────────────
          GestureDetector(
            onTap: () => context.go(AppRoutes.pantry),
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
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

class _FamilyHeader extends StatelessWidget {
  final FamilyModel family;
  final String currentUserId;
  final VoidCallback onCopyCode;

  const _FamilyHeader({
    required this.family,
    required this.currentUserId,
    required this.onCopyCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.textWhite),
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
                child: Icon(Icons.people, color: AppColors.textWhite, size: 20.r),
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
                        color: AppColors.textWhite,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onCopyCode,
                  child: Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.copy, color: AppColors.textWhite, size: 18.r),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilyMembersList extends StatelessWidget {
  final FamilyModel family;
  final String currentUserId;

  const _FamilyMembersList({
    required this.family,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MEMBERS',
          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        SizedBox(height: 12.h),
        ...family.members.map((member) => FamilyMemberCard(
              member: member,
              isCurrentUser: member.userId == currentUserId,
              isOwner: member.role == 'owner',
            )),
        SizedBox(height: 16.h),
      ],
    );
  }
}
