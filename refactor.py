import os
import re

COLORS_MAP = {
    "Color(0xFF111827)": "AppColors.textPrimary",
    "Color(0xFF22C55E)": "AppColors.primary",
    "Color(0xFF6B7280)": "AppColors.textSecondary",
    "Color(0xFF9CA3AF)": "AppColors.textMuted",
    "Color(0xFFFFFFFF)": "AppColors.backgroundWhite",
    "Color(0xFFF5F5F5)": "AppColors.background",
    "Color(0xFF1F2937)": "AppColors.backgroundDark",
    "Color(0xFFE5E7EB)": "AppColors.border",
    "Color(0xFF3B82F6)": "AppColors.secondary",
    "Color(0xFFEF4444)": "AppColors.error",
    "Color(0xFFF59E0B)": "AppColors.warning",
    "Color(0xFFF97316)": "AppColors.fatColor",
    "Color(0xFFDCFCE7)": "AppColors.primaryLight",
    "Color(0xFFEFF6FF)": "AppColors.secondaryLight",
    "Color(0xFFFEE2E2)": "AppColors.errorLight",
    "Color(0xFFFFF7ED)": "AppColors.warningLight"
}

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content

    for old, new in COLORS_MAP.items():
        content = content.replace(old, new)
        content = content.replace(f"const {new}", new)

    content = re.sub(r'fontSize:\s*(\d+(?:\.\d+)?)(?!\.sp|\.h|\.w|\.r)', r'fontSize: \1.sp', content)
    content = re.sub(r'width:\s*(\d+(?:\.\d+)?)(?!\.w|\.h|\.r|\.sp)', r'width: \1.w', content)
    
    def replace_height(m):
        val = float(m.group(1))
        if val > 5:
            return f"height: {m.group(1)}.h"
        return m.group(0)
    
    content = re.sub(r'height:\s*(\d+(?:\.\d+)?)(?!\.h|\.w|\.r|\.sp)', replace_height, content)
    content = re.sub(r'EdgeInsets\.all\(\s*(\d+(?:\.\d+)?)\s*(?!\.r|\.w|\.h|\.sp)\)', r'EdgeInsets.all(\1.r)', content)
    
    def replace_symmetric(m):
        inner = m.group(1)
        inner = re.sub(r'horizontal:\s*(\d+(?:\.\d+)?)(?!\.w|\.h|\.r|\.sp)', r'horizontal: \1.w', inner)
        inner = re.sub(r'vertical:\s*(\d+(?:\.\d+)?)(?!\.h|\.w|\.r|\.sp)', r'vertical: \1.h', inner)
        return f"EdgeInsets.symmetric({inner})"
    content = re.sub(r'EdgeInsets\.symmetric\((.*?)\)', replace_symmetric, content)
    
    content = re.sub(r'BorderRadius\.circular\(\s*(\d+(?:\.\d+)?)\s*(?!\.r|\.w|\.h|\.sp)\)', r'BorderRadius.circular(\1.r)', content)
    content = re.sub(r'size:\s*(\d+(?:\.\d+)?)(?!\.r|\.w|\.h|\.sp)', r'size: \1.r', content)
    content = re.sub(r'radius:\s*(\d+(?:\.\d+)?)(?!\.r|\.w|\.h|\.sp)', r'radius: \1.r', content)

    if content != original:
        imports_to_add = []
        if 'AppColors' in content and 'package:vitasense/core/theme/app_colors.dart' not in content:
            imports_to_add.append("import 'package:vitasense/core/theme/app_colors.dart';")
        if ('.sp' in content or '.w' in content or '.h' in content or '.r' in content) and 'package:flutter_screenutil/flutter_screenutil.dart' not in content:
            imports_to_add.append("import 'package:flutter_screenutil/flutter_screenutil.dart';")
        
        if imports_to_add:
            lines = content.split('\n')
            last_import_idx = 0
            for i, line in enumerate(lines):
                if line.startswith('import '):
                    last_import_idx = i
            
            for imp in imports_to_add:
                lines.insert(last_import_idx + 1, imp)
            content = '\n'.join(lines)
            
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

for root, dirs, files in os.walk('lib/features'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
