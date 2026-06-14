import os
import re

file_path = 'lib/features/macros/presentation/screens/home_screen_content.dart'
widget_dir = 'lib/features/macros/presentation/widgets/home/'

os.makedirs(widget_dir, exist_ok=True)

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

def extract_class(class_name, text):
    pattern = re.compile(rf'^class {class_name}\b.*?^{{', re.MULTILINE | re.DOTALL)
    match = pattern.search(text)
    if not match:
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

# 1. _ProgressCard
progress_card_code, content = extract_class('_ProgressCard', content)
progress_card_code = progress_card_code.replace('_ProgressCard', 'ProgressCard')

# 2. _MacroColumn
macro_column_code, content = extract_class('_MacroColumn', content)
macro_column_code = macro_column_code.replace('_MacroColumn', 'MacroColumn')

# 3. _WeekStrip
week_strip_code, content = extract_class('_WeekStrip', content)
week_strip_code = week_strip_code.replace('_WeekStrip', 'WeekStrip')

# 4. _MealSection & _MealSectionState
meal_section_code, content = extract_class('_MealSection', content)
meal_section_state_code, content = extract_class('_MealSectionState', content)
meal_section_full = meal_section_code + '\n\n' + meal_section_state_code
meal_section_full = meal_section_full.replace('_MealSectionState', 'MealSectionState').replace('_MealSection', 'MealSection')

# 5. _MacroSummaryBar & _MacroBarItem
macro_summary_bar_code, content = extract_class('_MacroSummaryBar', content)
macro_bar_item_code, content = extract_class('_MacroBarItem', content)
macro_summary_full = macro_summary_bar_code + '\n\n' + macro_bar_item_code
macro_summary_full = macro_summary_full.replace('_MacroSummaryBar', 'MacroSummaryBar').replace('_MacroBarItem', 'MacroBarItem')

base_imports = '''import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
'''

with open(os.path.join(widget_dir, 'progress_card.dart'), 'w', encoding='utf-8') as f:
    f.write(base_imports + '\n' + progress_card_code)

with open(os.path.join(widget_dir, 'macro_column.dart'), 'w', encoding='utf-8') as f:
    f.write(base_imports + '\n' + macro_column_code)

with open(os.path.join(widget_dir, 'week_strip.dart'), 'w', encoding='utf-8') as f:
    f.write(base_imports + "import 'package:intl/intl.dart';\n\n" + week_strip_code)

with open(os.path.join(widget_dir, 'meal_section.dart'), 'w', encoding='utf-8') as f:
    f.write(base_imports + "import 'package:vitasense/features/meals/data/models/meal_model.dart';\n\n" + meal_section_full)

with open(os.path.join(widget_dir, 'macro_summary_bar.dart'), 'w', encoding='utf-8') as f:
    f.write(base_imports + '\n' + macro_summary_full)

# Replace remaining class usages in the original content
content = content.replace('_ProgressCard', 'ProgressCard')
content = content.replace('_MacroColumn', 'MacroColumn')
content = content.replace('_WeekStrip', 'WeekStrip')
content = content.replace('_MealSection', 'MealSection')
content = content.replace('_MacroSummaryBar', 'MacroSummaryBar')
content = content.replace('_MacroBarItem', 'MacroBarItem')

new_imports = '''import '../widgets/home/progress_card.dart';
import '../widgets/home/macro_column.dart';
import '../widgets/home/week_strip.dart';
import '../widgets/home/meal_section.dart';
import '../widgets/home/macro_summary_bar.dart';
'''

# insert new imports right after the last import line
lines = content.split('\\n')
last_import_idx = 0
for i, line in enumerate(lines):
    if line.startswith('import '):
        last_import_idx = i

lines.insert(last_import_idx + 1, new_imports)
content = '\\n'.join(lines)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Split script completed successfully.")
