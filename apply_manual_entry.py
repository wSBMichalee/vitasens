import os
import re

# 1. category_grid_widget.dart
grid_file = 'lib/features/pantry/presentation/widgets/add_ingredient/category_grid_widget.dart'
with open(grid_file, 'r', encoding='utf-8') as f:
    grid_content = f.read()

grid_content = grid_content.replace(
'''  const CategoryGridWidget({super.key, required this.onCategoryTap});
  final ValueChanged<String> onCategoryTap;''',
'''  const CategoryGridWidget({
    super.key,
    required this.onCategoryTap,
    this.onManualSelect,
  });
  final ValueChanged<String> onCategoryTap;
  final void Function(Map<String, String> category)? onManualSelect;'''
)

grid_content = grid_content.replace(
'''              return GestureDetector(
                onTap: () => onCategoryTap(cat['query']!),''',
'''              return GestureDetector(
                onTap: () {
                  if (onManualSelect != null) {
                    onManualSelect!(cat);
                  } else {
                    onCategoryTap(cat['query']!);
                  }
                },'''
)

with open(grid_file, 'w', encoding='utf-8') as f:
    f.write(grid_content)

# 2. add_ingredient_screen.dart
screen_file = 'lib/features/pantry/presentation/screens/add_ingredient_screen.dart'
with open(screen_file, 'r', encoding='utf-8') as f:
    screen_content = f.read()

screen_content = screen_content.replace(
'''  String _selectedCategoryLabel = '';''',
'''  String _selectedCategoryLabel = '';
  
  bool _manualEntryMode = false;
  final TextEditingController _manualNameController = TextEditingController();
  String _selectedEmoji = '🍽️';'''
)

screen_content = screen_content.replace(
'''  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }''',
'''  void dispose() {
    _searchController.dispose();
    _manualNameController.dispose();
    _debounce?.cancel();
    super.dispose();
  }'''
)

screen_content = screen_content.replace(
'''    } else if (catLower.contains('nabiał') || catLower.contains('napoje')) {
      _category = 'dairy';
      _unit = 'ml';
      _quantity = 100;
    } else {''',
'''    } else if (catLower.contains('nabiał') || catLower.contains('napoje')) {
      _category = 'dairy';
      _unit = 'ml';
      _quantity = 100;
    } else if (catLower.contains('mięso') || catLower.contains('ryby')) {
      _category = 'protein';
      _unit = 'g';
      _quantity = 100;
    } else if (catLower.contains('zboża') || catLower.contains('pieczywo')) {
      _category = 'grains';
      _unit = 'g';
      _quantity = 100;
    } else {'''
)

screen_content = screen_content.replace(
'''                            _selectedCategoryLabel = item.categoryLabel;
                            _resolveCategoryAndUnit(item.categoryLabel);''',
'''                            _selectedCategoryLabel = item.categoryLabel;
                            _selectedEmoji = item.categoryEmoji;
                            _resolveCategoryAndUnit(item.categoryLabel);'''
)

screen_content = screen_content.replace(
'''  Widget _buildSearchStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar''',
'''  Widget _buildSearchStep() {
    if (_manualEntryMode) {
      return _buildManualEntryStep();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: TextButton.icon(
              onPressed: () => setState(() => _manualEntryMode = true),
              icon: Icon(Icons.edit_outlined, size: 16.r, color: AppColors.primary),
              label: Text(
                'Nie znalazłeś produktu? Dodaj ręcznie',
                style: TextStyle(fontSize: 13.sp, color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        // Search bar'''
)

methods_to_insert = '''  void _selectManualCategory(Map<String, String> cat) {
    final name = _manualNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wpisz najpierw nazwę produktu')),
      );
      return;
    }
    setState(() {
      _selectedName = name;
      _selectedImageUrl = null;
      _selectedCategoryLabel = cat['name']!;
      _selectedEmoji = cat['emoji']!;
      _resolveCategoryAndUnit(cat['name']!);
      _manualEntryMode = false;
    });
  }

  Widget _buildManualEntryStep() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _manualEntryMode = false),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_ios, size: 14.r, color: AppColors.primary),
                SizedBox(width: 4.w),
                Text(
                  'Wróć do wyszukiwania',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'NAZWA PRODUKTU',
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2),
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: TextField(
              controller: _manualNameController,
              style: TextStyle(fontSize: 15.sp, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'np. Jogurt naturalny',
                hintStyle: TextStyle(fontSize: 15.sp, color: Colors.grey.shade400),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'WYBIERZ KATEGORIĘ',
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2),
          ),
          SizedBox(height: 12.h),
          CategoryGridWidget(
            onCategoryTap: (_) {},
            onManualSelect: _selectManualCategory,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsStep() {'''

screen_content = screen_content.replace('  Widget _buildDetailsStep() {', methods_to_insert)

screen_content = screen_content.replace(
'''errorWidget: (_, __, ___) => const FallbackImageWidget(emoji: '🍽️'),''',
'''errorWidget: (_, __, ___) => FallbackImageWidget(emoji: _selectedEmoji),'''
)

screen_content = screen_content.replace(
''': const FallbackImageWidget(emoji: '🍽️'),''',
''': FallbackImageWidget(emoji: _selectedEmoji),'''
)

with open(screen_file, 'w', encoding='utf-8') as f:
    f.write(screen_content)

print("Done apply_manual_entry.py")
