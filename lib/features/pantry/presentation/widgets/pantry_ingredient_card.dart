import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../bloc/pantry_bloc.dart';
import '../../bloc/pantry_event.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/pantry/data/models/ingredient_model.dart';
import 'package:vitasense/core/utils/snackbar_utils.dart';
import 'pantry_emoji_helper.dart';

class IngredientCard extends StatefulWidget {
  const IngredientCard({super.key, required this.ingredient});

  final IngredientModel ingredient;

  @override
  State<IngredientCard> createState() => _IngredientCardState();
}

class _IngredientCardState extends State<IngredientCard> with TickerProviderStateMixin {
  late final AnimationController _pressController;
  late final AnimationController _pulseController;
  late final Animation<double> _pressScale;
  final ValueNotifier<double> _swipeProgress = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    final days = widget.ingredient.expiryDate?.difference(DateTime.now()).inDays;
    // Ticking is automatically handled safely when widget is built lazily and unmounted (ListView behaviour)
    if (days != null && days <= 3) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _pulseController.dispose();
    _swipeProgress.dispose();
    super.dispose();
  }

  Widget _buildPlaceholder() {
    final nameEmoji = emojiForName(widget.ingredient.name);
    final emoji = nameEmoji.isNotEmpty ? nameEmoji : emojiForCategory(widget.ingredient.category);
    final baseColor = colorForCategory(widget.ingredient.category);
    final darkColor = Color.lerp(baseColor, Colors.black, 0.1) ?? baseColor;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [baseColor, darkColor],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        emoji,
        style: TextStyle(
          fontSize: 36.r,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.15),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }

  String _formatQuantity(double quantity, String unit) {
    final u = unit.toLowerCase();
    if ((u == 'grams' || u == 'g') && quantity >= 1000) {
      return '${(quantity / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} kg';
    }
    if (['pieces', 'szt', 'pcs', 'units'].contains(u)) {
      return '${quantity.toInt()} szt';
    }
    if (u == 'ml' && quantity >= 1000) {
      return '${(quantity / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} l';
    }
    return '${quantity.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} $unit';
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.ingredient.expiryDate?.difference(DateTime.now()).inDays;

    return Dismissible(
      key: Key(widget.ingredient.id),
      direction: DismissDirection.endToStart,
      onUpdate: (details) {
        _swipeProgress.value = details.progress;
      },
      onDismissed: (_) {
        HapticFeedback.lightImpact();
        context.read<PantryBloc>().add(DeleteIngredient(widget.ingredient.id));
      },
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: ValueListenableBuilder<double>(
          valueListenable: _swipeProgress,
          builder: (context, progress, child) {
            // Skala od 0.8 do 1.2 w zależności od progressu swipe'a
            final scale = lerpDouble(0.8, 1.3, progress.clamp(0.0, 1.0)) ?? 1.0;
            return Transform.scale(
              scale: scale,
              child: Icon(Icons.delete_outline, color: AppColors.textWhite, size: 28.r),
            );
          },
        ),
      ),
      child: ScaleTransition(
        scale: _pressScale,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTapDown: (_) => _pressController.forward(),
              onTapUp: (_) {
                _pressController.reverse();
                _showOptions(context);
              },
              onTapCancel: () => _pressController.reverse(),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 55,
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                        child: (widget.ingredient.imageUrl != null && widget.ingredient.imageUrl!.isNotEmpty)
                            ? CachedNetworkImage(
                                imageUrl: widget.ingredient.imageUrl!,
                                fit: BoxFit.cover,
                                fadeInDuration: const Duration(milliseconds: 300),
                                placeholder: (_, __) => Shimmer.fromColors(
                                  baseColor: AppColors.borderLight,
                                  highlightColor: AppColors.border,
                                  child: Container(color: AppColors.borderLight),
                                ),
                                errorWidget: (_, __, ___) => _buildPlaceholder(),
                              )
                            : _buildPlaceholder(),
                      ),
                    ),
                    Expanded(
                      flex: 45,
                      child: Padding(
                        padding: EdgeInsets.all(10.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.ingredient.name,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              _formatQuantity(widget.ingredient.quantity, widget.ingredient.unit),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            if (days != null)
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  // Jeśli days <= 3, opacity oscyluje między 0.65 a 1.0
                                  final opacity = (days <= 3) 
                                      ? lerpDouble(0.65, 1.0, _pulseController.value) ?? 1.0 
                                      : 1.0;
                                  return Opacity(
                                    opacity: opacity,
                                    child: child,
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: days <= 0
                                        ? AppColors.error
                                        : days <= 3
                                            ? AppColors.warning
                                            : AppColors.success,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    days <= 0 
                                      ? 'Expired ${(-days)}d ago'
                                      : days == 0 ? 'Expires today' : '${days}d left',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final current = widget.ingredient.storageLocation;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r)))),
            SizedBox(height: 16.h),
            // Nazwa produktu
            Text(widget.ingredient.name, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            SizedBox(height: 4.h),
            Text('Przenieś do:', style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary)),
            SizedBox(height: 16.h),
            // 3 opcje przeniesienia
            if (current != 'fridge')
              _MoveOption(
                icon: '🧊',
                label: 'Lodówka',
                subtitle: 'Krótki termin przydatności',
                onTap: () {
                  Navigator.pop(ctx);
                  HapticFeedback.mediumImpact();
                  context.read<PantryBloc>().add(MoveIngredient(widget.ingredient.id, 'fridge'));
                  SnackbarUtils.showSuccess(context, '${widget.ingredient.name} → Lodówka ✓');
                },
              ),
            if (current != 'freezer')
              _MoveOption(
                icon: '❄️',
                label: 'Zamrażarka',
                subtitle: 'Długie przechowywanie',
                onTap: () {
                  Navigator.pop(ctx);
                  HapticFeedback.mediumImpact();
                  context.read<PantryBloc>().add(MoveIngredient(widget.ingredient.id, 'freezer'));
                  SnackbarUtils.showSuccess(context, '${widget.ingredient.name} → Zamrażarka ✓');
                },
              ),
            if (current != 'pantry')
              _MoveOption(
                icon: '🗄️',
                label: 'Spiżarnia',
                subtitle: 'Suche produkty, długi termin',
                onTap: () {
                  Navigator.pop(ctx);
                  HapticFeedback.mediumImpact();
                  context.read<PantryBloc>().add(MoveIngredient(widget.ingredient.id, 'pantry'));
                  SnackbarUtils.showSuccess(context, '${widget.ingredient.name} → Spiżarnia ✓');
                },
              ),
            Divider(color: AppColors.border, height: 24.h),
            // Usuń
            _MoveOption(
              icon: '🗑️',
              label: 'Usuń produkt',
              subtitle: 'Usuń ze spiżarni',
              isDestructive: true,
              onTap: () {
                Navigator.pop(ctx);
                context.read<PantryBloc>().add(DeleteIngredient(widget.ingredient.id));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MoveOption extends StatelessWidget {
  final String icon, label, subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  const _MoveOption({required this.icon, required this.label, required this.subtitle, required this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Text(icon, style: TextStyle(fontSize: 28.sp)),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: isDestructive ? AppColors.error : AppColors.textPrimary)),
                  Text(subtitle, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: isDestructive ? AppColors.error : AppColors.textMuted, size: 20.r),
          ],
        ),
      ),
    );
  }
}
