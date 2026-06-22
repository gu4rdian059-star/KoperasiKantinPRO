class Parent {
  final String phone;
  final String name;
  String password;
  List<String> linkedStudentNises;
  Map<String, bool> notificationSettings; // Key: type, Value: isEnabled

  Parent({
    required this.phone,
    required this.name,
    required this.password,
    required this.linkedStudentNises,
    required this.notificationSettings,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    final rawSettings = json['notification_settings'];
    Map<String, bool> settings = {
      'transaksi': true,
      'saldo_rendah': true,
      'alergen': true,
      'rekap': true,
      'topup': true,
    };
    if (rawSettings is Map) {
      rawSettings.forEach((k, v) {
        settings[k.toString()] = v == true || v == 'true';
      });
    }
    return Parent(
      phone: json['phone'] as String,
      name: json['name'] as String,
      password: json['password'] as String,
      linkedStudentNises: List<String>.from(json['linked_student_nises'] ?? []),
      notificationSettings: settings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'name': name,
      'password': password,
      'linked_student_nises': linkedStudentNises,
      'notification_settings': notificationSettings,
    };
  }

  Parent copyWith({
    String? password,
    List<String>? linkedStudentNises,
    Map<String, bool>? notificationSettings,
  }) {
    return Parent(
      phone: this.phone,
      name: this.name,
      password: password ?? this.password,
      linkedStudentNises: linkedStudentNises ?? List.from(this.linkedStudentNises),
      notificationSettings: notificationSettings ?? Map.from(this.notificationSettings),
    );
  }
}
