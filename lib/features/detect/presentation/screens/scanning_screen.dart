import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/features/detect/bloc/detect_bloc.dart';
import 'package:vitasense/features/detect/bloc/detect_event.dart';
import 'package:vitasense/features/detect/bloc/detect_state.dart';
import 'package:vitasense/features/detect/data/detect_repository.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class ScanningScreen extends StatelessWidget {
  const ScanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DetectBloc(
        repository: DetectRepository(),
      ),
      child: const _ScanningView(),
    );
  }
}

class _ScanningView extends StatefulWidget {
  const _ScanningView();

  @override
  State<_ScanningView> createState() => _ScanningViewState();
}

class _ScanningViewState extends State<_ScanningView> {
  CameraController? _controller;
  String _mode = 'meal'; // meal/fridge/receipt
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _setMode(String mode) {
    setState(() => _mode = mode);
    context.read<DetectBloc>().add(SwitchMode(mode));
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final photo = await _controller!.takePicture();
      final bytes = await photo.readAsBytes();
      final base64String = base64Encode(bytes);
      
      if (mounted) {
        context.read<DetectBloc>().add(
          CapturePhoto(base64String, 'lunch'), // Temporary mock for mealTime
        );
      }
    } catch (e) {
      debugPrint("Error capturing photo: $e");
    }
  }

  void _pickFromGallery() {}

  void _autoDetect() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<DetectBloc, DetectState>(
        listener: (context, state) {
          if (state is DetectSuccess) {
            context.push(AppRoutes.aiMeals, extra: state.result);
          } else if (state is DetectError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Stack(
          children: [
            // 1. Camera preview
            Positioned.fill(
              child: _isCameraInitialized && _controller != null
                  ? CameraPreview(_controller!)
                  : Container(color: Colors.black),
            ),
            
            // Dark overlay for better contrast
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),

            // 2. TOP BAR
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 36.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, color: Colors.white, size: 20.r),
                        ),
                      ),
                      const Spacer(),
                      
                      // MODE TABS
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ModeTab(
                              label: "MEAL",
                              isSelected: _mode == 'meal',
                              onTap: () => _setMode('meal'),
                            ),
                            _ModeTab(
                              label: "FRIDGE",
                              isSelected: _mode == 'fridge',
                              onTap: () => _setMode('fridge'),
                            ),
                            _ModeTab(
                              label: "RECEIPT",
                              isSelected: _mode == 'receipt',
                              onTap: () => _setMode('receipt'),
                            ),
                          ],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Flash toggle
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 36.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.bolt, color: Colors.white, size: 20.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. SCANNING FRAME
            Center(
              child: SizedBox(
                width: 260.w,
                height: 260.h,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: const Size(260, 260),
                      painter: ScannerFramePainter(),
                    ),
                    Center(
                      child: BlocBuilder<DetectBloc, DetectState>(
                        builder: (context, state) {
                          if (state is DetectProcessing) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                "DETECTING\nINGREDIENTS...",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // BOTTOM CONTROLS AND TEXT
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 4. BOTTOM TEXT
                      Text(
                        "Scan your meal",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32.h),
                      
                      // 5. BOTTOM CONTROLS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: _pickFromGallery,
                                child: Container(
                                  width: 52.w,
                                  height: 52.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.photo_library_outlined, color: Colors.white, size: 24.r),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "UPLOAD",
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                          
                          GestureDetector(
                            onTap: _capturePhoto,
                            child: Container(
                              width: 72.w,
                              height: 72.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3.w),
                                color: Colors.white,
                              ),
                            ),
                          ),
                          
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: _autoDetect,
                                child: Container(
                                  width: 52.w,
                                  height: 52.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.auto_awesome, color: Colors.white, size: 24.r),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "AUTO",
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.textPrimary : Colors.white,
          ),
        ),
      ),
    );
  }
}

class ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double lineLength = 30;
    const double radius = 16; 

    // Top Left
    var path = Path()
      ..moveTo(0, lineLength)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(lineLength, 0);
    canvas.drawPath(path, paint);

    // Top Right
    path = Path()
      ..moveTo(size.width - lineLength, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, lineLength);
    canvas.drawPath(path, paint);

    // Bottom Right
    path = Path()
      ..moveTo(size.width, size.height - lineLength)
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(size.width, size.height, size.width - radius, size.height)
      ..lineTo(size.width - lineLength, size.height);
    canvas.drawPath(path, paint);

    // Bottom Left
    path = Path()
      ..moveTo(lineLength, size.height)
      ..lineTo(radius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - radius)
      ..lineTo(0, size.height - lineLength);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
