part of '../../screens/create_recipe_screen.dart';

class RecipeBasicInfoSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descController;
  final TextEditingController timeController;
  final TextEditingController servingsController;
  final String? selectedCuisine;
  final List<String> selectedTags;
  final ValueChanged<String?> onCuisineChanged;
  final ValueChanged<String> onTagToggled;
  final List<String> cuisines;
  final List<String> allTags;

  const RecipeBasicInfoSection({
    super.key,
    required this.titleController,
    required this.descController,
    required this.timeController,
    required this.servingsController,
    this.selectedCuisine,
    required this.selectedTags,
    required this.onCuisineChanged,
    required this.onTagToggled,
    required this.cuisines,
    required this.allTags,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── BASICS ────────────────────────────────────────────────────────
        Text('RECIPE BASICS', style: AppTextStyles.caption),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: titleController,
          hint: 'Recipe title',
          isRequired: true,
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: descController,
          hint: 'Description',
          maxLines: 3,
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: timeController,
                hint: 'Cook time (min)',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildTextField(
                controller: servingsController,
                hint: 'Servings',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),

        // ─── CUISINE & DIET ────────────────────────────────────────────────
        Text('CUISINE & DIET', style: AppTextStyles.caption),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
            color: AppColors.backgroundWhite,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCuisine,
              isExpanded: true,
              hint: Text('Select Cuisine', style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp)),
              items: cuisines.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: onCuisineChanged,
            ),
          ),
        ),
        SizedBox(height: 24.h),

        // ─── DIET TAGS ─────────────────────────────────────────────────────
        Text('DIET TAGS', style: AppTextStyles.caption),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: allTags.map((tag) {
            final isSelected = selectedTags.contains(tag);
            return ChoiceChip(
              label: Text(tag, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500)),
              selected: isSelected,
              selectedColor: AppColors.primaryLight,
              backgroundColor: AppColors.borderLight,
              labelStyle: TextStyle(color: isSelected ? AppColors.primary : AppColors.textSecondary),
              onSelected: (_) => onTagToggled(tag),
            );
          }).toList(),
        ),
      ],
    );
  }
}
