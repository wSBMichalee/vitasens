import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';

/// Warianty nagłówka ekranu.
enum AppHeaderVariant {
  /// Ekrany główne (home, pantry, AI, progress, profile).
  /// Bez przycisku back. Tytuł po lewej. Opcjonalne akcje po prawej.
  main,

  /// Ekrany zagnieżdżone (push navigation).
  /// Przycisk back po lewej. Tytuł po lewej lub wycentrowany.
  /// Opcjonalne akcje po prawej.
  nested,

  /// Ekrany modalne (bottom sheet, dialog).
  /// Bez back. Tytuł po lewej. Przycisk X po prawej.
  modal,
}

/// Reużywalny nagłówek ekranu zgodny z DESIGN_SYSTEM.md.
///
/// Przykład użycia:
/// ```dart
/// AppHeader(
///   title: 'Spiżarnia',
///   subtitle: 'Twoje składniki',
///   variant: AppHeaderVariant.main,
///   actions: [
///     AppHeaderIconButton(icon: Icons.search, onPressed: () {}),
///   ],
/// )
/// ```
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.actions,
    this.variant = AppHeaderVariant.main,
    this.showDivider = true,
    this.backgroundColor,
    this.textColor,
  });

  final Color? backgroundColor;
  final Color? textColor;

  /// Tytuł nagłówka — wymagany.
  final String title;

  /// Opcjonalny podtytuł pod tytułem.
  final String? subtitle;

  /// Czy pokazać przycisk back po lewej.
  /// Dla [AppHeaderVariant.nested] automatycznie ustawiane na true
  /// jeśli nie podano inaczej.
  final bool showBack;

  /// Callback dla przycisku back.
  /// Jeśli null i [showBack] == true, używa Navigator.maybePop.
  final VoidCallback? onBack;

  /// Opcjonalne widgety po prawej stronie nagłówka.
  /// Używaj [AppHeaderIconButton] dla standardowych ikon.
  final List<Widget>? actions;

  /// Wariant nagłówka określający jego zachowanie i wygląd.
  final AppHeaderVariant variant;

  /// Czy pokazać separator na dole nagłówka.
  final bool showDivider;

  bool get _shouldShowBack =>
      showBack || variant == AppHeaderVariant.nested;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? AppColors.backgroundWhite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 16.h,
              left: 20.w,
              right: 20.w,
              bottom: 8.h,
            ),
            child: _buildContent(context),
          ),
          if (showDivider)
            Divider(
              color: backgroundColor != null
                  ? backgroundColor!.withValues(alpha: 0.3)
                  : AppColors.borderLight,
              thickness: 1,
              height: 1,
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (variant) {
      case AppHeaderVariant.main:
        return _MainHeader(
          title: title,
          subtitle: subtitle,
          showBack: _shouldShowBack,
          onBack: onBack,
          actions: actions,
          textColor: textColor,
        );
      case AppHeaderVariant.nested:
        return _NestedHeader(
          title: title,
          subtitle: subtitle,
          onBack: onBack,
          actions: actions,
          textColor: textColor,
        );
      case AppHeaderVariant.modal:
        return _ModalHeader(
          title: title,
          subtitle: subtitle,
          actions: actions,
          textColor: textColor,
        );
    }
  }
}

// ─── WARIANT 1: MAIN ─────────────────────────────────────────────────────────

class _MainHeader extends StatelessWidget {
  const _MainHeader({
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.actions,
    this.textColor,
  });

  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final iconColor = textColor ?? AppColors.textPrimary;
    final bgColor = textColor != null ? textColor!.withValues(alpha: 0.2) : AppColors.borderLight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showBack) ...[
          _BackButton(onBack: onBack, iconColor: iconColor, bgColor: bgColor),
          SizedBox(width: 12.w),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 28.sp,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: textColor ?? Colors.black,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 2.h),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.5,
                    color: textColor?.withValues(alpha: 0.8) ?? AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actions != null && actions!.isNotEmpty) ...[
          SizedBox(width: 8.w),
          ...actions!,
        ],
      ],
    );
  }
}

// ─── WARIANT 2: NESTED ───────────────────────────────────────────────────────

class _NestedHeader extends StatelessWidget {
  const _NestedHeader({
    required this.title,
    this.subtitle,
    this.onBack,
    this.actions,
    this.textColor,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final bool hasActions = actions != null && actions!.isNotEmpty;
    final iconColor = textColor ?? AppColors.textPrimary;
    final bgColor = textColor != null ? textColor!.withValues(alpha: 0.2) : AppColors.borderLight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _BackButton(onBack: onBack, iconColor: iconColor, bgColor: bgColor),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 28.sp,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: textColor ?? Colors.black,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 2.h),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.5,
                    color: textColor?.withValues(alpha: 0.8) ?? AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (hasActions) ...[
          SizedBox(width: 8.w),
          ...actions!,
        ],
      ],
    );
  }
}

// ─── WARIANT 3: MODAL ────────────────────────────────────────────────────────

class _ModalHeader extends StatelessWidget {
  const _ModalHeader({
    required this.title,
    this.subtitle,
    this.actions,
    this.textColor,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final iconColor = textColor ?? AppColors.textPrimary;
    final bgColor = textColor != null ? textColor!.withValues(alpha: 0.2) : AppColors.borderLight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 28.sp,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: textColor ?? Colors.black,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 2.h),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.5,
                    color: textColor?.withValues(alpha: 0.8) ?? AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actions != null && actions!.isNotEmpty) ...[
          SizedBox(width: 8.w),
          ...actions!,
        ] else ...[
          SizedBox(width: 8.w),
          _CloseButton(iconColor: iconColor, bgColor: bgColor),
        ],
      ],
    );
  }
}

// ─── SHARED COMPONENTS ───────────────────────────────────────────────────────

/// Przycisk back — kółko 40×40 z ikoną strzałki.
/// Touch target spełnia wymóg min 44×44 przez GestureDetector padding.
class _BackButton extends StatelessWidget {
  const _BackButton({this.onBack, this.iconColor, this.bgColor});

  final VoidCallback? onBack;
  final Color? iconColor;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBack ?? () => Navigator.of(context).maybePop(),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        // Rozszerza touch target do 44×44
        padding: EdgeInsets.all(2.r),
        child: Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: bgColor ?? AppColors.borderLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: iconColor ?? AppColors.textPrimary,
            size: 18.r,
          ),
        ),
      ),
    );
  }
}

/// Przycisk zamknięcia X — dla wariantu modal.
class _CloseButton extends StatelessWidget {
  const _CloseButton({this.iconColor, this.bgColor});

  final Color? iconColor;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.all(2.r),
        child: Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: bgColor ?? AppColors.borderLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close,
            color: iconColor ?? AppColors.textPrimary,
            size: 20.r,
          ),
        ),
      ),
    );
  }
}

/// Standardowy przycisk ikonowy do użycia w [AppHeader.actions].
/// Spełnia wymóg min 44×44 touch target.
///
/// Przykład:
/// ```dart
/// AppHeaderIconButton(icon: Icons.search, onPressed: () {})
/// ```
class AppHeaderIconButton extends StatelessWidget {
  const AppHeaderIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.backgroundColor,
    this.badge,
  });

  /// Ikona do wyświetlenia.
  final IconData icon;

  /// Callback po naciśnięciu.
  final VoidCallback onPressed;

  /// Kolor ikony. Domyślnie [AppColors.textPrimary].
  final Color? color;

  /// Kolor tła przycisku. Domyślnie [AppColors.borderLight].
  final Color? backgroundColor;

  /// Opcjonalna odznaka (badge) — liczba lub kropka.
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.all(2.r),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: backgroundColor ?? AppColors.borderLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color ?? AppColors.textPrimary,
                size: 20.r,
              ),
            ),
            if (badge != null)
              Positioned(
                top: -2,
                right: -2,
                child: badge!,
              ),
          ],
        ),
      ),
    );
  }
}
