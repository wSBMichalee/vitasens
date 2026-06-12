import os
import re

dir_path = 'lib/features/auth/presentation/screens/onboarding/'
main_file = 'lib/features/auth/presentation/screens/user_onboarding_screen.dart'

files = [os.path.join(dir_path, f) for f in os.listdir(dir_path) if f.endswith('.dart')]
files.append(main_file)

for file_path in files:
    with open(file_path, 'r') as f:
        content = f.read()
    
    content = re.sub(r'_Step(\d+[a-z]?)', r'Step\1', content)
    content = re.sub(r'_Heading', r'Heading', content)
    content = re.sub(r'_Subtitle', r'Subtitle', content)
    content = re.sub(r'_CtaButton', r'CtaButton', content)
    content = re.sub(r'_OptionCard', r'OptionCard', content)
    content = re.sub(r'_InfoRow', r'InfoRow', content)
    content = re.sub(r'_UnitTab', r'UnitTab', content)
    content = re.sub(r'_ReviewCard', r'ReviewCard', content)
    content = re.sub(r'_SummaryRow', r'SummaryRow', content)
    content = re.sub(r'_AnimatedListItem', r'AnimatedListItem', content)
        
    with open(file_path, 'w') as f:
        f.write(content)

# home_screen_content.dart missing imports
# let's remove the bad ones
home_content_path = 'lib/features/macros/presentation/screens/home_screen_content.dart'
with open(home_content_path, 'r') as f:
    content = f.read()

content = content.replace("import 'package:vitasense/features/meals/data/meal_item_model.dart';", "")
content = content.replace("import 'package:vitasense/features/macros/presentation/widgets/macro_progress_bar.dart';", "")

with open(home_content_path, 'w') as f:
    f.write(content)

