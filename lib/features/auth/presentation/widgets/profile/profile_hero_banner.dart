import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/auth/data/models/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileSliverAppBar extends StatelessWidget {
  const ProfileSliverAppBar({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: 104.h,
      pinned: true,
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: HeroBanner(user: user),
      ),
    );
  }
}

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final String? avatarUrl = Supabase.instance.client.auth.currentUser?.userMetadata?['avatar_url'] as String?
        ?? Supabase.instance.client.auth.currentUser?.userMetadata?['picture'] as String?
        ?? user.avatarUrl;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: OverflowBox(
        maxHeight: double.infinity,
        alignment: Alignment.topCenter,
        child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── AVATAR ──────────────────────────────────────
                  Container(
                    width: 64.r,
                    height: 64.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.textWhite.withValues(alpha: 0.2),
                      border: Border.all(
                        color: AppColors.textWhite.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: avatarUrl != null
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: avatarUrl,
                              width: 64.r,
                              height: 64.r,
                              fit: BoxFit.cover,
                              memCacheWidth: 200,
                              placeholder: (_, __) => Icon(
                                Icons.person,
                                color: AppColors.textWhite,
                                size: 36.r,
                              ),
                              errorWidget: (_, __, ___) => Icon(
                                Icons.person,
                                color: AppColors.textWhite,
                                size: 36.r,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.person,
                            color: AppColors.textWhite,
                            size: 36.r,
                          ),
                  ),
                  SizedBox(width: 16.w),

                  // ── NAME + EMAIL + BADGE ──────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName?.isNotEmpty == true
                              ? user.fullName!
                              : 'Your Name',
                          style: GoogleFontsSafeStyle.heroBold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          user.email,
                          style: GoogleFontsSafeStyle.heroSub,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}


abstract class GoogleFontsSafeStyle {
  static TextStyle get heroBold => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textWhite,
        height: 1.2,
      );

  static TextStyle get heroSub => TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textWhite.withValues(alpha: 0.75),
      );
}
