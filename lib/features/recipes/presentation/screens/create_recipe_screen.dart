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
import 'package:vitasense/features/recipes/data/models/recipe_model.dart';
import 'package:vitasense/features/recipes/data/recipes_repository.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required'), backgroundColor: AppColors.error),
      );
      return;
    }
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least 1 ingredient is required'), backgroundColor: AppColors.error),
      );
      return;
    }
    if (_stepControllers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least 1 step is required'), backgroundColor: AppColors.error),
      );
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recipe saved! 🎉'), backgroundColor: AppColors.primary),
          );
          _clearForm();
          _tabController.animateTo(0);
          context.read<RecipesBloc>().add(const LoadMyRecipes());
        }
        if (state is RecipesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
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
                    return _MyRecipeCard(
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
          // ─── BASICS ────────────────────────────────────────────────────────
          Text('RECIPE BASICS', style: AppTextStyles.caption),
          SizedBox(height: 12.h),
          _buildTextField(
            controller: _titleController,
            hint: 'Recipe title',
            isRequired: true,
          ),
          SizedBox(height: 12.h),
          _buildTextField(
            controller: _descController,
            hint: 'Description',
            maxLines: 3,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _timeController,
                  hint: 'Cook time (min)',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTextField(
                  controller: _servingsController,
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
                value: _selectedCuisine,
                isExpanded: true,
                hint: Text('Select Cuisine', style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp)),
                items: _cuisines.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCuisine = val),
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
            children: _allTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return ChoiceChip(
                label: Text(tag, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500)),
                selected: isSelected,
                selectedColor: AppColors.primaryLight,
                backgroundColor: AppColors.borderLight,
                labelStyle: TextStyle(color: isSelected ? AppColors.primary : AppColors.textSecondary),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: 24.h),

          // ─── INGREDIENTS ───────────────────────────────────────────────────
          Text('INGREDIENTS', style: AppTextStyles.caption),
          SizedBox(height: 12.h),
          ..._ingredients.asMap().entries.map((entry) {
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
                        _ingredients.removeAt(index);
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
                _ingredients.add({
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
          SizedBox(height: 24.h),

          // ─── STEPS ─────────────────────────────────────────────────────────
          Text('STEPS', style: AppTextStyles.caption),
          SizedBox(height: 12.h),
          ..._stepControllers.asMap().entries.map((entry) {
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
                        _stepControllers.removeAt(index);
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
                _stepControllers.add(TextEditingController());
              });
            },
            icon: const Icon(Icons.add, color: AppColors.primary),
            label: const Text('Add Step', style: TextStyle(color: AppColors.primary)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
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
}

class _MyRecipeCard extends StatelessWidget {
  final RecipeModel recipe;
  final VoidCallback onPublish;
  final VoidCallback onDelete;

  const _MyRecipeCard({
    required this.recipe,
    required this.onPublish,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        recipe.title,
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (recipe.isPublished)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(6.r)),
                        child: Text('PUBLIC', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      )
                    else
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(6.r)),
                        child: Text('DRAFT', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.timer_outlined, color: AppColors.textMuted, size: 12.r),
                    SizedBox(width: 4.w),
                    Text('${recipe.cookTimeMinutes} min', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                    SizedBox(width: 8.w),
                    Icon(Icons.favorite, color: AppColors.error, size: 12.r),
                    SizedBox(width: 4.w),
                    Text('${recipe.likesCount}', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20.r),
            padding: EdgeInsets.zero,
            onSelected: (value) {
              if (value == 'publish') onPublish();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => [
              if (!recipe.isPublished)
                const PopupMenuItem(
                  value: 'publish',
                  child: Text('Publish'),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
