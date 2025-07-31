// File: lib/theme/colors.dart
// Defines the centralized color palette for the Smart Warehouse app.

import 'package:flutter/material.dart';

class AppColors {
  // Scaffold and surface background
  static const Color background = Color(0xFF414643);

  // Tile, chart, and modal backgrounds
  static const Color card = Color(0xFF2D2F2C);

  // Primary action elements (e.g., buttons)
  static const Color primary = Color(0xFF3B7B7A);

  // Highlight and alert colors
  static const Color accent = Color(0xFFC94B4B);

  // Text on dark backgrounds
  static const Color text = Color(0xFFEAE3C3);

  // Secondary accent for charts
  static const Color secondaryAccent = Color(0xFF9BB6A1);

  // Borders and dividers
  static const Color divider = Color(0xFF666666);

  // Semi-transparent variants
  static Color primaryLight = primary.withAlpha((0.7 * 255).round());
  static Color accentLight = accent.withAlpha((0.7 * 255).round());
  static Color backgroundDim = background.withAlpha((0.9 * 255).round());

  // Status indicators
  static const Color warning = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
}
