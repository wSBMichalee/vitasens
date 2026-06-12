import os
import re

def parse_dart_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Match class definitions and capture everything up to the balanced closing brace.
    # This might be tricky with regex, so let's do a brace counting approach.
    
    classes = {}
    imports = []
    other_code = []
    
    lines = content.split('\n')
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

    return imports, other_code, classes

filepath = 'lib/features/auth/presentation/screens/user_onboarding_screen.dart'
imports, other_code, classes = parse_dart_file(filepath)

# Mapping requested by user
mapping = {
    'onboarding_shared_widgets.dart': ['_Heading', '_Subtitle', '_CtaButton', '_OptionCard', '_InfoRow', '_UnitTab', '_ReviewCard', '_SummaryRow', '_AnimatedListItem'],
    'onboarding_step1_intro.dart': ['_Step1', '_Step2'],
    'onboarding_step3_gender.dart': ['_Step3'],
    'onboarding_step4_height.dart': ['_Step4'],
    'onboarding_step5_weight.dart': ['_Step5'],
    'onboarding_step6_age.dart': ['_Step6'],
    'onboarding_step7_summary.dart': ['_Step7'],
    'onboarding_step8_goal.dart': ['_Step8', '_Step8b'],
    'onboarding_step9_target.dart': ['_Step9'],
    'onboarding_step10_activity.dart': ['_Step10', '_Step10b', '_Step10bState'],
    'onboarding_step11_diet.dart': ['_Step11'],
    'onboarding_step12_allergies.dart': ['_Step12', '_Step12State'],
    'onboarding_step13_health.dart': ['_Step13', '_Step13b'],
    'onboarding_step14_kitchen.dart': ['_Step14'],
    'onboarding_step15_cooking.dart': ['_Step15'],
    'onboarding_step16_pace.dart': ['_Step16', '_Step16b'],
    'onboarding_step17_social.dart': ['_Step17'],
    'onboarding_step18_notifications.dart': ['_Step18'],
    'onboarding_step19_rating.dart': ['_Step19', '_Step19b'],
    'onboarding_step20_loading.dart': ['_Step20', '_Step20State', '_Step20b', '_Step20bState'],
    'onboarding_step21_projection.dart': ['_Step21'],
    'onboarding_step22_paywall.dart': ['_Step22', '_Step22State']
}

out_dir = 'lib/features/auth/presentation/screens/onboarding/'
os.makedirs(out_dir, exist_ok=True)

# Generate new files
base_imports = "\n".join([
    "import 'package:flutter/cupertino.dart';",
    "import 'package:flutter/material.dart';",
    "import 'package:flutter_animate/flutter_animate.dart';",
    "import 'package:flutter_screenutil/flutter_screenutil.dart';",
    "import 'package:vitasense/core/theme/app_colors.dart';",
    "import 'package:vitasense/features/auth/presentation/screens/onboarding/onboarding_shared_widgets.dart';",
    "import 'dart:math';",
])

for filename, class_names in mapping.items():
    file_content = [base_imports]
    if filename == 'onboarding_shared_widgets.dart':
        # Remove the self import
        file_content[0] = file_content[0].replace("import 'package:vitasense/features/auth/presentation/screens/onboarding/onboarding_shared_widgets.dart';\n", "")
        
    for c in class_names:
        if c in classes:
            file_content.append(classes[c])
        else:
            print(f"WARNING: Class {c} not found!")
            
    with open(os.path.join(out_dir, filename), 'w') as f:
        f.write('\n\n'.join(file_content))

# Generate main file
main_content = []
for imp in imports:
    main_content.append(imp)
for filename in mapping.keys():
    main_content.append(f"import 'onboarding/{filename}';")

for line in other_code:
    if line.strip() != "":
        main_content.append(line)

main_content.append(classes['UserOnboardingScreen'])
main_content.append(classes['_UserOnboardingScreenState'])

with open(filepath, 'w') as f:
    f.write('\n'.join(main_content))

print("Onboarding refactor complete.")
