import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/features/extract/bloc/extract_bloc.dart';
import 'package:vitasense/features/extract/bloc/extract_event.dart';
import 'package:vitasense/features/extract/bloc/extract_state.dart';
import 'package:vitasense/features/extract/data/models/extracted_recipe_model.dart';

class ExtractScreen extends StatelessWidget {
  const ExtractScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExtractBloc(),
      child: const _ExtractView(),
    );
  }
}

class _ExtractView extends StatefulWidget {
  const _ExtractView();

  @override
  State<_ExtractView> createState() => _ExtractViewState();
}

class _ExtractViewState extends State<_ExtractView> {
  final TextEditingController _urlController = TextEditingController();

  void _extractUrl() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      FocusScope.of(context).unfocus();
      context.read<ExtractBloc>().add(ExtractUrl(url));
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  Text('Extract Recipe', style: AppTextStyles.headingLarge),
                ],
              ),
            ),

            Expanded(
              child: BlocConsumer<ExtractBloc, ExtractState>(
                listener: (context, state) {
                  if (state is ExtractError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
                    );
                  }
                  if (state is ExtractSaveSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Recipe saved!'), backgroundColor: AppColors.primary),
                    );
                    context.read<ExtractBloc>().add(const ResetExtract());
                    _urlController.clear();
                  }
                },
                builder: (context, state) {
                  if (state is ExtractInitial) return _buildInitialState().animate().fadeIn();
                  if (state is ExtractLoading) return const _LoadingView().animate().fadeIn();
                  if (state is ExtractSuccess) return _buildSuccessState(state.recipe).animate().slideY(begin: 0.1, duration: 300.ms).fadeIn();
                  
                  return _buildInitialState();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 40.h),
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(Icons.link, color: AppColors.primary, size: 40.r),
          ),
          SizedBox(height: 24.h),
          Text(
            'Import from Social Media',
            style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Paste a link from your favorite platform and let AI extract the recipe details.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPlatformBadge('TikTok', Icons.music_note),
              SizedBox(width: 8.w),
              _buildPlatformBadge('YouTube', Icons.play_arrow),
              SizedBox(width: 8.w),
              _buildPlatformBadge('Instagram', Icons.camera_alt),
            ],
          ),
          SizedBox(height: 40.h),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: 'https://...',
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: FilledButton(
              onPressed: _extractUrl,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(
                'Extract Recipe',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformBadge(String name, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14.r, color: AppColors.textSecondary),
          SizedBox(width: 4.w),
          Text(
            name,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(ExtractedRecipeModel recipe) {
    final title = recipe.title;
    final imageUrl = recipe.imageUrl ?? 'https://picsum.photos/400/300';
    final cookTime = recipe.cookTime ?? '15m';
    final servings = recipe.servings ?? '2';
    // Random mock match for UI presentation
    const int matchScore = 85; 
    const bool isGoodMatch = matchScore >= 80;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h).copyWith(bottom: 120.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── RECIPE CARD ──────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        height: 160.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: AppColors.borderLight),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.borderLight,
                          child: const Icon(Icons.image_not_supported, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.borderLight,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              'IMPORTED FROM URL',
                              style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            title,
                            style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Icon(Icons.timer_outlined, color: AppColors.textMuted, size: 16.r),
                              SizedBox(width: 4.w),
                              Text(cookTime, style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary)),
                              SizedBox(width: 16.w),
                              Icon(Icons.restaurant_outlined, color: AppColors.textMuted, size: 16.r),
                              SizedBox(width: 4.w),
                              Text('$servings servings', style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // ─── PANTRY MATCH CARD ────────────────────────────────────────────
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: isGoodMatch ? AppColors.successLight : AppColors.mismatchLight,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: isGoodMatch ? AppColors.successBorder : AppColors.mismatchBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.kitchen,
                      color: isGoodMatch ? AppColors.successDark : AppColors.mismatchText,
                      size: 24.r,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$matchScore% Pantry Match',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: isGoodMatch ? AppColors.successDeepDark : AppColors.mismatchText,
                            ),
                          ),
                          Text(
                            isGoodMatch ? 'You have almost everything!' : 'You need to buy a few things.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isGoodMatch ? AppColors.successDark : AppColors.mismatchTextDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // ─── INGREDIENTS ──────────────────────────────────────────────────
              Text('Ingredients', style: AppTextStyles.headingMedium),
              SizedBox(height: 12.h),
              if (recipe.ingredients.isEmpty)
                Text('No ingredients found.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp))
              else
                ...recipe.ingredients.map((ingredient) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.primary, size: 16.r),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              ingredient,
                              style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    )),
              SizedBox(height: 16.h),
              
              // ─── MISSING INGREDIENTS RED CARD ───────────────────────────────
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_shopping_cart, color: AppColors.error, size: 20.r),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Missing 2 items. Will add to shopping list.',
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // ─── INSTRUCTIONS ─────────────────────────────────────────────────
              Text('Instructions', style: AppTextStyles.headingMedium),
              SizedBox(height: 12.h),
              if (recipe.instructions.isEmpty)
                Text('No instructions found.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp))
              else ...[
                ...recipe.instructions.take(3).toList().asMap().entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key + 1}.',
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (recipe.instructions.length > 3)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '+ ${recipe.instructions.length - 3} more steps',
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ),
              ],
            ],
          ),
        ),

        // ─── STICKY BOTTOM BUTTONS ──────────────────────────────────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: FilledButton(
                    onPressed: () => context.read<ExtractBloc>().add(SaveExtractedRecipe(recipe)),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(
                      'Save Recipe',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: OutlinedButton(
                    onPressed: () => context.read<ExtractBloc>().add(const ResetExtract()),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(
                      'Try Another URL',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingView extends StatefulWidget {
  const _LoadingView();

  @override
  State<_LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<_LoadingView> {
  int _currentStep = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Simulate steps changing
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (mounted && _currentStep < 3) {
        setState(() {
          _currentStep++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 24.h),
          Text(
            'Analyzing URL...',
            style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 40.h),
          _buildLoadingStep(
            index: 0,
            icon: Icons.link,
            title: 'Reading URL',
          ),
          SizedBox(height: 16.h),
          _buildLoadingStep(
            index: 1,
            icon: Icons.movie_outlined,
            title: 'Analyzing video content',
          ),
          SizedBox(height: 16.h),
          _buildLoadingStep(
            index: 2,
            icon: Icons.description_outlined,
            title: 'Extracting recipe',
          ),
          SizedBox(height: 16.h),
          _buildLoadingStep(
            index: 3,
            icon: Icons.kitchen,
            title: 'Comparing with pantry',
          ),
          SizedBox(height: 80.h),
        ],
      ),
    );
  }

  Widget _buildLoadingStep({required int index, required IconData icon, required String title}) {
    final isDone = _currentStep > index;
    final isActive = _currentStep == index;

    return Row(
      children: [
        Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            color: isDone ? AppColors.primaryLight : AppColors.borderLight,
            shape: BoxShape.circle,
          ),
          child: isDone
              ? Icon(Icons.check, color: AppColors.primary, size: 16.r)
              : isActive
                  ? Padding(
                      padding: EdgeInsets.all(8.r),
                      child: const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                    )
                  : Icon(icon, color: AppColors.textMuted, size: 16.r),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isDone || isActive ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
