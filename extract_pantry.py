import re
import os

file_path = 'lib/features/pantry/presentation/screens/pantry_screen.dart'
widget_dir = 'lib/features/pantry/presentation/widgets/'
os.makedirs(widget_dir, exist_ok=True)

with open(file_path, 'r', encoding='utf-8') as f:
    text = f.read()

# Remove unused variable
text = text.replace('final count = state.ingredients.length;', '')

def extract_method(method_name, text):
    # Match Widget method_name(...) { ... }
    pattern = re.compile(r'Widget\s+' + method_name + r'\s*\([^)]*\)\s*\{', re.DOTALL)
    match = pattern.search(text)
    if not match:
        print(f"Could not find {method_name}")
        return "", text
    
    start_idx = match.start()
    
    brace_count = 0
    in_string = False
    string_char = ''
    i = match.end() - 1 # starts at '{'
    
    while i < len(text):
        if text[i] in ("'", '"') and (i == 0 or text[i-1] != '\\'):
            if not in_string:
                in_string = True
                string_char = text[i]
            elif string_char == text[i]:
                in_string = False
        
        if not in_string:
            if text[i] == '{':
                brace_count += 1
            elif text[i] == '}':
                brace_count -= 1
                if brace_count == 0:
                    end_idx = i + 1
                    method_content = text[start_idx:end_idx]
                    remaining = text[:start_idx] + text[end_idx:]
                    return method_content, remaining
        i += 1
    return "", text

# 1. PantryErrorView
code_error, text = extract_method('_buildError', text)
body_error = re.search(r'\{\s*(return.*?)\s*\}$', code_error, re.DOTALL).group(1)
body_error = body_error.replace('onPressed: () {', 'onPressed: onRetry, // {')
# To handle simple replacement, we just use onRetry
body_error = re.sub(r'onPressed:\s*\(\)\s*\{\s*context.read<PantryBloc>\(\)\.add\(const RefreshPantry\(\)\);\s*\},', 'onPressed: onRetry,', body_error)
widget_error = f"""import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';

class PantryErrorView extends StatelessWidget {{
  const PantryErrorView({{super.key, required this.message, required this.onRetry}});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {{
    {body_error}
  }}
}}
"""
with open(os.path.join(widget_dir, 'pantry_error_view.dart'), 'w') as f: f.write(widget_error)
text = text.replace('_buildError(context, state.message)', 'PantryErrorView(message: state.message, onRetry: () => context.read<PantryBloc>().add(const RefreshPantry()))')

# 2. PantryPromoCard
code_promo, text = extract_method('_buildPromoCard', text)
body_promo = re.search(r'\{\s*(return.*?)\s*\}$', code_error, re.DOTALL)
if body_promo: body_promo = body_promo.group(1)
else:
    body_promo = re.search(r'\{\s*(return.*?)\s*\}$', code_promo, re.DOTALL).group(1)
widget_promo = f"""import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';

class PantryPromoCard extends StatelessWidget {{
  const PantryPromoCard({{super.key}});

  @override
  Widget build(BuildContext context) {{
    {body_promo}
  }}
}}
"""
with open(os.path.join(widget_dir, 'pantry_promo_card.dart'), 'w') as f: f.write(widget_promo)
text = text.replace('_buildPromoCard(context, state)', 'const PantryPromoCard()')

# 3. PantryQuickActions
code_qa, text = extract_method('_buildQuickActions', text)
body_qa = re.search(r'\{\s*(return.*?)\s*\}$', code_qa, re.DOTALL).group(1)
widget_qa = f"""import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'pantry_quick_action_card.dart';

class PantryQuickActions extends StatelessWidget {{
  const PantryQuickActions({{super.key}});

  @override
  Widget build(BuildContext context) {{
    {body_qa}
  }}
}}
"""
with open(os.path.join(widget_dir, 'pantry_quick_actions.dart'), 'w') as f: f.write(widget_qa)
text = text.replace('_buildQuickActions(context)', 'const PantryQuickActions()')

# 4. PantryExpiryBanner
code_eb, text = extract_method('_buildExpiryBanner', text)
body_eb = re.search(r'\{\s*(return.*?)\s*\}$', code_eb, re.DOTALL).group(1)
body_eb = body_eb.replace('state.expiringSoon', 'expiring')
widget_eb = f"""import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/features/pantry/data/models/ingredient_model.dart';
import 'pantry_expiry_item.dart';

class PantryExpiryBanner extends StatelessWidget {{
  const PantryExpiryBanner({{super.key, required this.expiring}});
  final List<IngredientModel> expiring;

  @override
  Widget build(BuildContext context) {{
    {body_eb}
  }}
}}
"""
with open(os.path.join(widget_dir, 'pantry_expiry_banner.dart'), 'w') as f: f.write(widget_eb)
text = text.replace('_buildExpiryBanner(state)', 'PantryExpiryBanner(expiring: state.expiringSoon)')

# 5. PantrySearchBar
code_sb, text = extract_method('_buildSearchBar', text)
body_sb = re.search(r'\{\s*(return.*?)\s*\}$', code_sb, re.DOTALL).group(1)
body_sb = body_sb.replace('_searchController', 'controller')
body_sb = body_sb.replace('_searchQuery', 'searchQuery')
body_sb = re.sub(r'onChanged:\s*\(v\)\s*\{\s*setState\(\(\)\s*=>\s*_searchQuery\s*=\s*v\);\s*\},', 'onChanged: onChanged,', body_sb)
body_sb = re.sub(r'onTap:\s*\(\)\s*\{\s*controller\.clear\(\);\s*setState\(\(\)\s*=>\s*searchQuery\s*=\s*\'\'\);\s*\},', 'onTap: onClear,', body_sb)

widget_sb = f"""import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';

class PantrySearchBar extends StatelessWidget {{
  const PantrySearchBar({{
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
  }});
  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {{
    {body_sb}
  }}
}}
"""
with open(os.path.join(widget_dir, 'pantry_search_bar.dart'), 'w') as f: f.write(widget_sb)

search_bar_replacement = """PantrySearchBar(
  controller: _searchController,
  searchQuery: _searchQuery,
  onChanged: (v) => setState(() => _searchQuery = v),
  onClear: () {
    _searchController.clear();
    setState(() => _searchQuery = '');
  },
)"""
text = text.replace('_buildSearchBar()', search_bar_replacement)


# 6. PantryFilterChips
code_fc, text = extract_method('_buildFilterChips', text)
body_fc = re.search(r'\{\s*(return.*?)\s*\}$', code_fc, re.DOTALL).group(1)
body_fc = body_fc.replace("state.selectedFilter == 'all'", "selectedFilter == 'all'")
body_fc = body_fc.replace("state.selectedFilter == 'expiring'", "selectedFilter == 'expiring'")
body_fc = body_fc.replace("state.selectedFilter == 'low_stock'", "selectedFilter == 'low_stock'")

body_fc = re.sub(r"onTap:\s*\(\)\s*=>\s*context\.read<PantryBloc>\(\)\.add\((.*?)\),", r"onTap: () => onFilterSelected(\1),", body_fc)
body_fc = body_fc.replace("const FilterPantry('all')", "'all'")
body_fc = body_fc.replace("const FilterPantry('expiring')", "'expiring'")
body_fc = body_fc.replace("const FilterPantry('low_stock')", "'low_stock'")


widget_fc = f"""import 'package:flutter/material.dart' hide FilterChip;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'pantry_filter_chip.dart';

class PantryFilterChips extends StatelessWidget {{
  const PantryFilterChips({{super.key, required this.selectedFilter, required this.onFilterSelected}});
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  @override
  Widget build(BuildContext context) {{
    {body_fc}
  }}
}}
"""
with open(os.path.join(widget_dir, 'pantry_filter_chips.dart'), 'w') as f: f.write(widget_fc)

fc_replacement = """PantryFilterChips(
  selectedFilter: state.selectedFilter,
  onFilterSelected: (filter) => context.read<PantryBloc>().add(FilterPantry(filter)),
)"""
text = text.replace('_buildFilterChips(context, state)', fc_replacement)


# 7. PantryEmptyState
code_es, text = extract_method('_buildEmptyState', text)
body_es = re.search(r'\{\s*(return.*?)\s*\}$', code_es, re.DOTALL).group(1)

body_es = re.sub(r'if \(!isFiltered\) \.\.\.\[.*?\] else \.\.\.\[.*?\]', '', body_es, flags=re.DOTALL) 

# Instead of complex regex for body_es, let's just let flutter compile the exact body or we reconstruct it.
# The user provided exact replacement logic for _buildEmptyState in pantry_screen.dart, but the widget itself is easier to just dump.
# The logic for EmptyState varies on `isFiltered`, so we should replace the condition `(state.selectedFilter != 'all' || _searchQuery.isNotEmpty)` with `isFiltered`.
body_es = body_es.replace("state.selectedFilter != 'all' || _searchQuery.isNotEmpty", "isFiltered")
body_es = re.sub(r'onPressed:\s*\(\)\s*\{\s*if\s*\(isFiltered\).*?else.*?\}\s*\)', 'onPressed: onActionPressed)', body_es, flags=re.DOTALL)

# Since regex replace for onPressed might fail on complex blocks, we will manually replace the `FilledButton( onPressed: ..., child: ... )`
# Actually, I'll use a python script to just output the raw extracted string and run `sed` or flutter formatting.

widget_es = f"""import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class PantryEmptyState extends StatelessWidget {{
  const PantryEmptyState({{super.key, required this.isFiltered, required this.onActionPressed}});
  final bool isFiltered;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {{
    {body_es}
  }}
}}
"""
with open(os.path.join(widget_dir, 'pantry_empty_state.dart'), 'w') as f: f.write(widget_es)

es_replacement = """PantryEmptyState(
  isFiltered: state.selectedFilter != 'all' || _searchQuery.isNotEmpty,
  onActionPressed: (state.selectedFilter != 'all' || _searchQuery.isNotEmpty)
      ? () {
          _searchController.clear();
          setState(() => _searchQuery = '');
          context.read<PantryBloc>().add(const FilterPantry('all'));
        }
      : () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddIngredientScreen(),
          ).then((_) {
            if (context.mounted) {
              context.read<PantryBloc>().add(const RefreshPantry());
            }
          }),
)"""
text = text.replace('_buildEmptyState(context, state)', es_replacement)

# ADD IMPORTS TO MAIN FILE
new_imports = '''import '../widgets/pantry_error_view.dart';
import '../widgets/pantry_promo_card.dart';
import '../widgets/pantry_quick_actions.dart';
import '../widgets/pantry_expiry_banner.dart';
import '../widgets/pantry_search_bar.dart';
import '../widgets/pantry_filter_chips.dart';
import '../widgets/pantry_empty_state.dart';
'''
lines = text.split('\n')
last_import_idx = 0
for i, line in enumerate(lines):
    if line.startswith('import '):
        last_import_idx = i
lines.insert(last_import_idx + 1, new_imports)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines))

print("Extraction script completed.")
