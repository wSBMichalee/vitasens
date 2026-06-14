import re

file_path = 'lib/features/macros/presentation/screens/home_screen_content.dart'
with open(file_path, 'r') as f:
    text = f.read()

# Remove specific trailing imports
text = re.sub(r'import \'../widgets/home/.*?\';\n?', '', text)

# Insert after last import
lines = text.split('\n')
last_import_idx = 0
for i, line in enumerate(lines):
    if line.startswith('import '):
        last_import_idx = i

imports = """import '../widgets/home/progress_card.dart';
import '../widgets/home/macro_column.dart';
import '../widgets/home/week_strip.dart';
import '../widgets/home/meal_section.dart';
import '../widgets/home/macro_summary_bar.dart';"""

lines.insert(last_import_idx + 1, imports)
with open(file_path, 'w') as f:
    f.write('\n'.join(lines))

ms_path = 'lib/features/macros/presentation/widgets/home/meal_section.dart'
with open(ms_path, 'r') as f:
    ms_text = f.read()

new_imports = """import 'package:vitasense/features/meals/data/meal_model.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/features/meals/bloc/daily_log_bloc.dart';
import 'package:vitasense/features/meals/bloc/daily_log_event.dart';"""

ms_text = ms_text.replace("import 'package:vitasense/features/meals/data/models/meal_model.dart';", new_imports)

with open(ms_path, 'w') as f:
    f.write(ms_text)
