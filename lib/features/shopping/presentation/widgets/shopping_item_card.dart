import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/shopping/data/models/shopping_item_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/features/shopping/bloc/shopping_bloc.dart';
import 'package:vitasense/features/shopping/bloc/shopping_event.dart';

String getCategoryEmoji(String name, String? category) {
  final n = name.toLowerCase().trim();
  
  // Specific items first (before broad category checks)
  if (n.contains('egg')) return '🥚';
  if (n.contains('butter')) return '🧈';
  if (n.contains('milk') || n.contains('buttermilk')) return '🥛';
  if (n.contains('cheese')) return '🧀';
  if (n.contains('yogurt') || n.contains('yoghurt')) return '🫙';
  if (n.contains('cream') && !n.contains('ice cream')) return '🥛';
  if (n.contains('ice cream')) return '🍦';
  
  if (n.contains('chicken')) return '🍗';
  if (n.contains('beef') || n.contains('steak') || n.contains('mince')) return '🥩';
  if (n.contains('pork') || n.contains('bacon') || n.contains('ham')) return '🥓';
  if (n.contains('fish') || n.contains('salmon') || n.contains('tuna') || n.contains('cod')) return '🐟';
  if (n.contains('shrimp') || n.contains('prawn')) return '🦐';
  
  if (n.contains('apple')) return '🍎';
  if (n.contains('banana')) return '🍌';
  if (n.contains('strawberr') || n.contains('raspberry') || n.contains('blueberr')) return '🍓';
  if (n.contains('orange') || n.contains('lemon') || n.contains('lime')) return '🍋';
  if (n.contains('grape')) return '🍇';
  if (n.contains('watermelon')) return '🍉';
  if (n.contains('peach')) return '🍑';
  
  if (n.contains('tomato')) return '🍅';
  if (n.contains('carrot')) return '🥕';
  if (n.contains('onion')) return '🧅';
  if (n.contains('garlic')) return '🧄';
  if (n.contains('potato')) return '🥔';
  if (n.contains('broccoli') || n.contains('spinach') || n.contains('lettuce') || n.contains('mesclun') || n.contains('kale')) return '🥦';
  if (n.contains('pepper') || n.contains('papryka')) return '🫑';
  if (n.contains('mushroom')) return '🍄';
  if (n.contains('cucumber')) return '🥒';
  if (n.contains('corn')) return '🌽';
  if (n.contains('avocado')) return '🥑';
  
  if (n.contains('bread') || n.contains('toast') || n.contains('baguette')) return '🍞';
  if (n.contains('pasta') || n.contains('noodle') || n.contains('spaghetti')) return '🍝';
  if (n.contains('rice')) return '🍚';
  if (n.contains('flour') || n.contains('mąka')) return '🌾';
  if (n.contains('oat')) return '🌾';
  if (n.contains('cereal')) return '🥣';
  
  if (n.contains('sugar') || n.contains('cukier')) return '🍬';
  if (n.contains('honey')) return '🍯';
  if (n.contains('chocolate')) return '🍫';
  if (n.contains('vanilla')) return '🌿';
  if (n.contains('cinnamon') || n.contains('nutmeg') || n.contains('spice') || n.contains('herb')) return '🌿';
  if (n.contains('salt') || n.contains('pepper') && n.contains('black')) return '🧂';
  if (n.contains('oil') || n.contains('vinegar')) return '🫙';
  if (n.contains('sauce') || n.contains('ketchup') || n.contains('mustard')) return '🥫';
  
  if (n.contains('coffee')) return '☕';
  if (n.contains('tea')) return '🍵';
  if (n.contains('juice')) return '🧃';
  if (n.contains('water')) return '💧';
  if (n.contains('wine') || n.contains('beer')) return '🍷';
  if (n.contains('irish cream') || n.contains('bailey')) return '🥃';
  
  if (n.contains('cake') || n.contains('cookie') || n.contains('biscuit')) return '🍪';
  if (n.contains('chip') || n.contains('crisp')) return '🍟';
  if (n.contains('nut') || n.contains('almond') || n.contains('walnut')) return '🥜';
  
  // Category fallback
  final c = (category ?? '').toLowerCase();
  if (c.contains('dairy')) return '🥛';
  if (c.contains('meat')) return '🥩';
  if (c.contains('vegetable')) return '🥦';
  if (c.contains('fruit')) return '🍎';
  if (c.contains('grain') || c.contains('bread')) return '🌾';
  if (c.contains('drink') || c.contains('beverage')) return '🥤';
  
  return '🛒';
}

class ShoppingItemCard extends StatefulWidget {
  final ShoppingItemModel item;

  const ShoppingItemCard({super.key, required this.item});

  @override
  State<ShoppingItemCard> createState() => _ShoppingItemCardState();
}

class _ShoppingItemCardState extends State<ShoppingItemCard> with SingleTickerProviderStateMixin {
  bool _isChecking = false;

  void _handleCheck() {
    if (_isChecking) return;
    HapticFeedback.selectionClick();
    setState(() {
      _isChecking = true;
    });
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      context.read<ShoppingBloc>().add(MarkItemPurchased(widget.item.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _isChecking 
        ? const SizedBox() 
        : Dismissible(
            key: Key(widget.item.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) {
              HapticFeedback.lightImpact();
              context.read<ShoppingBloc>().add(DeleteShoppingItem(widget.item.id));
            },
            background: Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20.w),
              child: Icon(Icons.delete, color: AppColors.textWhite, size: 24.r),
            ),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _handleCheck,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24.r,
                      height: 24.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isChecking ? AppColors.primary : Colors.transparent,
                        border: Border.all(
                          color: _isChecking ? AppColors.primary : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: _isChecking
                          ? Icon(Icons.check, size: 16.r, color: Colors.white)
                          : null,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        getCategoryEmoji(widget.item.name, widget.item.category),
                        style: TextStyle(fontSize: 22.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.name,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${widget.item.quantity.toStringAsFixed(widget.item.quantity.truncateToDouble() == widget.item.quantity ? 0 : 1)} ${widget.item.unit}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}