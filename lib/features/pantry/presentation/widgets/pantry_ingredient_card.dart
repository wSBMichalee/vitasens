import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../bloc/pantry_bloc.dart';
import '../../bloc/pantry_event.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/pantry/data/models/ingredient_model.dart';
import 'pantry_emoji_helper.dart';

class IngredientCard extends StatelessWidget {
  const IngredientCard({super.key, required this.ingredient});

  final IngredientModel ingredient;

  Widget _buildPlaceholder() {
    final nameEmoji = emojiForName(ingredient.name);
    final emoji = nameEmoji.isNotEmpty ? nameEmoji : emojiForCategory(ingredient.category);

    return Container(
      color: colorForCategory(ingredient.category),
      alignment: Alignment.center,
      child: Text(
        emoji,
        style: TextStyle(fontSize: 36.r),
      ),
    );
  }

  String _formatQuantity(double quantity, String unit) {
    final u = unit.toLowerCase();
    if ((u == 'grams' || u == 'g') && quantity >= 1000) {
      return '${(quantity / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\\.0\$'), '')} kg';
    }
    if (['pieces', 'szt', 'pcs', 'units'].contains(u)) {
      return '${quantity.toInt()} szt';
    }
    if (u == 'ml' && quantity >= 1000) {
      return '${(quantity / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\\.0\$'), '')} l';
    }
    return '${quantity.toStringAsFixed(1).replaceAll(RegExp(r'\\.0\$'), '')} $unit';
  }

  @override
  Widget build(BuildContext context) {
    final days = ingredient.expiryDate?.difference(DateTime.now()).inDays;

    return Dismissible(
      key: Key(ingredient.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) =>
          context.read<PantryBloc>().add(DeleteIngredient(ingredient.id)),
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.delete_outline, color: AppColors.textWhite, size: 28.r),
      ),
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
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () => _showOptions(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 55,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    child: (ingredient.imageUrl != null && ingredient.imageUrl!.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: ingredient.imageUrl!,
                            fit: BoxFit.cover,
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
                          ingredient.name,
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
                          _formatQuantity(ingredient.quantity, ingredient.unit),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        if (days != null)
                          Container(
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _showOptions(BuildContext context) {
    final current = ingredient.storageLocation;
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
            Text(ingredient.name, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
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
                  context.read<PantryBloc>().add(MoveIngredient(ingredient.id, 'fridge'));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${ingredient.name} → Lodówka ✓'),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 2),
                  ));
                },
              ),
            if (current != 'freezer')
              _MoveOption(
                icon: '❄️',
                label: 'Zamrażarka',
                subtitle: 'Długie przechowywanie',
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<PantryBloc>().add(MoveIngredient(ingredient.id, 'freezer'));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${ingredient.name} → Zamrażarka ✓'),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 2),
                  ));
                },
              ),
            if (current != 'pantry')
              _MoveOption(
                icon: '🗄️',
                label: 'Spiżarnia',
                subtitle: 'Suche produkty, długi termin',
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<PantryBloc>().add(MoveIngredient(ingredient.id, 'pantry'));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${ingredient.name} → Spiżarnia ✓'),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 2),
                  ));
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
                context.read<PantryBloc>().add(DeleteIngredient(ingredient.id));
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

