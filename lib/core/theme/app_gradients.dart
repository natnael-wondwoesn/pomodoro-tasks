import 'package:flutter/material.dart';

class AppGradients {
  AppGradients._();

  // Background gradients
  static const LinearGradient backgroundLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5E6D3), Color(0xFFFDF2E9)],
  );

  static const LinearGradient backgroundDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2C1F14), Color(0xFF1A1208)],
  );

  // State gradients (light)
  static const LinearGradient focusLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x33C47F52), Color(0x1AD4956A)],
  );

  static const LinearGradient breakLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x337B9E6B), Color(0x1A7B9E6B)],
  );

  static const LinearGradient surfaceLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xB3FFFFFF), Color(0x66FFFFFF)],
  );

  // State gradients (dark)
  static const LinearGradient focusDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x33D4956A), Color(0x1AC47F52)],
  );

  static const LinearGradient breakDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x337B9E6B), Color(0x1A5A7A4B)],
  );

  static const LinearGradient surfaceDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x14FFFFFF), Color(0x0AFFFFFF)],
  );

  // Accent gradient (for buttons, timer ring)
  static const LinearGradient accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC47F52), Color(0xFFD4956A)],
  );

  // Partner gradient
  static const LinearGradient partner = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7B9E6B), Color(0xFF9AB88A)],
  );
}
