import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/widgets/app_header.dart';
import 'package:vitasense/core/supabase/supabase_client.dart';
import 'package:vitasense/core/utils/snackbar_utils.dart';
import 'package:vitasense/core/router/app_routes.dart';

class BarcodeResultScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const BarcodeResultScreen({super.key, required this.product});

  @override
  State<BarcodeResultScreen> createState() => _BarcodeResultScreenState();
}

class _BarcodeResultScreenState extends State<BarcodeResultScreen> {
  late double _servingG;
  bool _isProcessing = false;

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

  Future<void> _handleAction() async {
    final mode = widget.product['_mode'] ?? 'meal';
    final barcode = widget.product['barcode'];
    if (barcode == null) return;
    
    setState(() => _isProcessing = true);
    
    try {
      if (mode == 'meal') {
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
          SnackbarUtils.showSuccess(context, "Dodano \${widget.product['name']} do $mealTimeStr!");
          context.go(AppRoutes.home); // go to home to see the change
        } else {
          throw Exception('Failed');
        }
      } else if (mode == 'pantry') {
        // Here we just use a default pantryId. In real life we might get this from the user's active pantry.
        // Wait, for this demo we just get the first one or hardcode an ID if none provided.
        // A better approach is to ask backend to pick default or we fetch it.
        // Assuming backend handles user's pantry if we send null or we just fetch it.
        // Let's assume we need to fetch pantryId first
        final pantryRes = await SupabaseClientService.instance.client.from('pantries').select('id').limit(1).single();
        final pantryId = pantryRes['id'];
        
        final response = await SupabaseClientService.instance.client.functions.invoke(
          'scan-barcode',
          body: {
            'action': 'add_to_pantry',
            'barcode': barcode,
            'pantryId': pantryId,
            'quantity': _servingG,
            'unit': 'g',
          },
        );
        
        final data = response.data;
        if (data['success'] == true) {
          if (!mounted) return;
          SnackbarUtils.showSuccess(context, 'Dodano do spiżarni!');
          context.go(AppRoutes.pantry); 
        } else {
          throw Exception('Failed');
        }
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Wystąpił błąd podczas dodawania.');
      setState(() => _isProcessing = false);
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
    final buttonLabel = mode == 'meal' ? 'Dodaj do posiłku' : 'Dodaj do spiżarni';

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Skanowanie',
              subtitle: "Wynik dla kodu: \${widget.product['barcode']}",
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
                            '\${_servingG.toInt()}g',
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
              child: SizedBox(
                width: double.infinity,
                height: 56.h,
                child: FilledButton(
                  onPressed: _isProcessing ? null : _handleAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  ),
                  child: _isProcessing 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(buttonLabel, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                ),
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
