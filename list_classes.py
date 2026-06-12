import re

filepath = 'lib/features/showcase/presentation/screens/vitasense_mockup_screens.dart'
with open(filepath, 'r') as f:
    lines = f.readlines()

classes = []
for line in lines:
    match = re.match(r'^(?:abstract\s+)?class\s+([A-Za-z0-9_]+)', line)
    if match:
        classes.append(match.group(1))

print("Classes found:")
for c in classes:
    print(c)
