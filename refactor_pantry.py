import os
import re

source_file = 'lib/features/pantry/presentation/screens/pantry_screen.dart'
dest_folder = 'lib/features/pantry/presentation/widgets/'
os.makedirs(dest_folder, exist_ok=True)

file_mapping = {
    "pantry_shimmer.dart": ["_ShimmerLayout"],
    "pantry_filter_chip.dart": ["_FilterChip"],
    "pantry_quick_action_card.dart": ["_QuickActionCard"],
    "pantry_expiry_item.dart": ["_ExpiryItem"],
    "pantry_ingredient_card.dart": ["_IngredientCard"]
}

imports = """import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/features/pantry/data/models/ingredient_model.dart';
"""

with open(source_file, 'r', encoding='utf-8') as f:
    content = f.read()

def extract_class(class_name, text):
    pattern = re.compile(r'class\s+' + class_name + r'\b')
    match = pattern.search(text)
    if not match:
        return None, text
    
    start_idx = match.start()
    brace_count = 0
    in_class = False
    end_idx = -1
    
    for i in range(start_idx, len(text)):
        if text[i] == '{':
            brace_count += 1
            in_class = True
        elif text[i] == '}':
            brace_count -= 1
            if in_class and brace_count == 0:
                end_idx = i + 1
                break
                
    if end_idx != -1:
        extracted = text[start_idx:end_idx]
        remaining = text[:start_idx] + text[end_idx:]
        return extracted, remaining
    return None, text

# Extract and write
for dest_file, classes in file_mapping.items():
    file_content = imports + "\n"
    for cls in classes:
        extracted, content = extract_class(cls, content)
        if extracted:
            file_content += extracted + "\n\n"
        else:
            print(f"Warning: Class {cls} not found!")
    
    # Replace names in the new file
    for cls in classes:
        new_name = cls.lstrip('_')
        file_content = re.sub(r'\b' + cls + r'\b', new_name, file_content)
        
    with open(os.path.join(dest_folder, dest_file), 'w', encoding='utf-8') as f:
        f.write(file_content)

# Replace all usages in main file
for classes in file_mapping.values():
    for cls in classes:
        new_name = cls.lstrip('_')
        content = re.sub(r'\b' + cls + r'\b', new_name, content)

# Add imports to main file
import_statements = ""
for dest_file in file_mapping.keys():
    import_statements += f"import '../widgets/{dest_file}';\n"

# insert imports after the last import in main file
import_match = list(re.finditer(r'^import\s+.*$', content, re.MULTILINE))
if import_match:
    last_import = import_match[-1]
    insert_pos = last_import.end() + 1
    content = content[:insert_pos] + "\n" + import_statements + "\n" + content[insert_pos:]
else:
    content = import_statements + "\n" + content

with open(source_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("Refactor completed")
