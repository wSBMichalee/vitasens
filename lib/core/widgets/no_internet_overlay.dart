import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/l10n/app_localizations.dart';

class NoInternetOverlay extends StatefulWidget {
  final Widget child;

  const NoInternetOverlay({super.key, required this.child});

  @override
  State<NoInternetOverlay> createState() => _NoInternetOverlayState();
}

class _NoInternetOverlayState extends State<NoInternetOverlay> {
  bool _isConnected = true;
  bool _isChecking = false;
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results);
    });
  }

  Future<void> _checkInitialConnection() async {
    final results = await Connectivity().checkConnectivity();
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final bool hasConnection = results.any((r) => r != ConnectivityResult.none);
    _debounce?.cancel();
    if (!hasConnection) {
      _debounce = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _isConnected = false);
      });
    } else {
      if (mounted) setState(() => _isConnected = true);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_isConnected)
          AnimatedOpacity(
            opacity: _isConnected ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            child: Material(
              color: Colors.white,
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80.r,
                          height: 80.r,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF5F5F5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.wifi_off_rounded,
                            size: 40.r,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          AppLocalizations.of(context)!.noConnection,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111111),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          AppLocalizations.of(context)!.checkConnection,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.grey.shade500,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 32.h),
                        SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: FilledButton(
                            onPressed: () async {
                              setState(() => _isChecking = true);
                              await Future.delayed(const Duration(milliseconds: 1500));
                              final results = await Connectivity().checkConnectivity();
                              _updateConnectionStatus(results);
                              if (mounted) setState(() => _isChecking = false);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF2ECC71),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            child: _isChecking
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5),
                                  )
                                : Text(
                                    AppLocalizations.of(context)!.refresh,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          AppLocalizations.of(context)!.connectionWillRestore,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
