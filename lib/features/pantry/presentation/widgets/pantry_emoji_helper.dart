import 'package:flutter/material.dart';

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
