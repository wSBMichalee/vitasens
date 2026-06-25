import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoInternetOverlay extends StatefulWidget {
  final Widget child;

  const NoInternetOverlay({super.key, required this.child});

  @override
  State<NoInternetOverlay> createState() => _NoInternetOverlayState();
}

class _NoInternetOverlayState extends State<NoInternetOverlay> {
  bool _isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

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
    // If the list only contains 'none', we have no connection.
    final bool hasConnection = !results.contains(ConnectivityResult.none) || results.length > 1;
    if (_isConnected != hasConnection) {
      setState(() {
        _isConnected = hasConnection;
      });
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          left: 0,
          right: 0,
          bottom: _isConnected ? -100.h : 0,
          child: Material(
            color: Colors.transparent,
            child: Container(
              color: Colors.black87,
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h + MediaQuery.of(context).padding.bottom),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20.r),
                  SizedBox(width: 8.w),
                  Text(
                    'Brak połączenia z internetem',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
