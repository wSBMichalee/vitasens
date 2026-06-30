import os
import re

path = 'lib/features/recipes/presentation/widgets/ai_meals/filter_bottom_sheet.dart'
try:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    content = content.replace(
        "onTap: () => context.read<RecipesBloc>().add(",
        "onTap: () {\n                        HapticFeedback.selectionClick();\n                        context.read<RecipesBloc>().add("
    )
    content = content.replace(
        ")),",
        "));\n                      },"
    ) # This could break a lot of things. Let's not use string replace like this.
except:
    pass
