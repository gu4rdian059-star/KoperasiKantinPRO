class TransactionModel {
  final String id;
  final String studentNis;
  final String studentName;
  final String merchantId; // can be empty or 'SYSTEM' for Top Up
  final String merchantName;
  final String itemsSummary;
  final double amount;
  final String? appliedVoucherCode;
  final String type; // 'Pembelian', 'Top Up VA', 'Top Up QRIS', 'Top Up Minimarket', 'Top Up Manual'
  String status; // 'Selesai', 'Menunggu', 'Dibatalkan'
  final bool hasAllergenWarning;
  final List<String> triggeredAllergenCodes;
  final DateTime timestamp;
  final String? qrToken;
  final DateTime? qrTokenExpiry;

  TransactionModel({
    required this.id,
    required this.studentNis,
    required this.studentName,
    required this.merchantId,
    required this.merchantName,
    required this.itemsSummary,
    required this.amount,
    this.appliedVoucherCode,
    required this.type,
    required this.status,
    this.hasAllergenWarning = false,
    required this.triggeredAllergenCodes,
    required this.timestamp,
    this.qrToken,
    this.qrTokenExpiry,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      studentNis: json['student_nis'] as String,
      studentName: json['student_name'] as String,
      merchantId: json['merchant_id'] as String,
      merchantName: json['merchant_name'] as String,
      itemsSummary: json['items_summary'] as String,
      amount: (json['amount'] as num).toDouble(),
      appliedVoucherCode: json['applied_voucher_code'] as String?,
      type: json['type'] as String,
      status: json['status'] as String,
      hasAllergenWarning: json['has_allergen_warning'] as bool? ?? false,
      triggeredAllergenCodes: List<String>.from(json['triggered_allergen_codes'] ?? []),
      timestamp: DateTime.parse(json['timestamp'] as String),
      qrToken: json['qr_token'] as String?,
      qrTokenExpiry: json['qr_token_expiry'] != null
          ? DateTime.parse(json['qr_token_expiry'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_nis': studentNis,
      'student_name': studentName,
      'merchant_id': merchantId,
      'merchant_name': merchantName,
      'items_summary': itemsSummary,
      'amount': amount,
      'applied_voucher_code': appliedVoucherCode,
      'type': type,
      'status': status,
      'has_allergen_warning': hasAllergenWarning,
      'triggered_allergen_codes': triggeredAllergenCodes,
      'timestamp': timestamp.toIso8601String(),
      'qr_token': qrToken,
      'qr_token_expiry': qrTokenExpiry?.toIso8601String(),
    };
  }

  TransactionModel copyWith({
    String? status,
  }) {
    return TransactionModel(
      id: this.id,
      studentNis: this.studentNis,
      studentName: this.studentName,
      merchantId: this.merchantId,
      merchantName: this.merchantName,
      itemsSummary: this.itemsSummary,
      amount: this.amount,
      appliedVoucherCode: this.appliedVoucherCode,
      type: this.type,
      status: status ?? this.status,
      hasAllergenWarning: this.hasAllergenWarning,
      triggeredAllergenCodes: this.triggeredAllergenCodes,
      timestamp: this.timestamp,
      qrToken: this.qrToken,
      qrTokenExpiry: this.qrTokenExpiry,
    );
  }
}
