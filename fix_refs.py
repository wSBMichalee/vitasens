import os
for path in ['lib/features/macros/presentation/widgets/home/progress_card.dart', 'lib/features/macros/presentation/widgets/home/macro_summary_bar.dart']:
    with open(path, 'r') as f:
        text = f.read()
    text = text.replace('_MacroColumn', 'MacroColumn').replace('_MacroBarItem', 'MacroBarItem')
    if path == 'lib/features/macros/presentation/widgets/home/progress_card.dart':
        text = "import 'macro_column.dart';\n" + text
    with open(path, 'w') as f:
        f.write(text)
