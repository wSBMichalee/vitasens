import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/widgets/app_header.dart';
import 'package:vitasense/core/supabase/supabase_client.dart';
import 'package:vitasense/core/utils/snackbar_utils.dart';
import 'package:vitasense/core/router/app_routes.dart';
import 'package:vitasense/features/pantry/data/pantry_repository.dart';

class BarcodeResultScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const BarcodeResultScreen({super.key, required this.product});

  @override
  State<BarcodeResultScreen> createState() => _BarcodeResultScreenState();
}

class _BarcodeResultScreenState extends State<BarcodeResultScreen> {
  late double _servingG;
  bool _isProcessingMeal = false;
  bool _isProcessingPantry = false;
  String _storageLocation = 'fridge';

  @override
  void initState() {
    super.initState();
    _servingG = (widget.product['servingSizeG'] as num?)?.toDouble() ?? 100.0;
  }

  void _updateServing(double value) {
    setState(() => _servingG = value);
  }
  
  double _scaleMacro(String key) {
    final value100g = (widget.product[key] as num?)?.toDouble() ?? 0.0;
    return value100g * (_servingG / 100.0);
  }

  Future<void> _handleAddToMeal() async {
    final barcode = widget.product['barcode'];
    if (barcode == null) return;
    
    setState(() => _isProcessingMeal = true);
    
    try {
      final now = DateTime.now();
      final mealTimeStr = _getMealTimeStr(now.hour);
      final dateStr = now.toIso8601String().split('T')[0];
      
      final response = await SupabaseClientService.instance.client.functions.invoke(
        'scan-barcode',
        body: {
          'action': 'log_meal',
          'barcode': barcode,
          'servingG': _servingG,
          'mealTime': mealTimeStr,
          'mealDate': dateStr,
        },
      );
      
      final data = response.data;
      if (data['success'] == true) {
        if (!mounted) return;
        SnackbarUtils.showSuccess(context, 'Dodano do dziennika');
        context.go(AppRoutes.home);
      } else {
        throw Exception('Failed');
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Wystąpił błąd podczas dodawania do posiłku.');
      setState(() => _isProcessingMeal = false);
    }
  }

  Future<void> _handleAddToPantry() async {
    final name = widget.product['name'] as String? ?? 'Nieznany produkt';
    
    setState(() => _isProcessingPantry = true);
    
    try {
      await PantryRepository().addIngredient(
        pantryId: 'default',
        name: name,
        quantity: _servingG,
        unit: 'g',
        category: 'other',
        storageLocation: _storageLocation,
      );
      
      if (!mounted) return;
      
      String locationLabel = 'lodówki';
      if (_storageLocation == 'freezer') locationLabel = 'zamrażarki';
      if (_storageLocation == 'pantry') locationLabel = 'spiżarni';
      
      SnackbarUtils.showSuccess(context, '$name dodano do $locationLabel');
      
      setState(() => _isProcessingPantry = false);
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Wystąpił błąd podczas dodawania do spiżarni.');
      setState(() => _isProcessingPantry = false);
    }
  }
  
  String _getMealTimeStr(int hour) {
    if (hour >= 5 && hour < 11) return 'breakfast';
    if (hour >= 11 && hour < 16) return 'lunch';
    if (hour >= 16 && hour < 22) return 'dinner';
    return 'snack';
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.product['name'] as String? ?? 'Unknown Product';
    final brand = widget.product['brand'] as String?;
    final imageUrl = widget.product['imageUrl'] as String?;
    
    final scaledKcal = _scaleMacro('kcal100g');
    final scaledProtein = _scaleMacro('protein100g');
    final scaledCarbs = _scaleMacro('carbs100g');
    final scaledFat = _scaleMacro('fat100g');
    
    final mode = widget.product['_mode'] ?? 'meal';

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Skanowanie',
              subtitle: "Wynik dla kodu: ${widget.product['barcode']}",
              variant: AppHeaderVariant.nested,
              onBack: () => context.pop(),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    if (imageUrl != null && imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 200.w,
                          height: 200.h,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.borderLight,
                            child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.borderLight,
                            child: Icon(Icons.fastfood, size: 50.r, color: AppColors.textMuted),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 200.w,
                        height: 200.h,
                        decoration: BoxDecoration(
                          color: AppColors.borderLight,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Icon(Icons.fastfood, size: 80.r, color: AppColors.textMuted),
                      ),
                      
                    SizedBox(height: 24.h),
                    
                    Text(
                      name,
                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    if (brand != null && brand.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        brand,
                        style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    
                    SizedBox(height: 32.h),
                    
                    // Serving size selector
                    Text('Porcja (g)', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _servingG,
                            min: 10,
                            max: 1000,
                            divisions: 99,
                            activeColor: AppColors.primary,
                            onChanged: _updateServing,
                          ),
                        ),
                        Container(
                          width: 60.w,
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.borderLight,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            '${_servingG.toInt()}g',
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 32.h),
                    
                    // Macros Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _MacroBubble(label: 'Kcal', value: '${scaledKcal.round()}', color: Colors.orange),
                        _MacroBubble(label: 'Białko', value: '${scaledProtein.round()}g', color: Colors.blue),
                        _MacroBubble(label: 'Węgle', value: '${scaledCarbs.round()}g', color: Colors.purple),
                        _MacroBubble(label: 'Tłuszcz', value: '${scaledFat.round()}g', color: Colors.red),
                      ],
                    ),

                    SizedBox(height: 32.h),
                    
                    // Storage location selector
                    Row(
                      children: [
                        _StorageChip(
                          label: '🧊 Lodówka',
                          value: 'fridge',
                          selected: _storageLocation == 'fridge',
                          onTap: () => setState(() => _storageLocation = 'fridge'),
                        ),
                        SizedBox(width: 8.w),
                        _StorageChip(
                          label: '❄️ Zamrażarka',
                          value: 'freezer',
                          selected: _storageLocation == 'freezer',
                          onTap: () => setState(() => _storageLocation = 'freezer'),
                        ),
                        SizedBox(width: 8.w),
                        _StorageChip(
                          label: '🗄️ Spiżarnia',
                          value: 'pantry',
                          selected: _storageLocation == 'pantry',
                          onTap: () => setState(() => _storageLocation = 'pantry'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Buttons
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (mode == 'meal') ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: FilledButton.icon(
                        onPressed: _isProcessingMeal || _isProcessingPantry ? null : _handleAddToMeal,
                        icon: _isProcessingMeal 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.restaurant, color: Colors.white),
                        label: Text('Dodaj do posiłku', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: OutlinedButton.icon(
                      onPressed: _isProcessingMeal || _isProcessingPantry ? null : _handleAddToPantry,
                      icon: _isProcessingPantry
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.kitchen),
                      label: Text('Dodaj do spiżarni', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroBubble extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroBubble({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56.r,
          height: 56.r,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _StorageChip extends StatelessWidget {
  final String label, value;
  final bool selected;
  final VoidCallback onTap;
  
  const _StorageChip({
    required this.label, 
    required this.value, 
    required this.selected, 
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : AppColors.backgroundWhite,
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text(
              label, 
              style: TextStyle(
                fontSize: 11.sp, 
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500, 
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
