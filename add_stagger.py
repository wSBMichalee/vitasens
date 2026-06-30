import os
import glob
import re

directory = 'lib/features/auth/presentation/screens/onboarding'

files = glob.glob(f"{directory}/*.dart")

for file_path in files:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content

    # Zastąpienie toList(), przez z animacją.
    # Używamy wyrażenia regularnego, aby znaleźć ".toList()," które jest częścią children:
    # np. `children: options.map((e) => OptionCard(...)).toList(),`
    
    # Also find GridView or Wrap where children are mapped.
    # Wzorzec szuka: `options.map(...).toList()` bez opcjonalnego przecinka na końcu i podmienia
    
    content = re.sub(r'(\.toList\(\))(,?)', r'\1.animate(interval: 60.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad)\2', content)

    # Some map usages might not have flutter_animate imported
    if content != original_content and "flutter_animate.dart" not in content:
        content = "import 'package:flutter_animate/flutter_animate.dart';\n" + content
    
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {file_path}")
