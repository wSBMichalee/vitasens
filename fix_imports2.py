import os

path = 'lib/features/macros/presentation/screens/home_screen_content.dart'
with open(path, 'r') as f:
    content = f.read()

content = content.replace("import 'package:vitasense/features/macros/bloc/daily_log_bloc.dart';", "import 'package:vitasense/features/meals/bloc/daily_log_bloc.dart';")
content = content.replace("import 'package:vitasense/features/macros/bloc/daily_log_event.dart';", "import 'package:vitasense/features/meals/bloc/daily_log_event.dart';")
content = content.replace("import 'package:vitasense/features/macros/bloc/daily_log_state.dart';", "import 'package:vitasense/features/meals/bloc/daily_log_state.dart';")
content = content.replace("import 'package:vitasense/features/macros/data/models/meal_model.dart';", "import 'package:vitasense/features/meals/data/meal_model.dart';\nimport 'package:vitasense/features/meals/data/meal_item_model.dart';")

with open(path, 'w') as f:
    f.write(content)

