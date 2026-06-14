import os
import re

file_path = 'lib/features/browse/presentation/screens/browse_screen.dart'
widget_dir = 'lib/features/browse/presentation/widgets/'
os.makedirs(widget_dir, exist_ok=True)

with open(file_path, 'r', encoding='utf-8') as f:
    text = f.read()

def extract_class(class_name, text):
    pattern = re.compile(r'class\s+' + class_name + r'\b.*?\{', re.DOTALL)
    match = pattern.search(text)
    if not match:
        print(f"Could not find {class_name}")
        return "", text
    
    start_idx = match.start()
    
    brace_count = 0
    in_string = False
    string_char = ''
    i = start_idx
    
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
                    class_content = text[start_idx:end_idx]
                    remaining = text[:start_idx] + text[end_idx:]
                    return class_content, remaining
        i += 1
    return "", text

classes = [
    ('_CuisineChip', 'CuisineChip', 'cuisine_chip.dart', []),
    ('_SortChip', 'SortChip', 'sort_chip.dart', []),
    ('_FeaturedCard', 'FeaturedCard', 'featured_card.dart', [
        "import 'package:cached_network_image/cached_network_image.dart';",
        "import 'package:shimmer/shimmer.dart';",
        "import 'package:go_router/go_router.dart';",
        "import 'package:vitasense/core/router/app_router.dart';"
    ]),
    ('_RecipeGridCard', 'RecipeGridCard', 'recipe_grid_card.dart', [
        "import 'package:cached_network_image/cached_network_image.dart';",
        "import 'package:shimmer/shimmer.dart';",
        "import 'package:go_router/go_router.dart';",
        "import 'package:vitasense/core/router/app_router.dart';"
    ])
]

file_contents = {}

for old_name, new_name, filename, extra_imports in classes:
    code, text = extract_class(old_name, text)
    code = code.replace(old_name, new_name)
    
    if filename not in file_contents:
        file_contents[filename] = {
            'code': [],
            'imports': extra_imports
        }
    else:
        file_contents[filename]['imports'].extend(extra_imports)
        
    file_contents[filename]['code'].append(code)

base_imports = '''import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
'''

for filename, data in file_contents.items():
    unique_imports = list(dict.fromkeys(data['imports']))
    all_imports = base_imports + '\n'.join(unique_imports) + '\n\n'
    full_code = all_imports + '\n\n'.join(data['code'])
    with open(os.path.join(widget_dir, filename), 'w', encoding='utf-8') as f:
        f.write(full_code)

text = text.replace('_CuisineChip', 'CuisineChip')
text = text.replace('_SortChip', 'SortChip')
text = text.replace('_FeaturedCard', 'FeaturedCard')
text = text.replace('_RecipeGridCard', 'RecipeGridCard')

new_imports = '''import '../widgets/cuisine_chip.dart';
import '../widgets/sort_chip.dart';
import '../widgets/featured_card.dart';
import '../widgets/recipe_grid_card.dart';'''

lines = text.split('\n')
last_import_idx = 0
for i, line in enumerate(lines):
    if line.startswith('import '):
        last_import_idx = i

lines.insert(last_import_idx + 1, new_imports)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines))

print("Split script completed.")
