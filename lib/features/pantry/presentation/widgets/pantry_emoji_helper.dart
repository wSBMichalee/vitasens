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
      return '🥗';
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

  // Warzywa
  if (n.contains('papryka') || n.contains('pepper') || n.contains('bell pepper')) return '🫑';
  if (n.contains('onion') || n.contains('cebul')) return '🧅';
  if (n.contains('garlic') || n.contains('czosnek')) return '🧄';
  if (n.contains('cucumber') || n.contains('ogórek') || n.contains('ogorek')) return '🥒';
  if (n.contains('lettuce') || n.contains('salata') || n.contains('sałata')) return '🥬';
  if (n.contains('spinach') || n.contains('szpinak')) return '🥬';
  if (n.contains('zucchini') || n.contains('cukinia')) return '🥒';
  if (n.contains('eggplant') || n.contains('baklazan') || n.contains('bakłażan')) return '🍆';
  if (n.contains('pumpkin') || n.contains('dynia')) return '🎃';
  if (n.contains('mushroom') || n.contains('grzyb') || n.contains('pieczark')) return '🍄';
  if (n.contains('corn') || n.contains('kukurydz')) return '🌽';
  if (n.contains('pepper') && n.contains('chili')) return '🌶️';
  if (n.contains('chili') || n.contains('chilli')) return '🌶️';
  if (n.contains('beet') || n.contains('burak')) return '🟣';
  if (n.contains('radish') || n.contains('rzodkiew')) return '🔴';

  // Mięso i ryby
  if (n.contains('beef') || n.contains('wołow') || n.contains('wolowin')) return '🥩';
  if (n.contains('pork') || n.contains('wieprzow')) return '🥩';
  if (n.contains('turkey') || n.contains('indyk')) return '🍗';
  if (n.contains('fish') || n.contains('ryba') || n.contains('ryby') || n.contains('łosoś') || n.contains('losos') || n.contains('salmon')) return '🐟';
  if (n.contains('shrimp') || n.contains('krewetk')) return '🍤';
  if (n.contains('sausage') || n.contains('kiełbas') || n.contains('kielbas')) return '🌭';
  if (n.contains('bacon') || n.contains('boczek')) return '🥓';

  // Nabiał
  if (n.contains('yogurt') || n.contains('jogurt')) return '🥣';
  if (n.contains('butter') || n.contains('masło') || n.contains('maslo')) return '🧈';
  if (n.contains('cream') || n.contains('śmietan') || n.contains('smietan')) return '🥛';

  // Pieczywo i zboża
  if (n.contains('pasta') || n.contains('makaron')) return '🍝';
  if (n.contains('rice') || n.contains('ryż') || n.contains('ryz')) return '🍚';
  if (n.contains('flour') || n.contains('mąka') || n.contains('maka')) return '🌾';
  if (n.contains('oats') || n.contains('owsian') || n.contains('płatk') || n.contains('platk')) return '🥣';
  if (n.contains('bagel') || n.contains('bułka') || n.contains('bulka')) return '🥯';

  // Inne
  if (n.contains('honey') || n.contains('miód') || n.contains('miod')) return '🍯';
  if (n.contains('chocolate') || n.contains('czekolad')) return '🍫';
  if (n.contains('nuts') || n.contains('orzech')) return '🥜';
  if (n.contains('oil') || n.contains('olej') || n.contains('oliwa')) return '🫒';
  if (n.contains('juice') || n.contains('sok')) return '🧃';
  if (n.contains('water') || n.contains('woda')) return '💧';
  if (n.contains('coffee') || n.contains('kawa')) return '☕';
  if (n.contains('tea') || n.contains('herbata')) return '🍵';

  return '';
}
