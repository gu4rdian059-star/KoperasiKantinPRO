import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFFDBEAFE);
  
  // Success Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFC8E6C9);
  
  // Warning Colors
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFE082);
  
  // Error Colors
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFEF9A9A);
  
  // Neutral Colors
  static const Color neutral900 = Color(0xFF111827);
  static const Color neutral800 = Color(0xFF1F2937);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral50 = Color(0xFFFAFAFA);
  
  // White & Black
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  // Status Colors for Balance
  static const Color balanceCritical = Color(0xFFF44336); // Red - < Rp 5.000
  static const Color balanceWarning = Color(0xFFFFC107); // Yellow - Rp 5.000-20.000
  static const Color balanceGood = Color(0xFF4CAF50); // Green - > Rp 20.000
  
  // Status Colors for Stock
  static const Color stockAvailable = Color(0xFF4CAF50); // Green - > 5 pcs
  static const Color stockLow = Color(0xFFFFC107); // Yellow - 1-5 pcs
  static const Color stockOutOfStock = Color(0xFFF44336); // Red - 0 pcs
  
  // Merchant Status
  static const Color merchantOpen = Color(0xFF4CAF50); // Green
  static const Color merchantClosed = Color(0xFF9E9E9E); // Gray
  static const Color merchantTemporarilyClosed = Color(0xFFFFC107); // Yellow
}
