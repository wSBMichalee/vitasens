import os
path = 'lib/features/browse/presentation/widgets/sort_chip.dart'
with open(path, 'r') as f:
    text = f.read()

imports = """import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/features/browse/bloc/browse_bloc.dart';
import 'package:vitasense/features/browse/bloc/browse_event.dart';
"""
text = imports + text

with open(path, 'w') as f:
    f.write(text)

# Let's also check cuisine_chip.dart just in case it uses BLoC
path2 = 'lib/features/browse/presentation/widgets/cuisine_chip.dart'
with open(path2, 'r') as f:
    text2 = f.read()
if 'read<BrowseBloc>' in text2 or 'ToggleCuisine' in text2:
    text2 = imports + text2
    with open(path2, 'w') as f:
        f.write(text2)

# Check featured_card and recipe_grid_card for missing RecipeModel
path3 = 'lib/features/browse/presentation/widgets/featured_card.dart'
with open(path3, 'r') as f:
    text3 = f.read()
if 'RecipeModel' in text3:
    text3 = "import 'package:vitasense/features/recipes/data/models/recipe_model.dart';\n" + text3
    with open(path3, 'w') as f:
        f.write(text3)
        
path4 = 'lib/features/browse/presentation/widgets/recipe_grid_card.dart'
with open(path4, 'r') as f:
    text4 = f.read()
if 'RecipeModel' in text4:
    text4 = "import 'package:vitasense/features/recipes/data/models/recipe_model.dart';\n" + text4
    with open(path4, 'w') as f:
        f.write(text4)
