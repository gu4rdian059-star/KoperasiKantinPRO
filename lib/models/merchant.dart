class Merchant {
  final String id;
  final String name;
  final String category;
  final String username;
  final String password;
  final String startTime;
  final String endTime;
  bool isOpen;
  bool isTempClosed;

  Merchant({
    required this.id,
    required this.name,
    required this.category,
    required this.username,
    required this.password,
    required this.startTime,
    required this.endTime,
    this.isOpen = true,
    this.isTempClosed = false,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      isOpen: json['is_open'] as bool? ?? true,
      isTempClosed: json['is_temp_closed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'username': username,
      'password': password,
      'start_time': startTime,
      'end_time': endTime,
      'is_open': isOpen,
      'is_temp_closed': isTempClosed,
    };
  }

  Merchant copyWith({
    bool? isOpen,
    bool? isTempClosed,
  }) {
    return Merchant(
      id: this.id,
      name: this.name,
      category: this.category,
      username: this.username,
      password: this.password,
      startTime: this.startTime,
      endTime: this.endTime,
      isOpen: isOpen ?? this.isOpen,
      isTempClosed: isTempClosed ?? this.isTempClosed,
    );
  }
}
