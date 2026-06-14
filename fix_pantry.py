import os
import re

file_path = 'lib/features/pantry/presentation/screens/pantry_screen.dart'
with open(file_path, 'r') as f:
    text = f.read()
text = text.replace("import 'widgets/pantry_", "import '../widgets/pantry_")
with open(file_path, 'w') as f:
    f.write(text)

ev_path = 'lib/features/pantry/presentation/widgets/pantry_error_view.dart'
with open(ev_path, 'r') as f:
    ev_text = f.read()
ev_text = re.sub(r'onPressed:.*?context\.read<PantryBloc>.*?\).*?\},', 'onPressed: onRetry,', ev_text, flags=re.DOTALL)
with open(ev_path, 'w') as f:
    f.write(ev_text)

eb_path = 'lib/features/pantry/presentation/widgets/pantry_expiry_banner.dart'
with open(eb_path, 'r') as f:
    eb_text = f.read()
eb_text = re.sub(r'final expiring\s*=\s*expiring;', '', eb_text)
with open(eb_path, 'w') as f:
    f.write(eb_text)

sb_path = 'lib/features/pantry/presentation/widgets/pantry_search_bar.dart'
with open(sb_path, 'r') as f:
    sb_text = f.read()
sb_text = re.sub(r'onChanged:\s*\(v\)\s*\{\s*setState.*?\).*?\},', 'onChanged: onChanged,', sb_text, flags=re.DOTALL)
sb_text = re.sub(r'onTap:\s*\(\)\s*\{\s*controller\.clear.*?\).*?\},', 'onTap: onClear,', sb_text, flags=re.DOTALL)
with open(sb_path, 'w') as f:
    f.write(sb_text)

fc_path = 'lib/features/pantry/presentation/widgets/pantry_filter_chips.dart'
with open(fc_path, 'r') as f:
    fc_text = f.read()
fc_text = re.sub(r'context\.read<PantryBloc>\(\)\.add\((.*?)\)', r'onFilterSelected(\1)', fc_text)
with open(fc_path, 'w') as f:
    f.write(fc_text)
