import os
import re

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

# Task 1
t1_file = 'lib/features/recipes/presentation/screens/create_recipe_screen.dart'
t1_dir = 'lib/features/recipes/presentation/widgets/'
os.makedirs(t1_dir, exist_ok=True)

with open(t1_file, 'r', encoding='utf-8') as f:
    text1 = f.read()

code, text1 = extract_class('_MyRecipeCard', text1)
code = code.replace('_MyRecipeCard', 'MyRecipeCard')

t1_imports = """import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/features/recipes/data/models/recipe_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/features/recipes/bloc/recipes_bloc.dart';
import 'package:vitasense/features/recipes/bloc/recipes_event.dart';
import 'package:vitasense/core/router/app_router.dart';
"""
with open(os.path.join(t1_dir, 'my_recipe_card.dart'), 'w', encoding='utf-8') as f:
    f.write(t1_imports + '\n' + code)

text1 = text1.replace('_MyRecipeCard', 'MyRecipeCard')

lines = text1.split('\n')
for i, line in enumerate(lines):
    if line.startswith('import '):
        last_import_idx = i
lines.insert(last_import_idx + 1, "import '../widgets/my_recipe_card.dart';")
with open(t1_file, 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines))


# Task 2
t2_file = 'lib/features/extract/presentation/screens/extract_screen.dart'
t2_dir = 'lib/features/extract/presentation/widgets/'
os.makedirs(t2_dir, exist_ok=True)

with open(t2_file, 'r', encoding='utf-8') as f:
    text2 = f.read()

code1, text2 = extract_class('_LoadingView', text2)
code1 = code1.replace('_LoadingView', 'LoadingView')
code2, text2 = extract_class('_LoadingViewState', text2)
code2 = code2.replace('_LoadingViewState', 'LoadingViewState').replace('<_LoadingView>', '<LoadingView>')

t2_imports = """import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';
"""
with open(os.path.join(t2_dir, 'loading_view.dart'), 'w', encoding='utf-8') as f:
    f.write(t2_imports + '\n' + code1 + '\n\n' + code2)

text2 = text2.replace('_LoadingView', 'LoadingView')

lines = text2.split('\n')
last_import_idx = 0
for i, line in enumerate(lines):
    if line.startswith('import '):
        last_import_idx = i
lines.insert(last_import_idx + 1, "import '../widgets/loading_view.dart';")
with open(t2_file, 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines))

print("Split script tasks completed.")
