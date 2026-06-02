import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // ─── TŁA (BACKGROUNDS) ──────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F5F5);       // Jasnoszare tło główne
  static const Color backgroundWhite = Color(0xFFFFFFFF);  // Białe tła kart i elementów
  static const Color backgroundDark = Color(0xFF1F2937);   // Ciemnoszare karty (np. dark mode, przyciski)
  static const Color surface = Color(0xFFFFFFFF);          // Powierzchnia kontenerów

  // ─── PRIMARY (ZIELONY AKCENT) ──────────────────────────────────────────────────
  static const Color primary = Color(0xFF22C55E);          // Główny zielony
  static const Color primaryDark = Color(0xFF16A34A);      // Ciemniejszy zielony (hover, pressed)
  static const Color primaryLight = Color(0xFFDCFCE7);     // Bardzo jasny zielony (tła ikon, tagi)

  // ─── SECONDARY (NIEBIESKI AKCENT) ──────────────────────────────────────────────
  static const Color secondary = Color(0xFF3B82F6);        // Akcent niebieski
  static const Color secondaryLight = Color(0xFFEFF6FF);   // Jasny niebieski (tła ikon, akcenty)

  // ─── STATUSY ───────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);            // Czerwony (przeterminowania, błędy)
  static const Color errorLight = Color(0xFFFEE2E2);       // Jasnoczerwony (tła błędów)
  static const Color warning = Color(0xFFF59E0B);          // Pomarańczowy (ostrzeżenia, streak)
  static const Color warningLight = Color(0xFFFFF7ED);     // Jasnopomarańczowy (tła ostrzeżeń)
  static const Color success = Color(0xFF22C55E);          // Sukces (zielony primary)

  // ─── KOLORY TEKSTÓW ────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF111827);      // Główny tekst (prawie czarny)
  static const Color textSecondary = Color(0xFF6B7280);    // Tekst drugorzędny (szary)
  static const Color textMuted = Color(0xFF9CA3AF);        // Tekst wyciszony (jasnoszary)
  static const Color textWhite = Color(0xFFFFFFFF);        // Tekst biały

  // ─── MAKROSKŁADNIKI (MACRONUTRIENTS) ─────────────────────────────────────────────
  static const Color proteinColor = Color(0xFF3B82F6);     // Białko (niebieski)
  static const Color carbsColor = Color(0xFF22C55E);       // Węglowodany (zielony)
  static const Color fatColor = Color(0xFFF97316);         // Tłuszcze (pomarańczowy)

  // ─── DOLNA NAWIGACJA (BOTTOM NAVIGATION) ───────────────────────────────────────
  static const Color bottomNavBg = Color(0xFFFFFFFF);      // Tło paska nawigacji
  static const Color bottomNavSelected = Color(0xFF111827); // Kolor aktywnego tabu
  static const Color bottomNavUnselected = Color(0xFF9CA3AF); // Kolor nieaktywnego tabu

  // ─── RAMKI I LINIE (BORDERS & DIVIDERS) ────────────────────────────────────────
  static const Color border = Color(0xFFE5E7EB);           // Standardowa ramka
  static const Color borderLight = Color(0xFFF3F4F6);      // Bardzo jasna linia
  static const Color borderMedium = Color(0xFFD1D5DB);     // Średnia ramka szara

  // ─── AMBER (SPIŻARNIA / EXPIRY) ──────────────────────────────────────────────
  static const Color warningDark = Color(0xFFD97706);      // Amber ciemny (expiry pilne)
  static const Color warningBorder = Color(0xFFFED7AA);    // Amber ramka (expiry ostrzeżenie)

  // ─── INFO (SKY BLUE — KARTY PODPOWIEDZI) ─────────────────────────────────────
  static const Color infoLight = Color(0xFFF0F9FF);        // Sky blue tło
  static const Color infoBorder = Color(0xFFBAE6FD);       // Sky blue ramka

  // ─── INDIGO ───────────────────────────────────────────────────────────────────
  static const Color indigoLight = Color(0xFFEEF2FF);      // Jasne indigo (zaznaczony chip)

  // ─── SUCCESS STATES (ZGODNOŚĆ SKŁADNIKÓW) ────────────────────────────────────
  static const Color successLight = Color(0xFFE8F5E9);     // Bardzo jasny zielony bg
  static const Color successBorder = Color(0xFFA5D6A7);    // Zielona ramka zgodności
  static const Color successDark = Color(0xFF2E7D32);      // Ciemny zielony tekst
  static const Color successDeepDark = Color(0xFF1B5E20);  // Bardzo ciemny zielony

  // ─── MISMATCH STATES (NIEZGODNOŚĆ — EXTRACT SCREEN) ─────────────────────────
  static const Color mismatchLight = Color(0xFFFFF3E0);    // Jasny pomarańczowy bg
  static const Color mismatchBorder = Color(0xFFFFCC80);   // Bursztynowa ramka
  static const Color mismatchText = Color(0xFFE65100);     // Ciemny pomarańczowy tekst
  static const Color mismatchTextDark = Color(0xFFF57C00); // Pomarańczowy tekst

  // ─── CIEMNE TŁA ────────────────────────────────────────────────────────────
  static const Color backgroundNavy = Color(0xFF1A1F2E);   // Ciemny granat (paywall dark)
}
