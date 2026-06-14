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
    i = match.end() - 1 
    
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

file_path = 'lib/core/router/app_router.dart'
router_dir = 'lib/core/router/'
widgets_dir = 'lib/core/widgets/'
os.makedirs(router_dir, exist_ok=True)
os.makedirs(widgets_dir, exist_ok=True)

with open(file_path, 'r', encoding='utf-8') as f:
    text = f.read()

# 1. AppRoutes
code_routes, text = extract_class('AppRoutes', text)

routes_imports = """import 'package:flutter/foundation.dart';
"""
with open(os.path.join(router_dir, 'app_routes.dart'), 'w', encoding='utf-8') as f:
    f.write(routes_imports + '\n' + code_routes)

# Insert export and import of app_routes at the top imports block
lines = text.split('\n')
last_import_idx = 0
for i, line in enumerate(lines):
    if line.startswith('import '):
        last_import_idx = i
lines.insert(last_import_idx + 1, "export 'app_routes.dart';\nimport 'app_routes.dart';")
text = '\n'.join(lines)


# 2. ScaffoldWithBottomNav
code_sbn, text = extract_class('ScaffoldWithBottomNav', text)
code_sbn_state, text = extract_class('_ScaffoldWithBottomNavState', text)
code_nav_item, text = extract_class('_NavItem', text)

sbn_imports = """import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import '../router/app_routes.dart';
"""

with open(os.path.join(widgets_dir, 'scaffold_with_bottom_nav.dart'), 'w', encoding='utf-8') as f:
    f.write(sbn_imports + '\n' + code_sbn + '\n\n' + code_sbn_state + '\n\n' + code_nav_item)

# 3. PlaceholderScreen
code_ps, text = extract_class('_PlaceholderScreen', text)
code_ps = code_ps.replace('_PlaceholderScreen', 'PlaceholderScreen')

ps_imports = """import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
"""

with open(os.path.join(widgets_dir, 'placeholder_screen.dart'), 'w', encoding='utf-8') as f:
    f.write(ps_imports + '\n' + code_ps)


# Update app_router.dart references
text = text.replace("_PlaceholderScreen(name: \"We've got this!\")", 'PlaceholderScreen(name: "We\'ve got this!")')
text = text.replace("_PlaceholderScreen(name: 'We\\'ve got this!')", "PlaceholderScreen(name: 'We\\'ve got this!')")

lines = text.split('\n')
last_import_idx = 0
for i, line in enumerate(lines):
    if line.startswith('import ') or line.startswith('export '):
        last_import_idx = i
lines.insert(last_import_idx + 1, "import '../widgets/scaffold_with_bottom_nav.dart';\nimport '../widgets/placeholder_screen.dart';")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines))

print("Split script completed.")
