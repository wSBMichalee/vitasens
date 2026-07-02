part of '../screens/family_screen.dart';

class FamilyMemberCard extends StatelessWidget {
  final FamilyMemberModel member;
  final bool isCurrentUser;
  final bool isOwner;

  const FamilyMemberCard({
    super.key,
    required this.member,
    required this.isCurrentUser,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    final initials = member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
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
