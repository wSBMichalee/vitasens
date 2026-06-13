import os
import re

dir_path = 'lib/features/auth/presentation/widgets/profile/'
files = os.listdir(dir_path)

for file in files:
    if not file.endswith('.dart'): continue
    filepath = os.path.join(dir_path, file)
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Remove lucide_icons
    content = re.sub(r"import 'package:lucide_icons/lucide_icons.dart';\n", "", content)
    
    # Add missing imports
    additional_imports = """import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vitasense/features/auth/data/auth_repository.dart';
import 'profile_shimmer.dart';
import 'profile_goals_card.dart';
"""
    
    # Just append them to the top after the first import
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + additional_imports)
    
    with open(filepath, 'w') as f:
        f.write(content)

