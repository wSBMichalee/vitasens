import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/recipes/bloc/recipes_bloc.dart';
import 'package:vitasense/features/recipes/bloc/recipes_event.dart';
import 'package:vitasense/features/recipes/bloc/recipes_state.dart';

class RecipeCard extends StatefulWidget {
  const RecipeCard({super.key, required this.recipe, required this.isFavorite});

  final Map<String, dynamic> recipe;
  final bool isFavorite;

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late String _recipeId;

  @override
  void initState() {
    super.initState();
    _recipeId = widget.recipe['id']?.toString() ?? UniqueKey().toString();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final imageUrl = recipe['imageUrl'] as String?;
    final title = recipe['title'] as String? ?? 'Brak tytułu';
    final cookTime = recipe['cookTimeMinutes'] as int? ?? 0;
    final calories = (recipe['calories'] as num?)?.toInt() ?? 0;
    
    final matchPercent = (recipe['matchPercent'] as num?)?.toInt();
    final createdAtStr = recipe['createdAt'] as String?;
    final source = recipe['source'] as String?;
    
    bool isNew = false;
    if (createdAtStr != null && source != null && source != 'spoonacular' && source != 'themealdb') {
      final createdAt = DateTime.tryParse(createdAtStr);
      if (createdAt != null) {
        final diff = DateTime.now().difference(createdAt);
        if (diff.inDays <= 7) {
          isNew = true;
        }
      }
    }

    return Listener(
      onPointerDown: (_) {
        HapticFeedback.lightImpact();
        _controller.forward();
      },
      onPointerUp: (_) {
        _controller.reverse();
      },
      onPointerCancel: (_) {
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.recipeDetails, extra: widget.recipe),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: BlocListener<RecipesBloc, RecipesState>(
            listenWhen: (previous, current) => current is FavoriteToggled && current.recipeId == _recipeId,
            listener: (context, state) {
              // Służy tylko do opcjonalnych lokalnych efektów ubocznych
              // np. HapticFeedback czy dodatkowe animacje serca, 
              // bo widget.isFavorite zostanie zaktualizowane przez rodzica
              if (state is FavoriteToggled) {
                setState(() {}); // wymuszenie rebuilda jeśli rodzic jeszcze tego nie zrobił
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    color: Colors.black.withValues(alpha: 0.05),
                  ),
                ],
              ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'recipe_image_$_recipeId',
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
                          child: imageUrl != null && imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  fadeInDuration: const Duration(milliseconds: 300),
                                  placeholder: (context, url) => _buildPlaceholder(),
                                  errorWidget: (context, url, error) => _buildPlaceholder(),
                                )
                              : _buildPlaceholder(),
                        ),
                      ),
                      
                      // Match Badge & NEW Badge
                      if (matchPercent != null)
                        Positioned(
                          top: 8.h,
                          left: 8.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: matchPercent >= 80 ? AppColors.successLight : (matchPercent >= 40 ? Colors.orange[100] : AppColors.errorLight),
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: matchPercent >= 80 ? AppColors.success : (matchPercent >= 40 ? Colors.orange : AppColors.error),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '${matchPercent >= 80 ? '🟢' : (matchPercent >= 40 ? '🟡' : '🔴')} $matchPercent%',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    color: matchPercent >= 80 ? AppColors.successDark : (matchPercent >= 40 ? Colors.orange[900] : AppColors.error),
                                  ),
                                ),
                              ),
                              if (isNew)
                                Container(
                                  margin: EdgeInsets.only(top: 4.h),
                                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: Colors.purple[100],
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(color: Colors.purple, width: 1),
                                  ),
                                  child: Text(
                                    'NOWY',
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.purple[900],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      
                      // Favorite icon
                      Positioned(
                        top: 8.h,
                        right: 8.w,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.read<RecipesBloc>().add(ToggleFavorite(_recipeId, currentlyFavorited: widget.isFavorite));
                          },
                          child: Container(
                            padding: EdgeInsets.all(6.r),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4.r)],
                            ),
                            child: Icon(
                              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                              size: 18.r,
                              color: widget.isFavorite ? AppColors.error : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Padding(
                  padding: EdgeInsets.all(10.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      
                      // Clock & Flame row
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 12.r, color: AppColors.textSecondary),
                          SizedBox(width: 4.w),
                          Text(
                            '$cookTime min',
                            style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                          Spacer(),
                          Icon(Icons.local_fire_department_outlined, size: 12.r, color: AppColors.textSecondary),
                          SizedBox(width: 4.w),
                          Text(
                            '$calories kcal',
                            style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.restaurant, size: 32.r, color: AppColors.textMuted),
      ),
    );
  }
}