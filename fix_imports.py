import os

files_to_fix = {
    'lib/features/macros/presentation/screens/home_screen_content.dart': [
        "import 'package:vitasense/features/macros/bloc/daily_log_bloc.dart';",
        "import 'package:vitasense/features/macros/bloc/daily_log_event.dart';",
        "import 'package:vitasense/features/macros/bloc/daily_log_state.dart';",
        "import 'package:vitasense/features/macros/data/models/meal_model.dart';",
        "import 'package:vitasense/core/router/app_router.dart';",
        "import 'package:intl/intl.dart';",
        "import 'package:vitasense/features/macros/presentation/widgets/macro_progress_bar.dart';"
    ],
    'lib/features/showcase/presentation/screens/problem_fatigue_screen.dart': [
        "import 'package:cached_network_image/cached_network_image.dart';",
        "import 'package:vitasense/core/router/app_router.dart';"
    ],
    'lib/features/showcase/presentation/screens/feature_matcher_screen.dart': [
        "import 'package:cached_network_image/cached_network_image.dart';",
        "import 'package:vitasense/core/router/app_router.dart';"
    ],
    'lib/features/showcase/presentation/screens/results_analysis_screen.dart': [
        "import 'package:vitasense/core/router/app_router.dart';",
        "import 'dart:math' as math;"
    ]
}

for path, imports in files_to_fix.items():
    if os.path.exists(path):
        with open(path, 'r') as f:
            content = f.read()
        new_content = '\n'.join(imports) + '\n' + content
        with open(path, 'w') as f:
            f.write(new_content)

