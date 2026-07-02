import 'package:vitasense/core/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/core/widgets/app_header.dart';
import 'package:vitasense/features/recipes/bloc/recipes_bloc.dart';
import 'package:vitasense/features/recipes/bloc/recipes_event.dart';
import 'package:vitasense/features/recipes/bloc/recipes_state.dart';
import 'package:vitasense/features/recipes/data/recipes_repository.dart';
import '../widgets/my_recipe_card.dart';

part '../widgets/create_recipe/recipe_basic_info_section.dart';
part '../widgets/create_recipe/recipe_ingredients_section.dart';
part '../widgets/create_recipe/recipe_steps_section.dart';

class CreateRecipeScreen extends StatelessWidget {
  const CreateRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecipesBloc(repository: RecipesRepository())..add(const LoadMyRecipes()),
      child: const _CreateRecipeView(),
    );
  }
}

class _CreateRecipeView extends StatefulWidget {
  const _CreateRecipeView();

  @override
  State<_CreateRecipeView> createState() => _CreateRecipeViewState();
}

class _CreateRecipeViewState extends State<_CreateRecipeView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form Controllers
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _timeController = TextEditingController();
  final _servingsController = TextEditingController();

  String? _selectedCuisine;
  final List<String> _selectedTags = [];

  // Dynamic Lists
  final List<Map<String, dynamic>> _ingredients = [];
  final List<TextEditingController> _stepControllers = [];

  final List<String> _cuisines = [
    'Polish', 'Italian', 'Japanese', 'Chinese', 'Mexican',
    'Indian', 'Greek', 'Thai', 'American', 'Other'
  ];

  final List<String> _allTags = [
    'Vegan', 'Vegetarian', 'Gluten-Free', 'Dairy-Free',
    'High-Protein', 'Low-Carb', 'Keto', 'Paleo'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _timeController.dispose();
    _servingsController.dispose();
    for (var ctrl in _stepControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _saveRecipe() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      SnackbarUtils.showError(context, 'Title is required');
      return;
    }
    if (_ingredients.isEmpty) {
      SnackbarUtils.showError(context, 'At least 1 ingredient is required');
      return;
    }
    if (_stepControllers.isEmpty) {
      SnackbarUtils.showError(context, 'At least 1 step is required');
      return;
    }

    final ingredientsList = _ingredients.map((item) {
      return {
        'name': (item['name'] as TextEditingController).text.trim(),
        'amount': (item['amount'] as TextEditingController).text.trim(),
        'unit': (item['unit'] as TextEditingController).text.trim(),
      };
    }).toList();

    final stepsList = _stepControllers.map((c) => c.text.trim()).toList();

    context.read<RecipesBloc>().add(CreateRecipe(
          title: title,
          description: _descController.text.trim(),
          ingredients: ingredientsList,
          steps: stepsList,
          cookTimeMinutes: int.tryParse(_timeController.text.trim()) ?? 0,
          servings: int.tryParse(_servingsController.text.trim()) ?? 1,
          cuisineType: _selectedCuisine,
          dietTags: _selectedTags,
        ));
  }

  void _clearForm() {
    _titleController.clear();
    _descController.clear();
    _timeController.clear();
    _servingsController.clear();
    _selectedCuisine = null;
    _selectedTags.clear();
    _ingredients.clear();
    for (var ctrl in _stepControllers) {
      ctrl.dispose();
    }
    _stepControllers.clear();
    setState(() {});
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Recipe?'),
        content: const Text('Are you sure you want to delete this recipe?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<RecipesBloc>().add(DeleteRecipe(id));
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecipesBloc, RecipesState>(
      listener: (context, state) {
        if (state is RecipeCreated) {
          SnackbarUtils.showSuccess(context, 'Recipe saved! 🎉');
          _clearForm();
          _tabController.animateTo(0);
          context.read<RecipesBloc>().add(const LoadMyRecipes());
        }
        if (state is RecipesError) {
          SnackbarUtils.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(
                title: 'Zarządzaj Przepisami',
                variant: AppHeaderVariant.nested,
                onBack: () => context.pop(),
              ),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'Moje przepisy'),
                  Tab(text: 'Utwórz nowy'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMyRecipesTab(),
                    _buildCreateNewTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyRecipesTab() {
    return BlocBuilder<RecipesBloc, RecipesState>(
      builder: (context, state) {
        if (state is MyRecipesLoaded) {
          final recipes = state.recipes;
          if (recipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_outlined, color: AppColors.textMuted, size: 48.r),
                  SizedBox(height: 16.h),
                  Text('No recipes yet', style: AppTextStyles.headingMedium),
                  SizedBox(height: 8.h),
                  Text('Create your first recipe below', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  SizedBox(height: 24.h),
                  FilledButton(
                    onPressed: () => _tabController.animateTo(1),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Create Recipe'),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Recipes', style: AppTextStyles.headingLarge),
                    Text('${recipes.length} recipes created', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  itemCount: recipes.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    return MyRecipeCard(
                      recipe: recipes[index],
                      onPublish: () => context.read<RecipesBloc>().add(PublishRecipe(recipes[index].id)),
                      onDelete: () => _showDeleteDialog(recipes[index].id),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return _buildShimmerLoading();
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: AppColors.borderLight,
      highlightColor: AppColors.border,
      child: ListView.builder(
        padding: EdgeInsets.all(20.w),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          height: 100.h,
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(color: AppColors.backgroundWhite, borderRadius: BorderRadius.circular(16.r)),
        ),
      ),
    );
  }

  Widget _buildCreateNewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h).copyWith(bottom: 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RecipeBasicInfoSection(
            titleController: _titleController,
            descController: _descController,
            timeController: _timeController,
            servingsController: _servingsController,
            selectedCuisine: _selectedCuisine,
            selectedTags: _selectedTags,
            onCuisineChanged: (val) => setState(() => _selectedCuisine = val),
            onTagToggled: (tag) => setState(() {
              if (_selectedTags.contains(tag)) {
                _selectedTags.remove(tag);
              } else {
                _selectedTags.add(tag);
              }
            }),
            cuisines: _cuisines,
            allTags: _allTags,
          ),
          SizedBox(height: 24.h),

          RecipeIngredientsSection(
            ingredients: _ingredients,
          ),
          SizedBox(height: 24.h),

          RecipeStepsSection(
            stepControllers: _stepControllers,
          ),

          // ─── BOTTOM SAVE BUTTON ────────────────────────────────────────────
          SizedBox(height: 40.h),
          BlocBuilder<RecipesBloc, RecipesState>(
            builder: (context, state) {
              if (state is RecipeCreating) {
                return SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: FilledButton(
                    onPressed: null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: const CircularProgressIndicator(color: AppColors.textWhite, strokeWidth: 2),
                    ),
                  ),
                );
              }

              return SizedBox(
                width: double.infinity,
                height: 52.h,
                child: FilledButton(
                  onPressed: _saveRecipe,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text('Save Recipe', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget _buildTextField({
  required TextEditingController controller,
  required String hint,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
  bool isRequired = false,
}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    decoration: InputDecoration(
      hintText: hint + (isRequired ? ' *' : ''),
      hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14.sp),
      filled: true,
      fillColor: AppColors.backgroundWhite,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    ),
  );
}
