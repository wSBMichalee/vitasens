import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';

class SocialProofScreen extends StatelessWidget {
  const SocialProofScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Back button ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundWhite,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.textPrimary,
                      size: 16.r,
                    ),
                  ),
                ),
              ),
            ),

            // ─── Scrollable content ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 32.h),

                    // ─── Overlapping avatars ──────────────────────────────
                    const _AvatarStack()
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .scale(
                            begin: const Offset(0.9, 0.9),
                            duration: 400.ms,
                            curve: Curves.easeOut),

                    SizedBox(height: 24.h),

                    // ─── Big number ───────────────────────────────────────
                    Text(
                      '50,000+',
                      style: TextStyle(
                        fontSize: 52.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondary,
                        fontFamily: AppTextStyles.numberMedium.fontFamily,
                      ),
                    )
                        .animate(delay: 100.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0),

                    SizedBox(height: 8.h),

                    // ─── Heading ─────────────────────────────────────────
                    Text(
                      'Join thousands of people\neating smarter',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: AppTextStyles.headingXL.fontFamily,
                        height: 1.3,
                      ),
                    )
                        .animate(delay: 150.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.08, end: 0),

                    SizedBox(height: 12.h),

                    // ─── Subtitle ────────────────────────────────────────
                    Text(
                      'People are already using VitaSense to cook better meals from what they have',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ).animate(delay: 180.ms).fadeIn(duration: 400.ms),

                    SizedBox(height: 28.h),

                    // ─── Review card ──────────────────────────────────────
                    const _ReviewCard()
                        .animate(delay: 240.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.06, end: 0),

                    SizedBox(height: 32.h),

                    // ─── Limited time pill ────────────────────────────────
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8.r,
                            height: 8.r,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'LIMITED-TIME ACCESS TO FULL PLAN',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 300.ms).fadeIn(),

                    SizedBox(height: 16.h),

                    // ─── CTA button ───────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: FilledButton(
                        onPressed: () => context.go(AppRoutes.paywall),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.backgroundDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          'Unlock My Plan',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: AppTextStyles.labelLarge.fontFamily,
                          ),
                        ),
                      ),
                    ).animate(delay: 340.ms).fadeIn().slideY(begin: 0.1, end: 0),

                    SizedBox(height: 36.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Overlapping avatar stack ─────────────────────────────────────────────────
class _AvatarStack extends StatelessWidget {
  const _AvatarStack();

  static const List<String> _avatarUrls = [
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    const double size = 52;
    const double overlap = 20;
    const totalWidth = size * 4 - overlap * 2 + 16;

    return SizedBox(
      width: totalWidth.w,
      height: (size + 4).r,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatar 1
          Positioned(
            left: 0,
            child: _AvatarCircle(imageUrl: _avatarUrls[0]),
          ),
          // Avatar 2
          Positioned(
            left: (size - overlap).w,
            child: _AvatarCircle(imageUrl: _avatarUrls[1]),
          ),
          // Avatar 3
          Positioned(
            left: ((size - overlap) * 2).w,
            child: _AvatarCircle(imageUrl: _avatarUrls[2]),
          ),
          // +12k circle
          Positioned(
            left: ((size - overlap) * 3).w,
            child: Container(
              width: size.r,
              height: size.r,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.backgroundWhite, width: 2),
              ),
              child: Center(
                child: Text(
                  '+12k',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52.r,
      height: 52.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.backgroundWhite, width: 2),
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => Shimmer.fromColors(
            baseColor: AppColors.border,
            highlightColor: AppColors.borderLight,
            child: Container(color: AppColors.border),
          ),
          errorWidget: (_, __, ___) => Container(
            color: AppColors.borderLight,
            child: Icon(Icons.person, color: AppColors.textMuted, size: 24.r),
          ),
        ),
      ),
    );
  }
}

// ─── Review card ──────────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  const _ReviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stars
          Row(
            children: List.generate(
              5,
              (_) => Icon(Icons.star, color: AppColors.warning, size: 20.r),
            ),
          ),
          SizedBox(height: 12.h),
          // Quote
          Text(
            '"I stopped wasting groceries and started feeling so much more energetic. VitaSense literally told me what to do with my leftover kale and salmon."',
            style: TextStyle(
              fontSize: 14.sp,
              fontStyle: FontStyle.italic,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          SizedBox(height: 14.h),
          // Author
          Text(
            '— SARAH M., LONDON',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
