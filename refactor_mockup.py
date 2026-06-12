import os
import re

filepath = 'lib/features/showcase/presentation/screens/vitasense_mockup_screens.dart'
with open(filepath, 'r') as f:
    content = f.read()

# Parse classes using brace counting
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

# Mapping based on user request and usages
mapping = {
    'lib/features/macros/presentation/screens/home_screen_content.dart': [
        'MockupHomeScreen', '_MockupHomeScreenState', '_ProgressCard', '_MacroColumn', 
        '_WeekStrip', '_MealSection', '_MealSectionState', '_MacroSummaryBar', '_MacroBarItem'
    ],
    'lib/features/showcase/presentation/screens/problem_fatigue_screen.dart': [
        'ProblemFatigueScreen', '_StepDots', '_NavyButton'
    ],
    'lib/features/showcase/presentation/screens/feature_matcher_screen.dart': [
        'FeatureMatcherScreen', '_WhiteLabel', '_FeatureLine'
    ],
    'lib/features/showcase/presentation/screens/results_analysis_screen.dart': [
        'ResultsAnalysisScreen', '_ResultsAnalysisScreenState', '_AnalysisStep', '_AnalysisRingPainter'
    ],
    'lib/features/showcase/presentation/screens/mockup_ai_meals_screen.dart': [
        'MockupAiMealsScreen', '_PillFilter', '_IngredientToken', '_GreenBadge', '_MetaIcon', '_CircleIconButton'
    ]
}

# Wait, _NavyButton is used in FeatureMatcherScreen too. 
# In dart, if a file starts with `_` it's private.
# If _NavyButton is used in FeatureMatcherScreen but placed in problem_fatigue_screen.dart, it won't be accessible!
# The user wants to split the file. The easiest way to share a private class across files is to rename it to remove `_`, or put it in one file and use part/part of, or just copy it into both files. Let's rename it to remove `_` or just put it in a shared file if it's used across? Or since they are small, duplicate it?
# Let's remove `_` from _NavyButton and make it NavyButton. Or just copy it to both since it's a private widget.

