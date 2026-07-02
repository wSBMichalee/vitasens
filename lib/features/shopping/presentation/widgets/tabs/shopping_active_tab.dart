part of '../../screens/shopping_list_screen.dart';

class ShoppingActiveTab extends StatelessWidget {
  final List<ShoppingItemModel> items;
  final TextEditingController quickAddController;
  final void Function(String) onQuickAdd;

  const ShoppingActiveTab({
    super.key,
    required this.items,
    required this.quickAddController,
    required this.onQuickAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: quickAddController,
                  decoration: InputDecoration(
                    hintText: 'Quick add item...',
                    hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14.sp),
                    prefixIcon: Icon(Icons.add_shopping_cart, color: AppColors.textMuted, size: 20.r),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  onSubmitted: onQuickAdd,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        if (items.isEmpty)
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72.r,
                      height: 72.r,
                      decoration: const BoxDecoration(
                        color: AppColors.borderLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.shopping_cart_outlined,
                          size: 36.r, color: AppColors.textMuted),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Your list is empty',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 80.h),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ShoppingItemCard(item: items[index]);
              },
            ),
          ),
      ],
    );
  }
}
