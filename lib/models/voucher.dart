class Voucher {
  final String code;
  final String type; // 'Subsidi', 'Diskon', 'Hadiah'
  final double value; // nominal discount or percentage (0-100)
  final String description;
  final DateTime expiryDate;
  final String? merchantId; // if null, valid across all merchants

  Voucher({
    required this.code,
    required this.type,
    required this.value,
    required this.description,
    required this.expiryDate,
    this.merchantId,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      code: json['code'] as String,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      description: json['description'] as String,
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      merchantId: json['merchant_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'type': type,
      'value': value,
      'description': description,
      'expiry_date': expiryDate.toIso8601String(),
      'merchant_id': merchantId,
    };
  }

  bool get isExpired {
    return DateTime.now().isAfter(expiryDate);
  }
}
