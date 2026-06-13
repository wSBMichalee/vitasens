import os
import re

source_file = 'lib/features/auth/presentation/screens/profile_screen.dart'
dest_dir = 'lib/features/auth/presentation/widgets/profile/'
os.makedirs(dest_dir, exist_ok=True)

file_mapping = {
    'profile_daily_targets_card.dart': ['_DailyTargetsCard', '_DailyTargetsCardState', '_PremiumMacroTile'],
    'profile_goals_card.dart': ['_MyGoalsCard', '_GoalRow', '_EditGoalSheet', '_EditGoalSheetState', '_SaveButton'],
    'profile_menu_card.dart': ['_MenuCard', '_MenuItem', '_MenuRow', '_SubscriptionCard'],
    'profile_personal_info_card.dart': ['_PersonalInfoCard', '_TagsRow', '_EditTagsSheet', '_EditTagsSheetState'],
    'profile_hero_banner.dart': ['_ProfileSliverAppBar', '_HeroBanner'],
    'profile_shimmer.dart': ['_ProfileShimmer', '_SettingsMenuCard', '_Card']
}

base_imports = """import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/features/auth/bloc/auth_bloc.dart';
import 'package:vitasense/features/auth/bloc/auth_event.dart';
import 'package:vitasense/features/auth/data/models/user_model.dart';
import 'package:vitasense/features/subscription/bloc/subscription_bloc.dart';
import 'package:vitasense/features/subscription/bloc/subscription_state.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
"""

with open(source_file, 'r') as f:
    content = f.read()

def extract_class(class_name, content):
    pattern = r'(class\s+' + class_name + r'\b[^\{]*\{)'
    match = re.search(pattern, content)
    if not match:
        return "", content
    start_idx = match.start()
    
    brace_count = 0
    in_class = False
    for i in range(start_idx, len(content)):
        if content[i] == '{':
            brace_count += 1
            in_class = True
        elif content[i] == '}':
            brace_count -= 1
        
        if in_class and brace_count == 0:
            end_idx = i + 1
            extracted = content[start_idx:end_idx]
            remaining = content[:start_idx] + content[end_idx:]
            return extracted, remaining
    return "", content

extracted_classes = {}
all_classes_to_extract = [cls for group in file_mapping.values() for cls in group]

for cls in all_classes_to_extract:
    ext, content = extract_class(cls, content)
    extracted_classes[cls] = ext

for cls in all_classes_to_extract:
    new_name = cls[1:] if cls != '_Card' else 'ProfileShimmerCard'
    content = re.sub(r'\b' + cls + r'\b', new_name, content)
    for k in extracted_classes:
        extracted_classes[k] = re.sub(r'\b' + cls + r'\b', new_name, extracted_classes[k])

for filename, classes in file_mapping.items():
    file_content = base_imports + "\n"
    for cls in classes:
        file_content += extracted_classes[cls] + "\n\n"
    
    with open(os.path.join(dest_dir, filename), 'w') as f:
        f.write(file_content)

imports = ""
for filename in file_mapping.keys():
    imports += f"import '../widgets/profile/{filename}';\n"

last_import_idx = content.rfind("import '")
if last_import_idx != -1:
    end_of_line = content.find("\n", last_import_idx)
    content = content[:end_of_line+1] + imports + "\n" + content[end_of_line+1:]
else:
    content = imports + "\n" + content

with open(source_file, 'w') as f:
    f.write(content)

