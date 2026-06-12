import os

files_to_fix = {
    'lib/features/auth/presentation/screens/onboarding/onboarding_step20_loading.dart': [
        "import 'dart:async';"
    ],
    'lib/features/auth/presentation/screens/onboarding/onboarding_step18_notifications.dart': [
        "import 'package:permission_handler/permission_handler.dart';"
    ]
}

for path, imports in files_to_fix.items():
    if os.path.exists(path):
        with open(path, 'r') as f:
            content = f.read()
        new_content = '\n'.join(imports) + '\n' + content
        with open(path, 'w') as f:
            f.write(new_content)

