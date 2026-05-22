
import os
import re

def fix_const(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content

    # Remove const before widget constructors and lists
    content = re.sub(r'\bconst\s+([A-Z]\w*(?:\.[a-z]\w*)?\()', r'\1', content)
    content = re.sub(r'\bconst\s+\[', r'[', content)
    
    # Just in case, remove const before AppColors if any was missed
    content = re.sub(r'\bconst\s+AppColors', r'AppColors', content)
    
    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

for root, dirs, files in os.walk('lib/features'):
    for file in files:
        if file.endswith('.dart'):
            fix_const(os.path.join(root, file))
