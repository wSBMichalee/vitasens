import os
import re

# 1. pantry_event.dart
event_file = 'lib/features/pantry/bloc/pantry_event.dart'
with open(event_file, 'r', encoding='utf-8') as f:
    event_content = f.read()

event_content = event_content.replace(
'''class AddIngredient extends PantryEvent {
  final String name;
  final double quantity;
  final String unit;
  final String? category;
  final DateTime? expiryDate;

  const AddIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
    this.category,
    this.expiryDate,
  });

  @override
  List<Object?> get props => [name, quantity, unit, category, expiryDate];
}''',
'''class AddIngredient extends PantryEvent {
  final String name;
  final double quantity;
  final String unit;
  final String? category;
  final DateTime? expiryDate;
  final String? imageUrl;

  const AddIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
    this.category,
    this.expiryDate,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [name, quantity, unit, category, expiryDate, imageUrl];
}'''
)
with open(event_file, 'w', encoding='utf-8') as f:
    f.write(event_content)

# 2. add_ingredient_screen.dart
screen_file = 'lib/features/pantry/presentation/screens/add_ingredient_screen.dart'
with open(screen_file, 'r', encoding='utf-8') as f:
    screen_content = f.read()

screen_content = re.sub(
r'''void _resolveCategoryAndUnit\(String categoryLabel\) \{.*?\}''',
'''void _resolveCategoryAndUnit(String categoryLabel) {
    final catLower = categoryLabel.toLowerCase();
    if (catLower.contains('owoce')) {
      _category = 'fruits';
      _unit = 'szt';
      _quantity = 1;
    } else if (catLower.contains('warzywa')) {
      _category = 'vegetables';
      _unit = 'szt';
      _quantity = 1;
    } else if (catLower.contains('nabiał') || catLower.contains('napoje')) {
      _category = 'dairy';
      _unit = 'ml';
      _quantity = 100;
    } else {
      _category = 'other';
      _unit = 'g';
      _quantity = 100;
    }
  }''',
screen_content, flags=re.DOTALL
)

screen_content = re.sub(
r'''void _addIngredient\(\) \{.*?\}''',
'''void _addIngredient() {
    context.read<PantryBloc>().add(
          AddIngredient(
            name: _selectedName,
            quantity: _quantity,
            unit: _unit,
            category: _category ?? 'other',
            expiryDate: _calculateExpiry(),
            imageUrl: _selectedImageUrl,
          ),
        );
  }''',
screen_content, flags=re.DOTALL
)

with open(screen_file, 'w', encoding='utf-8') as f:
    f.write(screen_content)


# 3. pantry_bloc.dart
bloc_file = 'lib/features/pantry/bloc/pantry_bloc.dart'
with open(bloc_file, 'r', encoding='utf-8') as f:
    bloc_content = f.read()

bloc_content = bloc_content.replace(
'''      await repository.addIngredient(
        pantryId: 'default', // Temporary default
        name: event.name,
        quantity: event.quantity,
        unit: event.unit,
        category: event.category,
        expiryDate: event.expiryDate,
      );''',
'''      await repository.addIngredient(
        pantryId: 'default', // Temporary default
        name: event.name,
        quantity: event.quantity,
        unit: event.unit,
        category: event.category,
        expiryDate: event.expiryDate,
        imageUrl: event.imageUrl,
      );'''
)
with open(bloc_file, 'w', encoding='utf-8') as f:
    f.write(bloc_content)


# 4. pantry_repository.dart
repo_file = 'lib/features/pantry/data/pantry_repository.dart'
with open(repo_file, 'r', encoding='utf-8') as f:
    repo_content = f.read()

repo_content = re.sub(
r'''Future<void> addIngredient\(\{.*?\}\)\s*async\s*\{.*?CacheService\(\)\.invalidate\('pantry_ingredients'\);\n  \}''',
'''Future<void> addIngredient({
    required String pantryId,
    required String name,
    required double quantity,
    required String unit,
    String? category,
    DateTime? expiryDate,
    String? imageUrl,
  }) async {
    await _supabase.functions.invoke(
      'manage-pantry',
      body: {
        'action': 'add',
        'pantry_id': pantryId,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'category': category,
        if (expiryDate != null) 'expiry_date': expiryDate.toIso8601String(),
        if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
      },
    );
    CacheService().invalidate('pantry_ingredients');
  }''',
repo_content, flags=re.DOTALL
)
with open(repo_file, 'w', encoding='utf-8') as f:
    f.write(repo_content)


# 5. validators.ts
val_file = 'supabase/functions/_shared/validators.ts'
with open(val_file, 'r', encoding='utf-8') as f:
    val_content = f.read()

val_content = val_content.replace(
'''  minimumQuantity: z.number().min(0).default(0),
  expiryDate: z.string().datetime().optional()
});''',
'''  minimumQuantity: z.number().min(0).default(0),
  expiryDate: z.string().datetime().optional(),
  imageUrl: z.string().url().optional(),
});'''
)
with open(val_file, 'w', encoding='utf-8') as f:
    f.write(val_content)


# 6. PantryRepository.ts
ts_repo_file = 'supabase/functions/manage-pantry/PantryRepository.ts'
with open(ts_repo_file, 'r', encoding='utf-8') as f:
    ts_repo_content = f.read()

ts_repo_content = ts_repo_content.replace(
'''export interface AddIngredientDTO {
  pantryId: string;
  name: string;
  quantity: number;
  unit: string;
  category: string;
  minimumQuantity?: number;
  expiryDate?: string;
}''',
'''export interface AddIngredientDTO {
  pantryId: string;
  name: string;
  quantity: number;
  unit: string;
  category: string;
  minimumQuantity?: number;
  expiryDate?: string;
  imageUrl?: string;
}'''
)

ts_repo_content = ts_repo_content.replace(
'''        minimum_quantity: data.minimumQuantity ?? 0,
        expiry_date: data.expiryDate ?? null,
      })''',
'''        minimum_quantity: data.minimumQuantity ?? 0,
        expiry_date: data.expiryDate ?? null,
        image_url: data.imageUrl ?? null,
      })'''
)

with open(ts_repo_file, 'w', encoding='utf-8') as f:
    f.write(ts_repo_content)


# 7. pantry_ingredient_card.dart
card_file = 'lib/features/pantry/presentation/widgets/pantry_ingredient_card.dart'
with open(card_file, 'r', encoding='utf-8') as f:
    card_content = f.read()

card_content = card_content.replace(
'''  String _emojiForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'protein':''',
'''  String _emojiForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
      case 'fruit':
        return '🍎';
      case 'protein':'''
)

card_content = card_content.replace(
'''  Color _colorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'protein':''',
'''  Color _colorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
      case 'fruit':
        return const Color(0xFFFFF3E0);
      case 'protein':'''
)

emoji_method = '''  String _emojiForName(String name) {
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

'''

card_content = re.sub(r'  Widget _buildPlaceholder\(\) \{', emoji_method + r'  Widget _buildPlaceholder() {', card_content)

card_content = card_content.replace(
'''  Widget _buildPlaceholder() {
    return Container(
      color: _colorForCategory(ingredient.category),
      alignment: Alignment.center,
      child: Text(
        _emojiForCategory(ingredient.category),
        style: TextStyle(fontSize: 36.r),
      ),
    );
  }''',
'''  Widget _buildPlaceholder() {
    final nameEmoji = _emojiForName(ingredient.name);
    final emoji = nameEmoji.isNotEmpty ? nameEmoji : _emojiForCategory(ingredient.category);

    return Container(
      color: _colorForCategory(ingredient.category),
      alignment: Alignment.center,
      child: Text(
        emoji,
        style: TextStyle(fontSize: 36.r),
      ),
    );
  }'''
)

card_content = re.sub(
r'''\s*final imgUrl = 'https://source\.unsplash\.com/[^']+';''',
'',
card_content
)

card_content = card_content.replace(
'''                    child: CachedNetworkImage(
                      imageUrl: imgUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: AppColors.borderLight,
                        highlightColor: AppColors.border,
                        child: Container(color: AppColors.borderLight),
                      ),
                      errorWidget: (_, __, ___) => _buildPlaceholder(),
                    ),''',
'''                    child: (ingredient.imageUrl != null && ingredient.imageUrl!.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: ingredient.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Shimmer.fromColors(
                              baseColor: AppColors.borderLight,
                              highlightColor: AppColors.border,
                              child: Container(color: AppColors.borderLight),
                            ),
                            errorWidget: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),'''
)

card_content = card_content.replace('direction: DismissDirection.up,', 'direction: DismissDirection.endToStart,')

with open(card_file, 'w', encoding='utf-8') as f:
    f.write(card_content)

print("Apply pantry fixes completed")
