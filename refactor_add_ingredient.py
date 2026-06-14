import os
import re

source_file = 'lib/features/pantry/presentation/screens/add_ingredient_screen.dart'
dest_folder = 'lib/features/pantry/presentation/widgets/add_ingredient/'
models_folder = 'lib/features/pantry/data/models/'
os.makedirs(dest_folder, exist_ok=True)
os.makedirs(models_folder, exist_ok=True)

with open(source_file, 'r', encoding='utf-8') as f:
    content = f.read()

def extract_block(pattern_str, text):
    pattern = re.compile(pattern_str)
    match = pattern.search(text)
    if not match:
        return None, text
    
    start_idx = match.start()
    brace_start = text.find('{', start_idx)
    brace_count = 0
    in_block = False
    end_idx = -1
    
    for i in range(brace_start, len(text)):
        if text[i] == '{':
            brace_count += 1
            in_block = True
        elif text[i] == '}':
            brace_count -= 1
            if in_block and brace_count == 0:
                end_idx = i + 1
                break
                
    if end_idx != -1:
        extracted = text[start_idx:end_idx]
        remaining = text[:start_idx] + text[end_idx:]
        return extracted, remaining
    return None, text

# Extract ProductItem
product_item_class, content = extract_block(r'class\s+ProductItem\b', content)
if product_item_class:
    with open(os.path.join(models_folder, 'product_item.dart'), 'w', encoding='utf-8') as f:
        f.write(product_item_class + '\n')

# Extract methods
fallback_method, content = extract_block(r'Widget\s+_buildFallbackImage\s*\(.*?\)', content)
shimmer_method, content = extract_block(r'Widget\s+_buildLoadingShimmer\s*\(\)', content)
grid_method, content = extract_block(r'Widget\s+_buildCategoryGrid\s*\(\)', content)
results_method, content = extract_block(r'Widget\s+_buildResultsList\s*\(\)', content)
expiry_method, content = extract_block(r'Widget\s+_buildExpiryChip\s*\(.*?\)', content)

# Extract categories
cat_match = re.search(r'(?:static\s+)?const\s+List<Map<String,\s*String>>\s+_categoriesGrid\s*=\s*\[.*?\];', content, re.DOTALL)
categories_code = ""
if cat_match:
    categories_code = cat_match.group(0).replace('_categoriesGrid', 'categories')
    content = content[:cat_match.start()] + content[cat_match.end():]

# Write fallback_image_widget.dart
with open(os.path.join(dest_folder, 'fallback_image_widget.dart'), 'w', encoding='utf-8') as f:
    f.write("""import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FallbackImageWidget extends StatelessWidget {
  const FallbackImageWidget({super.key, required this.emoji, this.size = 56});
  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
""" + fallback_method[fallback_method.find('{')+1:fallback_method.rfind('}')].replace('56.r', 'size.r') + """
  }
}
""")

# Write loading_shimmer_list.dart
with open(os.path.join(dest_folder, 'loading_shimmer_list.dart'), 'w', encoding='utf-8') as f:
    f.write("""import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmerList extends StatelessWidget {
  const LoadingShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
""" + shimmer_method[shimmer_method.find('{')+1:shimmer_method.rfind('}')] + """
  }
}
""")

# Write category_grid_widget.dart
grid_body = grid_method[grid_method.find('{')+1:grid_method.rfind('}')].replace('_categoriesGrid', 'categories')
grid_body = re.sub(r'onTap:\s*\(\)\s*\{[^}]*\}', "onTap: () => onCategoryTap(cat['query']!),", grid_body)

with open(os.path.join(dest_folder, 'category_grid_widget.dart'), 'w', encoding='utf-8') as f:
    f.write("""import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryGridWidget extends StatelessWidget {
  const CategoryGridWidget({super.key, required this.onCategoryTap});
  final ValueChanged<String> onCategoryTap;

  """ + categories_code + """

  @override
  Widget build(BuildContext context) {
""" + grid_body + """
  }
}
""")

# Write search_results_list.dart
results_body = results_method[results_method.find('{')+1:results_method.rfind('}')].replace('_searchResults', 'items')
results_body = results_body.replace('_buildFallbackImage(item.categoryEmoji)', 'FallbackImageWidget(emoji: item.categoryEmoji)')
results_body = re.sub(r'onTap:\s*\(\)\s*\{.*?setState\(\(\)\s*\{.*?\}\);\s*\},?', 'onTap: () => onItemTap(item),', results_body, flags=re.DOTALL)

with open(os.path.join(dest_folder, 'search_results_list.dart'), 'w', encoding='utf-8') as f:
    f.write("""import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'fallback_image_widget.dart';
import '../../../data/models/product_item.dart';

class SearchResultsList extends StatelessWidget {
  const SearchResultsList({super.key, required this.items, required this.onItemTap});
  final List<ProductItem> items;
  final ValueChanged<ProductItem> onItemTap;

  @override
  Widget build(BuildContext context) {
""" + results_body + """
  }
}
""")

# Write expiry_chip.dart
expiry_body = expiry_method[expiry_method.find('{')+1:expiry_method.rfind('}')]
expiry_body = re.sub(r'onTap:\s*\(\)\s*async\s*\{.*?\}\s*,', 'onTap: onTap,', expiry_body, flags=re.DOTALL)
expiry_body = re.sub(r'final\s+isSelected\s*=\s*_selectedExpiry\s*==\s*label;', '', expiry_body)

with open(os.path.join(dest_folder, 'expiry_chip.dart'), 'w', encoding='utf-8') as f:
    f.write("""import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class ExpiryChip extends StatelessWidget {
  const ExpiryChip({super.key, required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
""" + expiry_body + """
  }
}
""")

# Replace calls in main file
content = content.replace('_buildCategoryGrid()', '''CategoryGridWidget(onCategoryTap: (query) {
                        _searchController.text = query;
                        _onSearchChanged(query);
                      })''')

content = content.replace('_buildLoadingShimmer()', 'const LoadingShimmerList()')

content = content.replace('_buildResultsList()', '''SearchResultsList(
                        items: _searchResults,
                        onItemTap: (item) {
                          setState(() {
                            _selectedName = item.brandName != null ? '${item.brandName} ${item.name}' : item.name;
                            _selectedImageUrl = item.imageUrl;
                            _selectedCategoryLabel = item.categoryLabel;
                            _resolveCategoryAndUnit(item.categoryLabel);
                          });
                        },
                      )''')

content = re.sub(r'_buildFallbackImage\((.*?)\)', r'FallbackImageWidget(emoji: \1)', content)

content = re.sub(r'_buildExpiryChip\((.*?)\)', r'''ExpiryChip(
                                  label: \1,
                                  isSelected: _selectedExpiry == \1,
                                  onTap: () async {
                                    if (\1 == 'Custom') {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now().add(const Duration(days: 3)),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(const Duration(days: 365)),
                                      );
                                      if (date != null) {
                                        setState(() {
                                          _selectedExpiry = 'Custom';
                                          _customExpiry = date;
                                        });
                                      }
                                    } else {
                                      setState(() => _selectedExpiry = \1);
                                    }
                                  },
                                )''', content)

# Add imports
imports = """import '../../../data/models/product_item.dart';
import '../widgets/add_ingredient/fallback_image_widget.dart';
import '../widgets/add_ingredient/loading_shimmer_list.dart';
import '../widgets/add_ingredient/category_grid_widget.dart';
import '../widgets/add_ingredient/search_results_list.dart';
import '../widgets/add_ingredient/expiry_chip.dart';
"""
import_match = list(re.finditer(r'^import\s+.*$', content, re.MULTILINE))
if import_match:
    last_import = import_match[-1]
    insert_pos = last_import.end() + 1
    content = content[:insert_pos] + "\n" + imports + "\n" + content[insert_pos:]
else:
    content = imports + "\n" + content

with open(source_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("Refactor add ingredient completed")
