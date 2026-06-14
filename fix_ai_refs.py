import os
for path in ['lib/features/recipes/presentation/widgets/ai_meals/recipe_card.dart', 'lib/features/recipes/presentation/widgets/ai_meals/filter_bottom_sheet.dart']:
    with open(path, 'r') as f:
        text = f.read()
    
    if path.endswith('filter_bottom_sheet.dart'):
        imports = """import 'package:flutter_bloc/flutter_bloc.dart';\nimport 'package:vitasense/features/recipes/bloc/recipes_bloc.dart';\nimport 'package:vitasense/features/recipes/bloc/recipes_event.dart';\nimport 'package:vitasense/features/recipes/bloc/recipes_state.dart';\n"""
        text = imports + text
        
    text = text.replace('_NutriBadge', 'NutriBadge')
    
    with open(path, 'w') as f:
        f.write(text)
