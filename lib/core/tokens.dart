import 'package:flutter/material.dart';

class C {
  static const white = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF8FAFC);
  static const border = Color(0xFFE2E8F0);
  static const inputBorder = Color(0xFFCBD5E1);
  static const navy = Color(0xFF0B192C);
  static const orange = Color(0xFFFF9F1C);
  static const orangeTint = Color(0xFFFFF1DD);
  static const green = Color(0xFF10B981);
  static const red = Color(0xFFDC2626);
  static const redTint = Color(0xFFFEF2F2);
  static const slate = Color(0xFF475569);
}

class T {
  static const _f = 'Inter';
  static const display = TextStyle(
      fontFamily: _f,
      fontSize: 24,
      height: 30 / 24,
      fontWeight: FontWeight.w700,
      color: C.navy);
  static const h1 = TextStyle(
      fontFamily: _f,
      fontSize: 22,
      height: 27.5 / 22,
      fontWeight: FontWeight.w700,
      color: C.navy);
  static const h2 = TextStyle(
      fontFamily: _f,
      fontSize: 13,
      height: 16.25 / 13,
      fontWeight: FontWeight.w600,
      color: C.navy);
  static const body = TextStyle(
      fontFamily: _f,
      fontSize: 14,
      height: 1.4,
      fontWeight: FontWeight.w400,
      color: C.navy);
  static const bodySlate = TextStyle(
      fontFamily: _f,
      fontSize: 14,
      height: 1.4,
      fontWeight: FontWeight.w400,
      color: C.slate);
  static const caption = TextStyle(
      fontFamily: _f,
      fontSize: 12,
      height: 1.4,
      fontWeight: FontWeight.w400,
      color: C.slate);
  static const label = TextStyle(
      fontFamily: _f,
      fontSize: 15,
      height: 22.5 / 15,
      fontWeight: FontWeight.w600,
      color: C.navy);
  static const fieldLabel = TextStyle(
      fontFamily: _f,
      fontSize: 12,
      letterSpacing: 0.6,
      fontWeight: FontWeight.w700,
      color: C.navy);
}

ThemeData appTheme() => ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: C.white,
      colorScheme: ColorScheme.fromSeed(seedColor: C.navy, primary: C.navy),
      appBarTheme: const AppBarTheme(
        backgroundColor: C.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: C.navy,
        titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: C.navy),
      ),
    );
