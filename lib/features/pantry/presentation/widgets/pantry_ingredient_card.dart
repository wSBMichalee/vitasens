import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../bloc/pantry_bloc.dart';
import '../../bloc/pantry_event.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/pantry/data/models/ingredient_model.dart';

class IngredientCard extends StatelessWidget {
  const IngredientCard({super.key, required this.ingredient});

  final IngredientModel ingredient;

  String _emojiForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
      case 'fruit':
        return '🍎';
      case 'protein':
        return '🥩';
      case 'vegetables':
      case 'vegetable':
        return '🥦';
      case 'dairy':
        return '🥛';
      case 'grains':
      case 'grain':
        return '🌾';
      default:
        return '🛒';
    }
  }

  Color _colorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
      case 'fruit':
        return const Color(0xFFFFF3E0);
      case 'protein':
        return const Color(0xFFFFEBEE);
      case 'vegetables':
      case 'vegetable':
        return const Color(0xFFE8F5E9);
      case 'dairy':
        return const Color(0xFFE3F2FD);
      case 'grains':
      case 'grain':
        return const Color(0xFFFFF8E1);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  String _emojiForName(String name) {
    final n = name.toLowerCase();
    if (n.contains('kiwi')) return '🥝';
    if (n.contains('banana')) return '🍌';
    if (n.contains('apple') || n.contains('jabłko')) return '🍎';
    if (n.contains('orange') || n.contains('pomarańcz')) return '🍊';
    if (n.contains('lemon') || n.contains('cytryna')) return '🍋';
    if (n.contains('strawberr') || n.contains('truskaw')) return '🍓';
    if (n.contains('grape') || n.contains('winogron')) return '🍇';
    if (n.contains('mango')) return '🥭';
    if (n.contains('pineapple') || n.contains('ananas')) return '🍍';
    if (n.contains('watermelon') || n.contains('arbuz')) return '🍉';
    if (n.contains('pear') || n.contains('gruszka')) return '🍐';
    if (n.contains('peach') || n.contains('brzoskwin')) return '🍑';
    if (n.contains('cherry') || n.contains('wiśni') || n.contains('czereśni')) return '🍒';
    if (n.contains('mixed fruit') || n.contains('fruit mix')) return '🍓';
    if (n.contains('avocado') || n.contains('awokado')) return '🥑';
    if (n.contains('carrot') || n.contains('marchew')) return '🥕';
    if (n.contains('broccoli') || n.contains('brokuł')) return '🥦';
    if (n.contains('tomato') || n.contains('pomidor')) return '🍅';
    if (n.contains('potato') || n.contains('ziemniak')) return '🥔';
    if (n.contains('milk') || n.contains('mleko')) return '🥛';
    if (n.contains('cheese') || n.contains('ser')) return '🧀';
    if (n.contains('egg') || n.contains('jajk')) return '🥚';
    if (n.contains('bread') || n.contains('chleb')) return '🍞';
    if (n.contains('chicken') || n.contains('kurczak')) return '🍗';
    return '';
  }

  Widget _buildPlaceholder() {
    final nameEmoji = _emojiForName(ingredient.name);
    final emoji = nameEmoji.isNotEmpty ? nameEmoji : _emojiForCategory(ingredient.category);

    return Container(
      color: _colorForCategory(ingredient.category),
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
            onTap: () {},
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
                              days <= 0 ? 'Expired' : '${days}d left',
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
}

