import re
import os

# 1. CREATE pantry_emoji_helper.dart
helper_code = """import 'package:flutter/material.dart';

String emojiForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'fruits':
    case 'fruit':
      return '🍎';
    case 'protein':
      return '🥩';
    case 'vegetables':
    case 'vegetable':
      return '🥦';
    case 'dairy':
      return '🥛';
    case 'grains':
    case 'grain':
      return '🌾';
    default:
      return '🛒';
  }
}

Color colorForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'fruits':
    case 'fruit':
      return const Color(0xFFFFF3E0);
    case 'protein':
      return const Color(0xFFFFEBEE);
    case 'vegetables':
    case 'vegetable':
      return const Color(0xFFE8F5E9);
    case 'dairy':
      return const Color(0xFFE3F2FD);
    case 'grains':
    case 'grain':
      return const Color(0xFFFFF8E1);
    default:
      return const Color(0xFFF5F5F5);
  }
}

String emojiForName(String name) {
  final n = name.toLowerCase();
  if (n.contains('kiwi')) return '🥝';
  if (n.contains('banana')) return '🍌';
  if (n.contains('apple') || n.contains('jabłko')) return '🍎';
  if (n.contains('orange') || n.contains('pomarańcz')) return '🍊';
  if (n.contains('lemon') || n.contains('cytryna')) return '🍋';
  if (n.contains('strawberr') || n.contains('truskaw')) return '🍓';
  if (n.contains('grape') || n.contains('winogron')) return '🍇';
  if (n.contains('mango')) return '🥭';
  if (n.contains('pineapple') || n.contains('ananas')) return '🍍';
  if (n.contains('watermelon') || n.contains('arbuz')) return '🍉';
  if (n.contains('pear') || n.contains('gruszka')) return '🍐';
  if (n.contains('peach') || n.contains('brzoskwin')) return '🍑';
  if (n.contains('cherry') || n.contains('wiśni') || n.contains('czereśni')) return '🍒';
  if (n.contains('mixed fruit') || n.contains('fruit mix')) return '🍓';
  if (n.contains('avocado') || n.contains('awokado')) return '🥑';
  if (n.contains('carrot') || n.contains('marchew')) return '🥕';
  if (n.contains('broccoli') || n.contains('brokuł')) return '🥦';
  if (n.contains('tomato') || n.contains('pomidor')) return '🍅';
  if (n.contains('potato') || n.contains('ziemniak')) return '🥔';
  if (n.contains('milk') || n.contains('mleko')) return '🥛';
  if (n.contains('cheese') || n.contains('ser')) return '🧀';
  if (n.contains('egg') || n.contains('jajk')) return '🥚';
  if (n.contains('bread') || n.contains('chleb')) return '🍞';
  if (n.contains('chicken') || n.contains('kurczak')) return '🍗';
  return '';
}
"""

with open('lib/features/pantry/presentation/widgets/pantry_emoji_helper.dart', 'w') as f:
    f.write(helper_code)


# 2. UPDATE pantry_ingredient_card.dart
card_path = 'lib/features/pantry/presentation/widgets/pantry_ingredient_card.dart'
with open(card_path, 'r') as f:
    card = f.read()

# Add import
lines = card.split('\n')
for i, line in enumerate(lines):
    if line.startswith('import '):
        last_import = i
lines.insert(last_import + 1, "import 'pantry_emoji_helper.dart';")
card = '\n'.join(lines)

# Remove methods
start_idx = card.find('  String _emojiForCategory(String category) {')
end_idx = card.find('  Widget _buildPlaceholder() {')
if start_idx != -1 and end_idx != -1:
    card = card[:start_idx] + card[end_idx:]

# Replace calls
card = card.replace('_emojiForCategory', 'emojiForCategory')
card = card.replace('_colorForCategory', 'colorForCategory')
card = card.replace('_emojiForName', 'emojiForName')

with open(card_path, 'w') as f:
    f.write(card)


# 3. UPDATE pantry_expiry_item.dart
exp_path = 'lib/features/pantry/presentation/widgets/pantry_expiry_item.dart'
with open(exp_path, 'r') as f:
    exp = f.read()

# Add import
lines = exp.split('\n')
for i, line in enumerate(lines):
    if line.startswith('import '):
        last_import = i
lines.insert(last_import + 1, "import 'pantry_emoji_helper.dart';")
exp = '\n'.join(lines)

# Remove map
map_start = exp.find('  static const Map<String, String> _categoryImages = {')
map_end = exp.find('  };', map_start) + 4
if map_start != -1:
    exp = exp[:map_start] + exp[map_end:]

# Replace logic in build
old_build_start = exp.find('    final imageUrl = _categoryImages[ingredient.category.toLowerCase()];')
old_build_end = exp.find('    return Container(')
new_build_vars = """    final nameEmoji = emojiForName(ingredient.name);
    final emoji = nameEmoji.isNotEmpty ? nameEmoji : emojiForCategory(ingredient.category);
    final bgColor = colorForCategory(ingredient.category);

    Widget placeholder() => Container(
      color: bgColor,
      alignment: Alignment.center,
      child: Text(emoji, style: TextStyle(fontSize: 22.r)),
    );

"""
exp = exp[:old_build_start] + new_build_vars + exp[old_build_end:]

# Replace SizedBox child
old_sizedbox = """              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: AppColors.border,
                        highlightColor: AppColors.borderLight,
                        child: Container(color: AppColors.border),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.warningLight,
                        child: Icon(Icons.eco, color: AppColors.warning, size: 20.r),
                      ),
                    )
                  : Container(
                      color: AppColors.warningLight,
                      child: Icon(Icons.eco, color: AppColors.warning, size: 20.r),
                    ),"""

new_sizedbox = """              child: (ingredient.imageUrl != null && ingredient.imageUrl!.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: ingredient.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: AppColors.border,
                        highlightColor: AppColors.borderLight,
                        child: Container(color: AppColors.border),
                      ),
                      errorWidget: (_, __, ___) => placeholder(),
                    )
                  : placeholder(),"""

exp = exp.replace(old_sizedbox, new_sizedbox)

with open(exp_path, 'w') as f:
    f.write(exp)

print("Emoji helper applied successfully")
