class Student {
  final String nis;
  String pin;
  final String name;
  final String className;
  double balance;
  double dailySpendingLimit; // 0.0 means no limit
  double remainderDailyLimit;
  List<String> allergens; // codes: SF, ML, EG, NT, GL, SY, CH
  List<String> vouchers; // codes of owned vouchers
  bool isLinked;
  String linkingCode;
  bool isBlocked;

  Student({
    required this.nis,
    required this.pin,
    required this.name,
    required this.className,
    required this.balance,
    this.dailySpendingLimit = 0.0,
    required this.remainderDailyLimit,
    required this.allergens,
    required this.vouchers,
    this.isLinked = false,
    required this.linkingCode,
    this.isBlocked = false,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      nis: json['nis'] as String,
      pin: json['pin'] as String,
      name: json['name'] as String,
      className: json['class_name'] as String,
      balance: (json['balance'] as num).toDouble(),
      dailySpendingLimit: (json['daily_spending_limit'] as num? ?? 0).toDouble(),
      remainderDailyLimit: (json['remainder_daily_limit'] as num? ?? 0).toDouble(),
      allergens: List<String>.from(json['allergens'] ?? []),
      vouchers: List<String>.from(json['vouchers'] ?? []),
      isLinked: json['is_linked'] as bool? ?? false,
      linkingCode: json['linking_code'] as String? ?? '',
      isBlocked: json['is_blocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nis': nis,
      'pin': pin,
      'name': name,
      'class_name': className,
      'balance': balance,
      'daily_spending_limit': dailySpendingLimit,
      'remainder_daily_limit': remainderDailyLimit,
      'allergens': allergens,
      'vouchers': vouchers,
      'is_linked': isLinked,
      'linking_code': linkingCode,
      'is_blocked': isBlocked,
    };
  }

  Student copyWith({
    String? pin,
    double? balance,
    double? dailySpendingLimit,
    double? remainderDailyLimit,
    List<String>? allergens,
    List<String>? vouchers,
    bool? isLinked,
    String? linkingCode,
    bool? isBlocked,
  }) {
    return Student(
      nis: this.nis,
      pin: pin ?? this.pin,
      name: this.name,
      className: this.className,
      balance: balance ?? this.balance,
      dailySpendingLimit: dailySpendingLimit ?? this.dailySpendingLimit,
      remainderDailyLimit: remainderDailyLimit ?? this.remainderDailyLimit,
      allergens: allergens ?? List.from(this.allergens),
      vouchers: vouchers ?? List.from(this.vouchers),
      isLinked: isLinked ?? this.isLinked,
      linkingCode: linkingCode ?? this.linkingCode,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
