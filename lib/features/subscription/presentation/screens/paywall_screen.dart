import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:vitasense/features/auth/data/models/user_model.dart';

class PaywallScreen extends StatefulWidget {
  final UserModel? user;

  const PaywallScreen({super.key, this.user});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  int _selectedPlanIndex = 0; // 0 for Yearly, 1 for Monthly
  bool _isPurchasing = false;

  int get _trialDaysLeft {
    final expires = widget.user?.trialExpiresAt;
    if (expires == null) return 0;
    final diff = expires.difference(DateTime.now()).inDays;
    return diff.clamp(0, 3);
  }

  String get _trialHeadline {
    final days = _trialDaysLeft;
    if (days <= 0) return 'Twój trial wygasł';
    if (days == 1) return 'Ostatni dzień trialu!';
    return 'Zostały Ci $days dni darmowego dostępu';
  }

  String get _ctaLabel {
    if (_trialDaysLeft <= 0) return 'Kup plan i wróć do VitaSense';
    if (_selectedPlanIndex == 0) return 'Kontynuuj z Yearly — \$4.91/mo';
    return 'Kontynuuj z Monthly — \$9.99/mo';
  }

  Future<void> _purchase(BuildContext context) async {
    if (_isPurchasing) return;
    setState(() => _isPurchasing = true);
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) {
        throw Exception('No offerings available. Configure products in RevenueCat dashboard.');
      }
      // Yearly = index 0, Monthly = index 1
      final package = _selectedPlanIndex == 0
          ? (current.annual ?? current.availablePackages.first)
          : (current.monthly ?? current.availablePackages.last);
      await Purchases.purchasePackage(package);
      if (context.mounted) context.go(AppRoutes.successPurchase);
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        // User cancelled — cicho wróć
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Purchase failed: ${e.name}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  static const List<String> _features = [
    'Meals from your pantry',
    'Tailored to your health',
    'AI-powered suggestions',
    'No more food waste',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Heading ───────────────────────────────────────────────
                  Text(
                    _trialHeadline,
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                  if (_trialDaysLeft > 0)
                    Container(
                      margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.primary, size: 18.r),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Za ${_trialDaysLeft == 1 ? "1 dzień" : "$_trialDaysLeft dni"} wyślemy Ci przypomnienie przed końcem trialu.',
                              style: TextStyle(fontSize: 13.sp, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 32.h),

                  // ─── Features ────────────────────────────────────────────
                  ...List.generate(_features.length, (i) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Row(
                      children: [
                        Icon(Icons.check, color: AppColors.primary, size: 24.r),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            _features[i],
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: Duration(milliseconds: 80 + i * 60))
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.04, end: 0)),

                  SizedBox(height: 32.h),

                  // ─── Plans ────────────────────────────────────────────────
                  _PlanCard(
                    title: 'Yearly Plan',
                    price: '\$4.91',
                    priceSuffix: '/mo',
                    billingNote: '\$59.00 billed annually',
                    badgeText: '3 DAYS FREE',
                    isSelected: _selectedPlanIndex == 0,
                    onTap: () => setState(() => _selectedPlanIndex = 0),
                  ).animate(delay: 280.ms).fadeIn(duration: 400.ms),

                  SizedBox(height: 16.h),

                  _PlanCard(
                    title: 'Monthly Plan',
                    price: '\$9.99',
                    priceSuffix: '/mo',
                    billingNote: 'Billed monthly',
                    badgeText: '3 DAYS FREE',
                    isSelected: _selectedPlanIndex == 1,
                    onTap: () => setState(() => _selectedPlanIndex = 1),
                  ).animate(delay: 320.ms).fadeIn(duration: 400.ms),

                  SizedBox(height: 40.h),

                  // ─── CTA ──────────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: FilledButton(
                      onPressed: _isPurchasing ? null : () => _purchase(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: _isPurchasing
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          : Text(
                              _ctaLabel,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ).animate(delay: 360.ms).fadeIn(duration: 400.ms),

                  SizedBox(height: 16.h),

                  Center(
                    child: Text(
                      'Cancel anytime',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[400],
                      ),
                    ),
                  ).animate(delay: 360.ms).fadeIn(duration: 400.ms),
                ],
              ),
            ),

            // ─── X Close Button ────────────────────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: IconButton(
                  onPressed: () => context.go(AppRoutes.home),
                  icon: Icon(Icons.close, color: Colors.black, size: 24.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String priceSuffix;
  final String billingNote;
  final String? badgeText;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.priceSuffix,
    required this.billingNote,
    this.badgeText,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1A1A2E) : Colors.white,
              border: Border.all(
                color: isSelected ? const Color(0xFF2ECC71) : Colors.grey[200]!,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isSelected) ...[
                            Icon(Icons.check_circle, color: const Color(0xFF2ECC71), size: 20.r),
                            SizedBox(width: 8.w),
                          ],
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        billingNote,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isSelected ? Colors.white70 : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      priceSuffix,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isSelected ? Colors.white70 : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (badgeText != null)
          Positioned(
            top: -12.h,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                badgeText!,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
