import re

source_file = 'lib/features/auth/presentation/screens/profile_screen.dart'
dest_file = 'lib/features/auth/presentation/widgets/profile/profile_hero_banner.dart'

with open(source_file, 'r') as f:
    content = f.read()

# Extract GoogleFontsSafeStyle
pattern = r'(abstract class GoogleFontsSafeStyle \{[\s\S]*?\n\})'
match = re.search(pattern, content)
if match:
    google_fonts_style = match.group(1)
    content = content.replace(google_fonts_style, '')
    with open(source_file, 'w') as f:
        f.write(content)
        
    with open(dest_file, 'a') as f:
        f.write("\n" + google_fonts_style + "\n")

