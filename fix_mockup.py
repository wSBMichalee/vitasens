import os
import re

filepath = 'lib/features/showcase/presentation/screens/vitasense_mockup_screens.dart'
with open(filepath, 'r') as f:
    content = f.read()

# Replace _NavyButton with NavyButton everywhere so it can be exported or just duplicated.
# Actually, the user did not say to create a shared file. So I'll just rename them to be public and put them in problem_fatigue_screen.dart, then feature_matcher_screen.dart can import it.
content = re.sub(r'\b_NavyButton\b', 'NavyButton', content)
content = re.sub(r'\b_StepDots\b', 'StepDots', content)
content = re.sub(r'\b_WhiteLabel\b', 'WhiteLabel', content)
content = re.sub(r'\b_FeatureLine\b', 'FeatureLine', content)
content = re.sub(r'\b_CircleIconButton\b', 'CircleIconButton', content)

lines = content.split('\n')
classes = {}
imports = []
other_code = []

current_class = None
class_lines = []
brace_count = 0
in_class = False

for line in lines:
    if not in_class:
        if line.startswith('import '):
            imports.append(line)
        else:
            match = re.match(r'^(?:abstract\s+)?class\s+([A-Za-z0-9_]+)\s*(?:extends|implements|with|{)', line)
            if match:
                in_class = True
                current_class = match.group(1)
                class_lines = [line]
                brace_count = line.count('{') - line.count('}')
                if brace_count == 0 and '{' in line:
                    classes[current_class] = '\n'.join(class_lines)
                    in_class = False
                    current_class = None
            else:
                other_code.append(line)
    else:
        class_lines.append(line)
        brace_count += line.count('{') - line.count('}')
        if brace_count <= 0:
            classes[current_class] = '\n'.join(class_lines)
            in_class = False
            current_class = None

mapping = {
    'lib/features/macros/presentation/screens/home_screen_content.dart': [
        'MockupHomeScreen', '_MockupHomeScreenState', '_ProgressCard', '_MacroColumn', 
        '_WeekStrip', '_MealSection', '_MealSectionState', '_MacroSummaryBar', '_MacroBarItem'
    ],
    'lib/features/showcase/presentation/screens/problem_fatigue_screen.dart': [
        'ProblemFatigueScreen', 'StepDots', 'NavyButton', 'CircleIconButton'
    ],
    'lib/features/showcase/presentation/screens/feature_matcher_screen.dart': [
        'FeatureMatcherScreen', 'WhiteLabel', 'FeatureLine'
    ],
    'lib/features/showcase/presentation/screens/results_analysis_screen.dart': [
        'ResultsAnalysisScreen', '_ResultsAnalysisScreenState', '_AnalysisStep', '_AnalysisRingPainter'
    ]
}

base_imports = "\n".join([
    "import 'package:flutter/material.dart';",
    "import 'package:flutter_screenutil/flutter_screenutil.dart';",
    "import 'package:go_router/go_router.dart';",
    "import 'package:vitasense/core/theme/app_colors.dart';",
    "import 'package:flutter_bloc/flutter_bloc.dart';",
    "import 'package:vitasense/features/auth/bloc/auth_bloc.dart';",
    "import 'package:vitasense/features/auth/data/models/user_model.dart';",
    "import 'package:vitasense/features/water/presentation/widgets/water_card.dart';",
    "import 'package:vitasense/features/showcase/presentation/screens/problem_fatigue_screen.dart';"
])

for filepath_out, class_names in mapping.items():
    file_content = [base_imports]
    for c in class_names:
        if c in classes:
            file_content.append(classes[c])
        else:
            print(f"WARNING: Class {c} not found!")
    with open(filepath_out, 'w') as f:
        f.write('\n\n'.join(file_content))

# update app_router.dart
router_path = 'lib/core/router/app_router.dart'
with open(router_path, 'r') as f:
    router_content = f.read()

router_content = router_content.replace(
    "import 'package:vitasense/features/showcase/presentation/screens/vitasense_mockup_screens.dart';",
    """import 'package:vitasense/features/showcase/presentation/screens/problem_fatigue_screen.dart';
import 'package:vitasense/features/showcase/presentation/screens/feature_matcher_screen.dart';
import 'package:vitasense/features/showcase/presentation/screens/results_analysis_screen.dart';"""
)
with open(router_path, 'w') as f:
    f.write(router_content)

# update home_screen.dart
home_path = 'lib/features/macros/presentation/screens/home_screen.dart'
with open(home_path, 'r') as f:
    home_content = f.read()

home_content = home_content.replace(
    "import 'package:vitasense/features/showcase/presentation/screens/vitasense_mockup_screens.dart';",
    "import 'package:vitasense/features/macros/presentation/screens/home_screen_content.dart';"
)
with open(home_path, 'w') as f:
    f.write(home_content)

os.remove(filepath)

print("Mockup refactor complete.")
