# VitaSens — Design System

> **Reguła #0**: Przed każdą zmianą UI przeczytaj ten plik.
> Każde odstępstwo musi być udokumentowane i zatwierdzone.

---

## 1. Kolory (`AppColors`)

Import: `package:vitasense/core/theme/app_colors.dart`

### Tła (Backgrounds)
| Token | Wartość | Użycie |
|---|---|---|
| `AppColors.background` | `#F5F5F5` | Tło główne Scaffold |
| `AppColors.backgroundWhite` | `#FFFFFF` | Karty, kontenery, pola |
| `AppColors.backgroundDark` | `#1F2937` | Ciemne przyciski, FAB |
| `AppColors.surface` | `#FFFFFF` | Powierzchnia kontenerów |
| `AppColors.backgroundNavy` | `#1A1F2E` | Paywall, dark sections |

### Akcent główny (Primary — Zielony)
| Token | Wartość | Użycie |
|---|---|---|
| `AppColors.primary` | `#22C55E` | CTA, progress, akcenty |
| `AppColors.primaryDark` | `#16A34A` | Hover, pressed states |
| `AppColors.primaryLight` | `#DCFCE7` | Tła ikon, tagi |

### Akcent dodatkowy (Secondary — Niebieski)
| Token | Wartość | Użycie |
|---|---|---|
| `AppColors.secondary` | `#3B82F6` | AI insights, linki |
| `AppColors.secondaryLight` | `#EFF6FF` | Tła kart insight |

### Statusy
| Token | Wartość | Użycie |
|---|---|---|
| `AppColors.error` | `#EF4444` | Błędy, LOW status |
| `AppColors.errorLight` | `#FEE2E2` | Tła błędów |
| `AppColors.warning` | `#F59E0B` | Ostrzeżenia, streak |
| `AppColors.warningLight` | `#FFF7ED` | Tła ostrzeżeń |
| `AppColors.success` | `#22C55E` | Sukces (= primary) |
| `AppColors.successLight` | `#E8F5E9` | Tła sukcesu |
| `AppColors.successDark` | `#2E7D32` | Tekst sukcesu |

### Teksty
| Token | Wartość | Użycie |
|---|---|---|
| `AppColors.textPrimary` | `#111827` | Nagłówki, wartości |
| `AppColors.textSecondary` | `#6B7280` | Podtytuły, opisy |
| `AppColors.textMuted` | `#9CA3AF` | Placeholdery, hinty |
| `AppColors.textWhite` | `#FFFFFF` | Tekst na ciemnym tle |

### Makroskładniki
| Token | Wartość | Użycie |
|---|---|---|
| `AppColors.proteinColor` | `#3B82F6` | Białko |
| `AppColors.carbsColor` | `#22C55E` | Węglowodany |
| `AppColors.fatColor` | `#F97316` | Tłuszcze |

### Ramki i linie
| Token | Wartość | Użycie |
|---|---|---|
| `AppColors.border` | `#E5E7EB` | Standardowa ramka |
| `AppColors.borderLight` | `#F3F4F6` | Separatory, tła pasków |
| `AppColors.borderMedium` | `#D1D5DB` | Mocniejsza ramka |

### Nawigacja dolna
| Token | Wartość | Użycie |
|---|---|---|
| `AppColors.bottomNavBg` | `#FFFFFF` | Tło paska |
| `AppColors.bottomNavSelected` | `#111827` | Aktywna zakładka |
| `AppColors.bottomNavUnselected` | `#9CA3AF` | Nieaktywna zakładka |

> ⛔ **ZAKAZ**: Nie używaj `Colors.white`, `Colors.black`, `Color(0xFF...)` bezpośrednio.
> Zawsze używaj tokenów `AppColors.*`.
> Wyjątek: `Colors.transparent` i `Colors.black.withValues(alpha: x)` dla cieni.

---

## 2. Typografia (`AppTextStyles`)

Import: `package:vitasense/core/theme/app_text_styles.dart`  
Font: **Inter** (Google Fonts)

### Hierarchia stylów
| Token | Rozmiar | Weight | Kolor | Line-height | Użycie |
|---|---|---|---|---|---|
| `displayLarge` | 32 | w700 | textPrimary | 1.2 | Onboarding hero |
| `displayMedium` | 28 | w700 | textPrimary | 1.2 | Onboarding secondary |
| `headingXL` | 28 | w700 | textPrimary | — | Nagłówek ekranu (main) |
| `headingLarge` | 24 | w700 | textPrimary | — | Nagłówek sekcji |
| `headingMedium` | 20 | w700 | textPrimary | — | Podsekcja |
| `headingSmall` | 18 | w600 | textPrimary | — | Tytuł karty |
| `bodyLarge` | 16 | w400 | textPrimary | 1.5 | Body text (MINIMUM) |
| `bodyMedium` | 14 | w400 | textSecondary | 1.5 | Opisy, podtytuły |
| `bodySmall` | 12 | w400 | textMuted | — | Drobne info |
| `labelLarge` | 16 | w600 | textPrimary | — | Etykiety przycisków |
| `labelMedium` | 14 | w600 | textPrimary | — | Etykiety tagi |
| `labelSmall` | 12 | w500 | textSecondary | — | Micro-etykiety |
| `numberXL` | 48 | w700 | textPrimary | — | Kalorie hero |
| `numberLarge` | 32 | w700 | textPrimary | — | Duże liczby |
| `numberMedium` | 24 | w700 | textPrimary | — | Makra wartości |
| `numberSmall` | 16 | w600 | textPrimary | — | Małe liczby |
| `caption` | 11 | w400 | textMuted | — | Podpisy |
| `captionBold` | 11 | w600 | textSecondary | — | Etykiety caps |

### Zasady typografii
- **Minimum 16sp** dla body text (`bodyLarge` lub większy)
- **Minimum 14sp** dla etykiet i opisów (`bodyMedium`)
- **Line-height 1.5** dla wszystkich paragrafów i opisów
- Używaj `AppTextStyles.*` zamiast inline `TextStyle(fontSize: x)`
- Dopuszczalne inline `TextStyle` z `fontSize: x.sp` tylko gdy token nie pasuje

---

## 3. Wymiary i Spacing

### System 4pt
Wszystkie odstępy muszą być wielokrotnością 4:
`4, 8, 12, 16, 20, 24, 28, 32, 40, 48, 56, 64`

### ScreenUtil — obowiązkowe
```dart
import 'package:flutter_screenutil/flutter_screenutil.dart';
```
| Suffix | Użycie |
|---|---|
| `.sp` | fontSize |
| `.h` | height, vertical padding/margin |
| `.w` | width, horizontal padding/margin |
| `.r` | radius, kwadratowe wymiary (ikony, avatary) |

### Padding ekranu
- **Horizontal**: `24.w` (standard), `20.w` (header)
- **Vertical top**: `24.h` (pod SafeArea)
- **Vertical bottom**: `100.h` (z FAB), `24.h` (bez FAB)

### Touch targets
- **Minimum 44×44dp** dla wszystkich klikalnych elementów
- Przyciski: `height: 50.h` minimum (CTA: `56.h`)
- Ikony klikalne: `40.r` minimum container
- Użyj `Padding` lub `GestureDetector` z odpowiednim rozmiarem jeśli element jest mniejszy

---

## 4. Komponenty

### Karty (Cards)
```dart
decoration: BoxDecoration(
  color: AppColors.backgroundWhite,
  borderRadius: BorderRadius.circular(20.r),  // lub 16.r, 24.r
  border: Border.all(color: AppColors.border),
  boxShadow: [
    BoxShadow(
      blurRadius: 16,
      offset: Offset(0, 6),
      color: Colors.black.withValues(alpha: 0.04),
    ),
  ],
),
```

### Przyciski CTA (Primary)
- `FilledButton` z `backgroundColor: AppColors.primary`
- `height: 56.h`, `borderRadius: 16.r`
- Text: `labelLarge`, `AppColors.textWhite`, `letterSpacing: 0.5`

### Przyciski Dark (Secondary action)
- `ElevatedButton` lub `FilledButton` z `backgroundColor: AppColors.backgroundDark`
- Te same wymiary co CTA

### Przyciski Outlined
- `OutlinedButton` z `side: BorderSide(color: AppColors.border)`

### Back Button (standardowy)
```dart
Container(
  width: 40.r, height: 40.r,
  decoration: BoxDecoration(
    color: AppColors.borderLight,
    shape: BoxShape.circle,
  ),
  child: Icon(
    Icons.arrow_back_ios_new,
    color: AppColors.textPrimary,
    size: 18.r,
  ),
)
```

---

## 5. Nagłówki Ekranów (`AppHeader`)

Import: `package:vitasense/core/widgets/app_header.dart`

> ⛔ **ZAKAZ**: Nie buduj własnych nagłówków inline. Zawsze używaj `AppHeader`.

### Warianty
| Wariant | Opis | Używany na |
|---|---|---|
| `AppHeaderVariant.main` | Bez back, tytuł po lewej, akcje po prawej | home, pantry, AI, progress, profile |
| `AppHeaderVariant.nested` | Back po lewej, tytuł wycentrowany/po lewej, akcje po prawej | push navigation |
| `AppHeaderVariant.modal` | Bez back, tytuł po lewej, X po prawej | bottom sheet, dialog |

### Parametry
```dart
AppHeader(
  title: 'Tytuł',           // wymagany
  subtitle: 'Podtytuł',     // opcjonalny
  showBack: false,           // default false
  onBack: () {},             // opcjonalny
  actions: [Widget],         // opcjonalne ikony po prawej
  variant: AppHeaderVariant.main,
)
```

### Styl
- Tło: przezroczyste (dopasowuje się do Scaffold)
- Padding: `horizontal: 20.w`, `vertical: 16.h`
- Tytuł: `26.sp`, `w700`, `AppColors.textPrimary`, `height: 1.2`
- Podtytuł: `13.sp`, `AppColors.textSecondary`, `height: 1.5`
- Separator: `Divider(color: AppColors.borderLight, thickness: 1, height: 1)`

---

## 6. Stany Widgetów

### Loading State — Shimmer
```dart
// Shimmer zamiast spinnera dla list i kart
// Użyj pakietu shimmer lub własnego AnimationController
Container(
  decoration: BoxDecoration(
    color: AppColors.borderLight,
    borderRadius: BorderRadius.circular(12.r),
  ),
)
// + ShimmerEffect (gradient animowany)
```

### Empty State
```dart
// Zawsze z ikoną + tytułem + opisem + przyciskiem CTA
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Icon(icon, color: AppColors.textMuted, size: 48.r),
    SizedBox(height: 16.h),
    Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
    SizedBox(height: 8.h),
    Text(description, style: TextStyle(fontSize: 14.sp, height: 1.5, color: AppColors.textMuted)),
    SizedBox(height: 24.h),
    // CTA Button
  ],
)
```

### Error State
```dart
// Zawsze z opisem błędu + przyciskiem Retry
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Icon(Icons.error_outline, color: AppColors.error, size: 48.r),
    SizedBox(height: 16.h),
    Text('Coś poszło nie tak', style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary)),
    SizedBox(height: 24.h),
    FilledButton(onPressed: onRetry, child: Text('Spróbuj ponownie')),
  ],
)
```

---

## 7. Animacje

| Typ | Czas | Krzywa |
|---|---|---|
| Micro (tap feedback, scale) | 150ms | `Curves.easeInOut` |
| Transition (slide, fade) | 250ms | `Curves.easeOut` |
| Reveal (expansion) | 300ms | `Curves.easeInOutCubic` |

- **Shimmer loading**: gradient animowany, 1200ms pętla
- **Page transition**: domyślnie system (GoRouter)
- **Tap feedback**: `ScaleTransition` 0.92–1.0, 150ms

---

## 8. Ikony

- Używaj `Icons.*` z Material Design
- ⛔ **Zakaz emoji jako ikon UI**
- Rozmiar: `20.r` (małe), `24.r` (standardowe), `32.r` (hero)
- Kolor: zawsze `AppColors.*` — nigdy hardkodowany

---

## 9. Zasady Kodu

### Obowiązkowe
- `const` wszędzie gdzie możliwe
- `dispose()` dla wszystkich `AnimationController`, `TextEditingController`, `ScrollController`
- `AppColors.*` dla 100% kolorów
- `.sp .h .w .r` z ScreenUtil dla 100% wymiarów
- `flutter analyze: 0 issues` po każdej zmianie

### Zakazane
```dart
// ⛔ ZAKAZ
Colors.white
Colors.black
Color(0xFF...)        // bezpośrednio — używaj AppColors.*
fontSize: 14          // bez .sp — używaj 14.sp
height: 50            // bez .h — używaj 50.h
width: 100            // bez .w — używaj 100.w
radius: 12            // bez .r — używaj 12.r
Spinner()             // zamiast Shimmer dla loading
```

### Dopuszczalne wyjątki
```dart
// ✅ OK
Colors.transparent
Colors.black.withValues(alpha: 0.04)   // tylko dla boxShadow
const Color(0xFFFACC15)                // specyficzne kolory bez tokenu (np. żółty streak)
```

---

## 10. Global Screen Rules

Obowiązkowe zasady unifikacji UI:
- **Tło ekranu (Scaffold)**: Zawsze `AppColors.backgroundWhite` (#FFFFFF). Zakaz używania kolorowych teł, np. zielonego.
- **Tytuły ekranów**: Zawsze format: `FontWeight.w800`, `28.sp`, `Colors.black`. Pozycja tytułu w `AppHeader`: `padding: EdgeInsets.only(top: 16.h, left: 20.w, bottom: 8.h)`. Używamy `AppHeader` zamiast standardowego `AppBar`.
- **Karty i kontenery**: Zawsze białe tło `AppColors.backgroundWhite` (#FFFFFF), `borderRadius: BorderRadius.circular(16.r)`. Cień: `BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: Offset(0, 4))`. Brak szarych teł.
- **Akcenty zielone (`AppColors.primary`)**: Rezerwowane tylko dla CTA, ikon nawigacji, progress barów, checkboksów i małych tagów/oznaczeń.

---

## 11. Struktura Pliku Ekranu

```dart
// 1. imports — dart: → flutter: → external → internal
// 2. class XxxScreen extends StatelessWidget / StatefulWidget
// 3. Jeśli StatefulWidget:
//    - initState() z inicjalizacją kontrolerów
//    - dispose() z dispose() WSZYSTKICH kontrolerów
// 4. build():
//    - Scaffold z backgroundColor: AppColors.background
//    - SafeArea
//    - AppHeader (widget, nie inline)
//    - body content
// 5. Prywatne sub-widgety na dole pliku
// 6. flutter analyze: 0 issues
```

---

## 11. Reużywalne Widgety (`lib/core/widgets/`)

| Widget | Plik | Użycie |
|---|---|---|
| `AppHeader` | `app_header.dart` | Nagłówek każdego ekranu |

> Dodawaj tu nowe reużywalne widgety z całej aplikacji.

---

*Ostatnia aktualizacja: 2026-06-07*  
*Źródła: `app_colors.dart`, `app_text_styles.dart`, `app_theme.dart`*
