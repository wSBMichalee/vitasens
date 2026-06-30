import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  int updatedFiles = 0;
  for (var file in files) {
    if (file.path == 'lib/core/utils/snackbar_utils.dart') continue;
    String content = file.readAsStringSync();
    if (!content.contains('ScaffoldMessenger')) continue;

    bool changed = false;
    
    // Common error pattern 1
    final errorRegex1 = RegExp(r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*SnackBar\(\s*content:\s*Text\(([^)]+)\),\s*backgroundColor:\s*(AppColors\.error|Colors\.red),\s*\),\s*\);", multiLine: true);
    content = content.replaceAllMapped(errorRegex1, (m) {
      changed = true;
      return "SnackbarUtils.showError(context, ${m[1]});";
    });

    // Common error pattern 2 (with const)
    final errorRegex2 = RegExp(r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*const\s*SnackBar\(\s*content:\s*Text\(([^)]+)\),\s*backgroundColor:\s*(AppColors\.error|Colors\.red),\s*\),\s*\);", multiLine: true);
    content = content.replaceAllMapped(errorRegex2, (m) {
      changed = true;
      return "SnackbarUtils.showError(context, ${m[1]});";
    });

    // Common error pattern 3 (with behavior floating)
    final errorRegex3 = RegExp(r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*SnackBar\(\s*content:\s*Text\(([^)]+)\),\s*backgroundColor:\s*AppColors\.error,\s*behavior:\s*SnackBarBehavior\.floating,\s*\),\s*\);", multiLine: true);
    content = content.replaceAllMapped(errorRegex3, (m) {
      changed = true;
      return "SnackbarUtils.showError(context, ${m[1]}, behavior: SnackBarBehavior.floating);";
    });

    final errorRegex3c = RegExp(r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*const\s*SnackBar\(\s*content:\s*Text\(([^)]+)\),\s*backgroundColor:\s*AppColors\.error,\s*behavior:\s*SnackBarBehavior\.floating,\s*\),\s*\);", multiLine: true);
    content = content.replaceAllMapped(errorRegex3c, (m) {
      changed = true;
      return "SnackbarUtils.showError(context, ${m[1]}, behavior: SnackBarBehavior.floating);";
    });

    // Success pattern 1 (with const)
    final successRegex1 = RegExp(r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*const\s*SnackBar\(\s*content:\s*Text\(([^)]+)\),\s*backgroundColor:\s*AppColors\.primary,\s*\),\s*\);", multiLine: true);
    content = content.replaceAllMapped(successRegex1, (m) {
      changed = true;
      return "SnackbarUtils.showSuccess(context, ${m[1]});";
    });

    // Success pattern 2
    final successRegex2 = RegExp(r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*SnackBar\(\s*content:\s*Text\(([^)]+)\),\s*backgroundColor:\s*AppColors\.primary,\s*\),\s*\);", multiLine: true);
    content = content.replaceAllMapped(successRegex2, (m) {
      changed = true;
      return "SnackbarUtils.showSuccess(context, ${m[1]});";
    });

    if (changed) {
      // add import if missing
      if (!content.contains('package:vitasense/core/utils/snackbar_utils.dart')) {
        content = "import 'package:vitasense/core/utils/snackbar_utils.dart';\n" + content;
      }
      file.writeAsStringSync(content);
      updatedFiles++;
    }
  }
  print('Updated $updatedFiles files.');
}
