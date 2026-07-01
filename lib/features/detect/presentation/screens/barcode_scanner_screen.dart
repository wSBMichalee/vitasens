import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/supabase/supabase_client.dart';
import 'package:vitasense/core/utils/snackbar_utils.dart';
import 'package:vitasense/core/router/app_routes.dart';

class BarcodeScannerScreen extends StatefulWidget {
  final String mode; // 'meal' | 'pantry'
  
  const BarcodeScannerScreen({
    super.key,
    this.mode = 'meal',
  });

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.all],
  );
  bool _isProcessing = false;

  Future<void> _processBarcode(String barcode) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final response = await SupabaseClientService.instance.client.functions.invoke(
        'scan-barcode',
        body: {'action': 'lookup', 'barcode': barcode},
      );
      
      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        if (!mounted) return;
        final product = data['data'] as Map<String, dynamic>;
        
        // Include mode in the product data to handle action properly on the next screen
        product['_mode'] = widget.mode; 
        
        context.pushReplacement(AppRoutes.barcodeResult, extra: product);
      } else {
        if (!mounted) return;
        SnackbarUtils.showError(context, 'Produkt nie znaleziony. Spróbuj inny kod.');
        // Allow scanning again after a short delay
        await Future.delayed(const Duration(seconds: 2));
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Produkt nie znaleziony. Spróbuj inny kod.');
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: 250.w,
      height: 250.h,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _scannerController,
            scanWindow: scanWindow,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null && !_isProcessing) {
                  _processBarcode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          // Skaner nakładka (ciemne tło poza ramką)
          CustomPaint(
            painter: _ScannerOverlayPainter(scanWindow: scanWindow),
          ),
          // Zamknij
          Positioned(
            top: 50.h,
            left: 16.w,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => context.pop(),
            ),
          ),
          // Instrukcja
          Positioned(
            bottom: 60.h,
            left: 0,
            right: 0,
            child: Text(
              'Skieruj kamerę na kod kreskowy',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                shadows: const [
                  Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(0, 0))
                ],
              ),
            ),
          ),
          // Loading indicator
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final Rect scanWindow;

  _ScannerOverlayPainter({required this.scanWindow});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final transparentPaint = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.clear;

    final borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawRect(Offset.zero & size, backgroundPaint);
    
    // Clear the center rect
    final RRect rrect = RRect.fromRectAndRadius(scanWindow, const Radius.circular(20));
    canvas.drawRRect(rrect, transparentPaint);
    
    // Draw the border
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
