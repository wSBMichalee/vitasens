import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Helper for requesting runtime permissions and handling permanent denials.
///
/// Usage:
/// ```dart
/// final granted = await PermissionHelper.requestCamera();
/// if (!granted) {
///   await PermissionHelper.openAppSettingsIfDenied(context, Permission.camera);
/// }
/// ```
class PermissionHelper {
  PermissionHelper._(); // prevent instantiation

  // ---------------------------------------------------------------------------
  // Camera
  // ---------------------------------------------------------------------------

  /// Requests camera access.
  /// Returns `true` if permission is granted, `false` otherwise.
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // ---------------------------------------------------------------------------
  // Microphone
  // ---------------------------------------------------------------------------

  /// Requests microphone access.
  /// Returns `true` if permission is granted, `false` otherwise.
  static Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // ---------------------------------------------------------------------------
  // Photos / Gallery
  // ---------------------------------------------------------------------------

  /// Requests photo library access.
  /// Returns `true` if permission is granted, `false` otherwise.
  static Future<bool> requestPhotos() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  // ---------------------------------------------------------------------------
  // App Settings fallback
  // ---------------------------------------------------------------------------

  /// Shows an [AlertDialog] prompting the user to open app settings when a
  /// [permission] has been permanently denied.
  ///
  /// Does nothing if the permission is NOT permanently denied.
  static Future<void> openAppSettingsIfDenied(
    BuildContext context,
    Permission permission,
  ) async {
    final status = await permission.status;

    if (!status.isPermanentlyDenied) return;

    final permissionLabel = _permissionLabel(permission);

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Uprawnienie wymagane'),
        content: Text(
          'Dostęp do $permissionLabel został trwale zablokowany. '
          'Otwórz Ustawienia aplikacji, aby przyznać to uprawnienie.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await openAppSettings();
            },
            child: const Text('Otwórz ustawienia'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  static String _permissionLabel(Permission permission) {
    if (permission == Permission.camera) return 'kamery';
    if (permission == Permission.microphone) return 'mikrofonu';
    if (permission == Permission.photos) return 'biblioteki zdjęć';
    return 'wymaganego zasobu';
  }
}
