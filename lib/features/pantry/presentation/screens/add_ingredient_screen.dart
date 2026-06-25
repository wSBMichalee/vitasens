import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/services/spoonacular_service.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/pantry/bloc/pantry_bloc.dart';
import 'package:vitasense/features/pantry/bloc/pantry_event.dart';
import 'package:vitasense/features/pantry/bloc/pantry_state.dart';
import 'package:vitasense/features/pantry/data/pantry_repository.dart';

import '../../data/models/product_item.dart';
import '../widgets/add_ingredient/fallback_image_widget.dart';
import '../widgets/add_ingredient/loading_shimmer_list.dart';
import '../widgets/add_ingredient/category_grid_widget.dart';
import '../widgets/add_ingredient/search_results_list.dart';
import '../widgets/add_ingredient/expiry_chip.dart';
import '../widgets/add_ingredient/search_step.dart';
import '../widgets/add_ingredient/manual_entry_step.dart';
import '../widgets/add_ingredient/details_step.dart';


class AddIngredientScreen extends StatelessWidget {
  const AddIngredientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PantryBloc(repository: PantryRepository()),
      child: const _AddIngredientView(),
    );
  }
}



class _AddIngredientView extends StatefulWidget {
  const _AddIngredientView();

  @override
  State<_AddIngredientView> createState() => _AddIngredientViewState();
}

class _AddIngredientViewState extends State<_AddIngredientView> {
  static const Map<String, int> _defaultExpiryDays = {
    // Nabiał
    'milk': 7, 'mleko': 7, 'jogurt': 14, 'yogurt': 14, 'butter': 30,
    'masło': 30, 'cheese': 21, 'ser': 21, 'cream': 7, 'śmietana': 7,
    'eggs': 21, 'jajka': 21, 'jajko': 21,
    // Mięso i ryby
    'chicken': 3, 'kurczak': 3, 'beef': 3, 'wołowina': 3, 'pork': 3,
    'wieprzowina': 3, 'fish': 2, 'ryba': 2, 'łosoś': 2, 'salmon': 2,
    'tuna': 2, 'tuńczyk': 2, 'ham': 5, 'szynka': 5,
    // Warzywa
    'lettuce': 5, 'sałata': 5, 'spinach': 5, 'szpinak': 5,
    'tomato': 7, 'pomidor': 7, 'cucumber': 7, 'ogórek': 7,
    'carrot': 14, 'marchewka': 14, 'broccoli': 7, 'brokuł': 7,
    'pepper': 14, 'papryka': 14, 'onion': 30, 'cebula': 30,
    'garlic': 30, 'czosnek': 30, 'potato': 30, 'ziemniaki': 30,
    'mushroom': 5, 'grzyby': 5, 'pieczarki': 5,
    // Owoce
    'banana': 5, 'banan': 5, 'apple': 14, 'jabłko': 14,
    'orange': 14, 'pomarańcza': 14, 'strawberry': 3, 'truskawka': 3,
    'kiwi': 7, 'grape': 7, 'winogrona': 7, 'lemon': 21, 'cytryna': 21,
    // Pieczywo
    'bread': 5, 'chleb': 5, 'bagel': 3, 'tortilla': 7,
    // Suche produkty (długo się przechowują)
    'rice': 365, 'ryż': 365, 'pasta': 365, 'makaron': 365,
    'flour': 365, 'mąka': 365, 'sugar': 730, 'cukier': 730,
    'oil': 365, 'olej': 365, 'oliwa': 365,
  };

  int _getDefaultExpiryDays(String name) {
    final lower = name.toLowerCase().trim();
    for (final entry in _defaultExpiryDays.entries) {
      if (lower.contains(entry.key) || entry.key.contains(lower)) {
        return entry.value;
      }
    }
    return 3; // domyślnie 3 dni jeśli nie znaleziono
  }

  final TextEditingController _searchController = TextEditingController();
  final SpoonacularService _spoonacularService = SpoonacularService();
  Timer? _debounce;
  
  bool _isLoading = false;
  String? _errorMessage;
  List<ProductItem> _searchResults = [];

  String _selectedName = '';
  String? _selectedImageUrl;
  String _selectedCategoryLabel = '';
  
  bool _manualEntryMode = false;
  final TextEditingController _manualNameController = TextEditingController();
  String _selectedEmoji = '🍽️';
  
  double _quantity = 1;
  String _unit = 'g';
  String _selectedExpiry = '3 days';
  DateTime? _customExpiry;
  String? _category;

  

  @override
  void dispose() {
    _searchController.dispose();
    _manualNameController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Map<String, String> _mapCategory(String aisle, String foodName) {
    final lowerAisle = aisle.toLowerCase();
    final lowerName = foodName.toLowerCase();

    if (lowerAisle.contains('produce') || lowerAisle.contains('fruit')) {
      if (lowerName.contains('carrot') || lowerName.contains('broccoli') || lowerName.contains('spinach') || 
          lowerName.contains('pepper') || lowerName.contains('onion') || lowerName.contains('garlic') || 
          lowerName.contains('tomato') || lowerName.contains('potato') || lowerName.contains('cucumber')) {
        return {'label': 'Warzywa', 'emoji': '🥦'};
      }
      return {'label': 'Owoce', 'emoji': '🍎'};
    }
    
    if (lowerAisle.contains('meat') || lowerAisle.contains('seafood') || lowerAisle.contains('fish')) {
      if (lowerAisle.contains('seafood') || lowerAisle.contains('fish') || lowerName.contains('fish') || lowerName.contains('salmon') || lowerName.contains('tuna')) {
        return {'label': 'Ryby', 'emoji': '🐟'};
      }
      return {'label': 'Mięso', 'emoji': '🥩'};
    }
    
    if (lowerAisle.contains('dairy') || lowerAisle.contains('cheese') || lowerAisle.contains('egg')) {
      return {'label': 'Nabiał', 'emoji': '🥛'};
    }
    
    if (lowerAisle.contains('beverage') || lowerAisle.contains('drink') || lowerAisle.contains('water') || lowerAisle.contains('juice')) {
      return {'label': 'Napoje', 'emoji': '🥤'};
    }
    
    if (lowerAisle.contains('bakery') || lowerAisle.contains('bread') || lowerAisle.contains('cereal') || lowerAisle.contains('pasta') || lowerAisle.contains('rice') || lowerAisle.contains('grain')) {
      return {'label': 'Zboża', 'emoji': '🌾'};
    }
    
    if (lowerAisle.contains('candy') || lowerAisle.contains('sweet') || lowerAisle.contains('chocolate') || lowerAisle.contains('dessert') || lowerAisle.contains('baking')) {
      return {'label': 'Słodycze', 'emoji': '🍫'};
    }
    
    if (lowerAisle.contains('spice') || lowerAisle.contains('condiment') || lowerAisle.contains('sauce') || lowerAisle.contains('oil')) {
      return {'label': 'Przyprawy', 'emoji': '🧂'};
    }

    if (lowerAisle.isEmpty) {
      if (lowerName.contains('apple') || lowerName.contains('banana')) return {'label': 'Owoce', 'emoji': '🍎'};
      if (lowerName.contains('chicken') || lowerName.contains('beef')) return {'label': 'Mięso', 'emoji': '🥩'};
      if (lowerName.contains('milk') || lowerName.contains('cheese')) return {'label': 'Nabiał', 'emoji': '🥛'};
      if (lowerName.contains('bread') || lowerName.contains('rice')) return {'label': 'Zboża', 'emoji': '🌾'};
      if (lowerName.contains('chocolate')) return {'label': 'Słodycze', 'emoji': '🍫'};
    }
    
    return {'label': 'Inne', 'emoji': '🍽️'};
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _errorMessage = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      final foods = await _spoonacularService.searchIngredients(query);
      
      final results = foods.map((f) {
        final name = f['name']?.toString() ?? 'Nieznany produkt';
        final image = f['image']?.toString() ?? '';
        final calories = f['calories'] ?? '0kcal';
        final fat = f['fat'] ?? '0g';
        final carbs = f['carbs'] ?? '0g';
        final protein = f['protein'] ?? '0g';
        final aisle = f['aisle']?.toString() ?? '';
        
        final desc = 'Calories: $calories | Fat: $fat | Carbs: $carbs | Protein: $protein';
        final mappedCat = _mapCategory(aisle, name);
        
        return ProductItem(
          name: name,
          brandName: null,
          description: desc,
          imageUrl: image,
          categoryLabel: mappedCat['label']!,
          categoryEmoji: mappedCat['emoji']!,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = null; // No red error text, just empty results
          _searchResults = [];
          _isLoading = false;
        });
      }
    }
  }

  void _resolveCategoryAndUnit(String categoryLabel) {
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
    } else if (catLower.contains('mięso') || catLower.contains('ryby')) {
      _category = 'protein';
      _unit = 'g';
      _quantity = 100;
    } else if (catLower.contains('zboża') || catLower.contains('pieczywo')) {
      _category = 'grains';
      _unit = 'g';
      _quantity = 100;
    } else {
      _category = 'other';
      _unit = 'g';
      _quantity = 100;
    }
  }

  DateTime? _calculateExpiry() {
    final now = DateTime.now();
    switch (_selectedExpiry) {
      case '1 day': return now.add(const Duration(days: 1));
      case '3 days': return now.add(const Duration(days: 3));
      case '1 week': return now.add(const Duration(days: 7));
      case '1 month': return now.add(const Duration(days: 30));
      case 'Custom': return _customExpiry ?? now.add(const Duration(days: 3));
      default: return now.add(Duration(days: _getDefaultExpiryDays(_selectedName)));
    }
  }

  void _addIngredient() {
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
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PantryBloc, PantryState>(
      listener: (context, state) {
        if (state is PantryIngredientAdded) {
          Navigator.of(context).pop();
        } else if (state is PantryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: EdgeInsets.only(top: 12.h, bottom: 16.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add Ingredient',
                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 32.r,
                          height: 32.r,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, size: 18.r, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                
                // Content
                _selectedName.isEmpty ? SearchStep(
                  manualEntryMode: _manualEntryMode,
                  onEnableManualEntry: () => setState(() => _manualEntryMode = true),
                  searchController: _searchController,
                  onSearchChanged: _onSearchChanged,
                  onClearSearch: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                  isLoading: _isLoading,
                  errorMessage: _errorMessage,
                  searchResults: _searchResults,
                  onItemTap: (item) {
                    setState(() {
                      _selectedName = item.brandName != null ? '${item.brandName} ${item.name}' : item.name;
                      _selectedImageUrl = item.imageUrl;
                      _selectedCategoryLabel = item.categoryLabel;
                      _selectedEmoji = item.categoryEmoji;
                      _resolveCategoryAndUnit(item.categoryLabel);

                      final suggestedDays = _getDefaultExpiryDays(_selectedName);
                      if (suggestedDays <= 1) _selectedExpiry = '1 day';
                      else if (suggestedDays <= 3) _selectedExpiry = '3 days';
                      else if (suggestedDays <= 7) _selectedExpiry = '1 week';
                      else _selectedExpiry = '1 month';
                    });
                  },
                  onCategoryGridTap: (query) {
                    _searchController.text = query;
                    _onSearchChanged(query);
                  },
                  manualEntryStepWidget: ManualEntryStep(
                    onDisableManualEntry: () => setState(() => _manualEntryMode = false),
                    manualNameController: _manualNameController,
                    onManualSelect: _selectManualCategory,
                  ),
                ) : DetailsStep(
                  selectedImageUrl: _selectedImageUrl,
                  selectedEmoji: _selectedEmoji,
                  selectedName: _selectedName,
                  selectedCategoryLabel: _selectedCategoryLabel,
                  onEditName: () => setState(() => _selectedName = ''),
                  unit: _unit,
                  quantity: _quantity,
                  onDecreaseQuantity: () {
                    setState(() {
                      double step = _unit == 'szt' ? 1 : 50;
                      if (_quantity > step) _quantity -= step;
                    });
                  },
                  onIncreaseQuantity: () {
                    setState(() {
                      double step = _unit == 'szt' ? 1 : 50;
                      _quantity += step;
                    });
                  },
                  onUnitChanged: (val) {
                    if (val != null) setState(() => _unit = val);
                  },
                  selectedExpiry: _selectedExpiry,
                  onAddIngredient: _addIngredient,
                  onExpiryTap: (label) async {
                    if (label == 'Custom') {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 3)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedExpiry = 'Custom';
                          _customExpiry = date;
                        });
                      }
                    } else {
                      setState(() => _selectedExpiry = label);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  
}
