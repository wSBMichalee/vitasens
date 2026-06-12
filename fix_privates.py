import os
import re

dir_path = 'lib/features/auth/presentation/screens/onboarding/'
main_file = 'lib/features/auth/presentation/screens/user_onboarding_screen.dart'

files = [os.path.join(dir_path, f) for f in os.listdir(dir_path) if f.endswith('.dart')]
files.append(main_file)

replacements = [
    r'_Step',
    r'_Heading',
    r'_Subtitle',
    r'_CtaButton',
    r'_OptionCard',
    r'_InfoRow',
    r'_UnitTab',
    r'_ReviewCard',
    r'_SummaryRow',
    r'_AnimatedListItem'
]

for file_path in files:
    with open(file_path, 'r') as f:
        content = f.read()
    
    for r in replacements:
        # replace e.g. _Step with Step
        target = r[1:] # remove underscore
        content = re.sub(r'\b' + r + r'\b', target, content)
        
    with open(file_path, 'w') as f:
        f.write(content)

# Fix imports in home_screen_content.dart
home_content_path = 'lib/features/macros/presentation/screens/home_screen_content.dart'
with open(home_content_path, 'r') as f:
    hc = f.read()

missing_imports = [
    "import 'package:vitasense/features/water/bloc/water_bloc.dart';",
    "import 'package:vitasense/features/water/bloc/water_event.dart';",
    "import 'package:vitasense/core/widgets/gradient_scaffold.dart';",
    "import 'package:vitasense/core/widgets/app_header.dart';"
]
hc = '\n'.join(missing_imports) + '\n' + hc

with open(home_content_path, 'w') as f:
    f.write(hc)

print("Fixed private classes and mockup imports")
