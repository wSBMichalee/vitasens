import re

filepath = 'lib/features/showcase/presentation/screens/vitasense_mockup_screens.dart'
with open(filepath, 'r') as f:
    content = f.read()

# Define the classes
classes = [
    'MockupAiMealsScreen', 'MockupHomeScreen', '_MockupHomeScreenState', 
    'ProblemFatigueScreen', 'FeatureMatcherScreen', 'ResultsAnalysisScreen', 
    '_ResultsAnalysisScreenState', '_ProgressCard', '_MacroColumn', '_PillFilter', 
    '_IngredientToken', '_GreenBadge', '_MetaIcon', '_CircleIconButton', 
    '_StepDots', '_NavyButton', '_WhiteLabel', '_FeatureLine', 
    '_AnalysisStep', '_AnalysisRingPainter', '_WeekStrip', '_MacroSummaryBar', 
    '_MacroBarItem', '_MealSection', '_MealSectionState'
]

# Extract class bodies roughly to find usages
class_bodies = {}
for c in classes:
    # simple extraction from "class C" to the next "class" or end of file
    start_idx = content.find(f'class {c}')
    if start_idx == -1: continue
    
    # find next class
    next_idx = len(content)
    for other in classes:
        if other == c: continue
        idx = content.find(f'class {other}')
        if idx > start_idx and idx < next_idx:
            next_idx = idx
            
    class_bodies[c] = content[start_idx:next_idx]

for c in classes:
    if c.startswith('_'):
        # find where it's used
        used_in = []
        for other_c, body in class_bodies.items():
            if other_c != c and c in body:
                used_in.append(other_c)
        print(f"{c} is used in: {used_in}")

