import re

# 1. CREATE pantry_storage_tabs.dart
tabs_code = """import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class PantryStorageTabs extends StatelessWidget {
  const PantryStorageTabs({super.key, required this.selected, required this.onSelected});
  final String selected; // 'fridge' lub 'pantry'
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Expanded(child: _tab(context, 'fridge', Icons.kitchen_outlined, 'Lodówka')),
          SizedBox(width: 4.w),
          Expanded(child: _tab(context, 'pantry', Icons.inventory_2_outlined, 'Spiżarka')),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, String value, IconData icon, String label) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.backgroundWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: isSelected ? [
            BoxShadow(color: AppColors.textPrimary.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.r, color: isSelected ? AppColors.primary : AppColors.textMuted),
            SizedBox(width: 6.w),
            Text(label, style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
            )),
          ],
        ),
      ),
    );
  }
}
"""
with open('lib/features/pantry/presentation/widgets/pantry_storage_tabs.dart', 'w') as f:
    f.write(tabs_code)


# 2. UPDATE pantry_empty_state.dart
pes_path = 'lib/features/pantry/presentation/widgets/pantry_empty_state.dart'
with open(pes_path, 'r') as f:
    pes = f.read()

pes = pes.replace('const PantryEmptyState({super.key, required this.isFiltered, required this.onActionPressed});', 
                  'const PantryEmptyState({super.key, required this.isFiltered, required this.onActionPressed, required this.storageLabel});\n  final String storageLabel;')

pes = pes.replace("'Your pantry is empty'", "'Twoja $storageLabel jest pusta'")
pes = pes.replace("'Add your first ingredient to get started'", "storageLabel == 'lodówka' ? 'Dodaj swój pierwszy produkt z lodówki by zacząć' : 'Dodaj swój pierwszy produkt ze spiżarki by zacząć'")

with open(pes_path, 'w') as f:
    f.write(pes)


# 3. UPDATE pantry_screen.dart
ps_path = 'lib/features/pantry/presentation/screens/pantry_screen.dart'
with open(ps_path, 'r') as f:
    ps = f.read()

# ADD IMPORTS
import_insert = "import '../widgets/pantry_storage_tabs.dart';\n"
lines = ps.split('\n')
last_import = max([i for i, line in enumerate(lines) if line.startswith('import ')])
lines.insert(last_import + 1, import_insert)
ps = '\n'.join(lines)


# Add helper methods and state variable
helpers = """  String _selectedStorage = 'fridge';

  bool _isPantryCategory(String category) {
    return category == 'grains' || category == 'other' || category == 'cereal' || category == 'chocolate' || category == 'drinks' || category == 'bread';
  }

  bool _belongsToStorage(IngredientModel ingredient, String storage) {
    final isPantry = _isPantryCategory(ingredient.category.toLowerCase());
    return storage == 'pantry' ? isPantry : !isPantry;
  }
"""
ps = ps.replace('String _searchQuery = \'\';', 'String _searchQuery = \'\';\n' + helpers)


# Update _applyFilters
old_apply = """  List<IngredientModel> _applyFilters(PantryLoaded state) {
    List<IngredientModel> result;
    switch (state.selectedFilter) {
      case 'expiring':
        result = state.expiringSoon;
      case 'low_stock':
        result =
            state.ingredients.where((i) => i.quantity <= i.minimumQuantity).toList();
      default:
        result = state.ingredients;
    }
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((i) => i.name.toLowerCase().contains(q)).toList();
    }
    return result;
  }"""
new_apply = """  List<IngredientModel> _applyFilters(PantryLoaded state) {
    // 1. Storage filter
    List<IngredientModel> result = state.ingredients.where((i) => _belongsToStorage(i, _selectedStorage)).toList();

    // 2. Selected filter (expiring/low_stock)
    switch (state.selectedFilter) {
      case 'expiring':
        result = state.expiringSoon.where((i) => _belongsToStorage(i, _selectedStorage)).toList();
      case 'low_stock':
        result = result.where((i) => i.quantity <= i.minimumQuantity).toList();
      default:
        break; // already filtered by storage
    }

    // 3. Search query
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((i) => i.name.toLowerCase().contains(q)).toList();
    }
    
    return result;
  }"""
ps = ps.replace(old_apply, new_apply)


# Insert PantryStorageTabs in _buildLoaded
search_bar_code = """                        PantrySearchBar(
  controller: _searchController,"""

tabs_insert = """                        PantryStorageTabs(
                          selected: _selectedStorage,
                          onSelected: (v) => setState(() => _selectedStorage = v),
                        ),
                        SizedBox(height: 12.h),
"""
ps = ps.replace(search_bar_code, tabs_insert + search_bar_code)

# Filter expiry banner
old_banner = """                        if (state.expiringSoon.isNotEmpty) ...[
                          SizedBox(height: 20.h),
                          PantryExpiryBanner(expiring: state.expiringSoon),
                        ],"""
new_banner = """                        Builder(builder: (context) {
                          final expiringInStorage = state.expiringSoon.where((i) => _belongsToStorage(i, _selectedStorage)).toList();
                          if (expiringInStorage.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 20.h),
                                PantryExpiryBanner(expiring: expiringInStorage),
                              ]
                            );
                          }
                          return const SizedBox.shrink();
                        }),"""
ps = ps.replace(old_banner, new_banner)

# Add storageLabel to EmptyState
old_empty = """PantryEmptyState(
  isFiltered: state.selectedFilter != 'all' || _searchQuery.isNotEmpty,
  onActionPressed: (state.selectedFilter != 'all' || _searchQuery.isNotEmpty)"""
new_empty = """PantryEmptyState(
  storageLabel: _selectedStorage == 'fridge' ? 'lodówka' : 'spiżarka',
  isFiltered: state.selectedFilter != 'all' || _searchQuery.isNotEmpty,
  onActionPressed: (state.selectedFilter != 'all' || _searchQuery.isNotEmpty)"""
ps = ps.replace(old_empty, new_empty)

# Update _sectionTitle
old_title = """  String _sectionTitle(String filter) {
    switch (filter) {
      case 'expiring':
        return 'Expiring soon';
      case 'low_stock':
        return 'Low stock items';
      default:
        return 'All ingredients';
    }
  }"""
new_title = """  String _sectionTitle(String filter) {
    final prefix = _selectedStorage == 'fridge' ? 'Lodówka' : 'Spiżarka';
    switch (filter) {
      case 'expiring':
        return '$prefix: Expiring soon';
      case 'low_stock':
        return '$prefix: Low stock items';
      default:
        return '$prefix: All ingredients';
    }
  }"""
ps = ps.replace(old_title, new_title)


with open(ps_path, 'w') as f:
    f.write(ps)

print("implement_tabs.py completed")
