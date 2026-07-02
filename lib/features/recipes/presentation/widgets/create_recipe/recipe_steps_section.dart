part of '../../screens/create_recipe_screen.dart';

class RecipeStepsSection extends StatefulWidget {
  final List<TextEditingController> stepControllers;

  const RecipeStepsSection({super.key, required this.stepControllers});

  @override
  State<RecipeStepsSection> createState() => _RecipeStepsSectionState();
}

class _RecipeStepsSectionState extends State<RecipeStepsSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEPS', style: AppTextStyles.caption),
        SizedBox(height: 12.h),
        ...widget.stepControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final ctrl = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24.r,
                  height: 24.r,
                  margin: EdgeInsets.only(top: 12.h),
                  decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text('${index + 1}', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildTextField(
                    controller: ctrl,
                    hint: 'Step description',
                    maxLines: 2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () {
                    setState(() {
                      ctrl.dispose();
                      widget.stepControllers.removeAt(index);
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
              widget.stepControllers.add(TextEditingController());
            });
          },
          icon: const Icon(Icons.add, color: AppColors.primary),
          label: const Text('Add Step', style: TextStyle(color: AppColors.primary)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
        ),
      ],
    );
  }
}
