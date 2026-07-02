part of '../../screens/create_recipe_screen.dart';

class RecipeIngredientsSection extends StatefulWidget {
  final List<Map<String, dynamic>> ingredients;

  const RecipeIngredientsSection({super.key, required this.ingredients});

  @override
  State<RecipeIngredientsSection> createState() => _RecipeIngredientsSectionState();
}

class _RecipeIngredientsSectionState extends State<RecipeIngredientsSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('INGREDIENTS', style: AppTextStyles.caption),
        SizedBox(height: 12.h),
        ...widget.ingredients.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                Expanded(flex: 3, child: _buildTextField(controller: item['name'] as TextEditingController, hint: 'Name')),
                SizedBox(width: 8.w),
                Expanded(flex: 1, child: _buildTextField(controller: item['amount'] as TextEditingController, hint: 'Amt')),
                SizedBox(width: 8.w),
                Expanded(flex: 1, child: _buildTextField(controller: item['unit'] as TextEditingController, hint: 'Unit')),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () {
                    setState(() {
                      (item['name'] as TextEditingController).dispose();
                      (item['amount'] as TextEditingController).dispose();
                      (item['unit'] as TextEditingController).dispose();
                      widget.ingredients.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        }),
        SizedBox(height: 8.h),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              widget.ingredients.add({
                'name': TextEditingController(),
                'amount': TextEditingController(),
                'unit': TextEditingController(),
              });
            });
          },
          icon: const Icon(Icons.add, color: AppColors.primary),
          label: const Text('Add Ingredient', style: TextStyle(color: AppColors.primary)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
        ),
      ],
    );
  }
}
