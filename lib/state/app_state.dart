import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student.dart';
import '../models/parent.dart';
import '../models/merchant.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../models/voucher.dart';
import '../services/mock_database.dart';

class AppState extends ChangeNotifier {
  // Session State
  String? currentRole; // 'siswa', 'ortu', 'merchant', 'admin'
  dynamic currentUser; // Student, Parent, Merchant, String (admin)

  // Loading State
  bool isLoading = true;
  String? loadingError;

  // System Lists
  List<Student> students = [];
  List<Parent> parents = [];
  List<Merchant> merchants = [];
  List<Product> products = [];
  List<TransactionModel> transactions = [];
  List<Voucher> vouchers = [];

  // Notifications Log
  List<Map<String, dynamic>> systemNotifications = [];

  // Supabase client shorthand
  SupabaseClient get _db => Supabase.instance.client;

  AppState() {
    _initFromSupabase();
  }

  // ─── INITIALIZATION ──────────────────────────────────────────────────────

  Future<void> _initFromSupabase() async {
    isLoading = true;
    loadingError = null;
    notifyListeners();

    try {
      // Load all tables in parallel
      final results = await Future.wait([
        _db.from('students').select(),
        _db.from('parents').select(),
        _db.from('merchants').select(),
        _db.from('products').select(),
        _db.from('transactions').select().order('timestamp', ascending: false),
        _db.from('vouchers').select(),
      ]);

      final rawStudents = results[0] as List;
      final rawParents = results[1] as List;
      final rawMerchants = results[2] as List;
      final rawProducts = results[3] as List;
      final rawTransactions = results[4] as List;
      final rawVouchers = results[5] as List;

      // If database is completely empty, seed with demo data
      if (rawStudents.isEmpty && rawMerchants.isEmpty) {
        await _seedDemoData();
        isLoading = false;
        notifyListeners();
        return;
      }

      students = rawStudents.map((j) => Student.fromJson(j)).toList();
      parents = rawParents.map((j) => Parent.fromJson(j)).toList();
      merchants = rawMerchants.map((j) => Merchant.fromJson(j)).toList();
      products = rawProducts.map((j) => Product.fromJson(j)).toList();
      transactions = rawTransactions.map((j) => TransactionModel.fromJson(j)).toList();
      vouchers = rawVouchers.map((j) => Voucher.fromJson(j)).toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      // Fallback to mock data if Supabase fails
      debugPrint('Supabase load failed, using mock data: $e');
      _loadMockData();
      isLoading = false;
      loadingError = 'Menggunakan data lokal (offline mode)';
      notifyListeners();
    }
  }

  void _loadMockData() {
    students = List.from(MockDatabase.students);
    parents = List.from(MockDatabase.parents);
    merchants = List.from(MockDatabase.merchants);
    products = List.from(MockDatabase.products);
    transactions = List.from(MockDatabase.transactions);
    vouchers = List.from(MockDatabase.vouchers);
  }

  Future<void> _seedDemoData() async {
    debugPrint('Seeding demo data to Supabase...');
    try {
      // Seed students
      for (final s in MockDatabase.students) {
        await _db.from('students').upsert(s.toJson());
      }
      // Seed parents
      for (final p in MockDatabase.parents) {
        await _db.from('parents').upsert(p.toJson());
      }
      // Seed merchants
      for (final m in MockDatabase.merchants) {
        await _db.from('merchants').upsert(m.toJson());
      }
      // Seed products
      for (final prod in MockDatabase.products) {
        await _db.from('products').upsert(prod.toJson());
      }
      // Seed vouchers
      for (final v in MockDatabase.vouchers) {
        await _db.from('vouchers').upsert(v.toJson());
      }
      // Seed transactions
      for (final tx in MockDatabase.transactions) {
        await _db.from('transactions').upsert(tx.toJson());
      }

      // Reload from Supabase after seeding
      await _initFromSupabase();
    } catch (e) {
      debugPrint('Seeding failed: $e');
      _loadMockData();
    }
  }

  // Reload all data from Supabase
  Future<void> refreshData() async {
    await _initFromSupabase();
  }

  // ─── AUTHENTICATION ───────────────────────────────────────────────────────

  Future<void> loginSiswa(String nis, String pin) async {
    try {
      final res = await _db.from('students').select().eq('nis', nis).maybeSingle();
      if (res == null) throw Exception("NIS tidak ditemukan dalam sistem");

      final student = Student.fromJson(res);
      if (student.isBlocked) throw Exception("Akun Anda dinonaktifkan, hubungi admin");
      if (student.pin != pin) throw Exception("PIN yang Anda masukkan salah");

      currentRole = 'siswa';
      currentUser = student;
      notifyListeners();
    } catch (e) {
      debugPrint('Supabase loginSiswa error: $e. Using offline fallback...');
      final studentIndex = students.indexWhere((s) => s.nis == nis);
      if (studentIndex == -1) throw Exception("NIS tidak ditemukan dalam sistem");

      final student = students[studentIndex];
      if (student.isBlocked) throw Exception("Akun Anda dinonaktifkan, hubungi admin");
      if (student.pin != pin) throw Exception("PIN yang Anda masukkan salah");

      currentRole = 'siswa';
      currentUser = student;
      notifyListeners();
    }
  }

  Future<void> loginParent(String phone, String password) async {
    try {
      final res = await _db.from('parents').select().eq('phone', phone).maybeSingle();
      if (res == null) throw Exception("Nomor HP tidak terdaftar");

      final parent = Parent.fromJson(res);
      if (parent.password != password) throw Exception("Kata sandi yang Anda masukkan salah");

      currentRole = 'ortu';
      currentUser = parent;
      notifyListeners();
    } catch (e) {
      debugPrint('Supabase loginParent error: $e. Using offline fallback...');
      final parentIndex = parents.indexWhere((p) => p.phone == phone);
      if (parentIndex == -1) throw Exception("Nomor HP tidak terdaftar");

      final parent = parents[parentIndex];
      if (parent.password != password) throw Exception("Kata sandi yang Anda masukkan salah");

      currentRole = 'ortu';
      currentUser = parent;
      notifyListeners();
    }
  }

  Future<void> loginMerchant(String username, String password) async {
    try {
      final res = await _db.from('merchants').select().eq('username', username).maybeSingle();
      if (res == null) throw Exception("Username atau password salah");

      final merchant = Merchant.fromJson(res);
      if (merchant.isTempClosed) throw Exception("Akun Anda dinonaktifkan, hubungi admin");
      if (merchant.password != password) throw Exception("Username atau password salah");

      currentRole = 'merchant';
      currentUser = merchant;
      notifyListeners();
    } catch (e) {
      debugPrint('Supabase loginMerchant error: $e. Using offline fallback...');
      final merchantIndex = merchants.indexWhere((m) => m.username == username);
      if (merchantIndex == -1) throw Exception("Username atau password salah");

      final merchant = merchants[merchantIndex];
      if (merchant.isTempClosed) throw Exception("Akun Anda dinonaktifkan, hubungi admin");
      if (merchant.password != password) throw Exception("Username atau password salah");

      currentRole = 'merchant';
      currentUser = merchant;
      notifyListeners();
    }
  }

  void loginAdmin(String username, String password) {
    if (username == 'admin' && password == 'password') {
      currentRole = 'admin';
      currentUser = 'Admin SekolahPRO';
      notifyListeners();
    } else {
      throw Exception("Username atau password salah");
    }
  }

  void registerParent(String phone, String name, String password, String childLinkingCode) {
    final studentIndex = students.indexWhere((s) => s.linkingCode == childLinkingCode);
    if (studentIndex == -1) throw Exception("Kode linking anak tidak ditemukan");

    final student = students[studentIndex];
    final parentIndex = parents.indexWhere((p) => p.phone == phone);
    if (parentIndex != -1) throw Exception("Nomor HP ini sudah terdaftar sebagai Orang Tua");

    final newParent = Parent(
      phone: phone,
      name: name,
      password: password,
      linkedStudentNises: [student.nis],
      notificationSettings: {
        'transaksi': true,
        'saldo_rendah': true,
        'alergen': true,
        'rekap': true,
        'topup': true,
      },
    );

    parents.add(newParent);
    student.isLinked = true;

    // Write to Supabase async in fire-and-forget style
    () async {
      try {
        await _db.from('parents').upsert(newParent.toJson());
        await _db.from('students').upsert(student.toJson());
      } catch (e) {
        debugPrint('registerParent Supabase error: $e');
      }
    }();

    currentRole = 'ortu';
    currentUser = newParent;
    notifyListeners();
  }

  void logout() {
    currentRole = null;
    currentUser = null;
    notifyListeners();
  }

  // ─── SISWA PORTAL ─────────────────────────────────────────────────────────

  void changeStudentPin(String nis, String newPin) {
    final idx = students.indexWhere((s) => s.nis == nis);
    if (idx != -1) {
      students[idx].pin = newPin;
      if (currentRole == 'siswa' && currentUser.nis == nis) {
        currentUser = students[idx];
      }
      _db.from('students')
          .update({'pin': newPin}).eq('nis', nis)
          .catchError((e) => debugPrint('changeStudentPin error: $e'));
      notifyListeners();
    }
  }

  List<String> checkCartForAllergens(String studentNis, List<Product> cartProducts) {
    final student = students.firstWhere((s) => s.nis == studentNis);
    List<String> triggeredAllergens = [];
    for (var prod in cartProducts) {
      for (var allergen in prod.allergens) {
        if (student.allergens.contains(allergen) && !triggeredAllergens.contains(allergen)) {
          triggeredAllergens.add(allergen);
        }
      }
    }
    return triggeredAllergens;
  }

  TransactionModel initiatePurchase({
    required String studentNis,
    required String merchantId,
    required List<Product> cartItems,
    required List<int> quantities,
    String? voucherCode,
    bool bypassAllergen = false,
  }) {
    final student = students.firstWhere((s) => s.nis == studentNis);
    final merchant = merchants.firstWhere((m) => m.id == merchantId);

    // Calculate price
    double subtotal = 0.0;
    for (int i = 0; i < cartItems.length; i++) {
      subtotal += cartItems[i].price * quantities[i];
    }

    // Apply voucher
    double discount = 0.0;
    if (voucherCode != null && voucherCode.isNotEmpty) {
      final voucherIdx = vouchers.indexWhere((v) => v.code == voucherCode && !v.isExpired);
      if (voucherIdx != -1) {
        final voucher = vouchers[voucherIdx];
        if (voucher.type == 'Diskon') {
          discount = subtotal * (voucher.value / 100);
        } else if (voucher.type == 'Subsidi' || voucher.type == 'Hadiah') {
          discount = voucher.value;
        }
      }
    }

    double totalAmount = subtotal - discount;
    if (totalAmount < 0) totalAmount = 0.0;

    // Verify stock
    for (int i = 0; i < cartItems.length; i++) {
      final prodIdx = products.indexWhere((p) => p.id == cartItems[i].id);
      if (prodIdx == -1 || products[prodIdx].stock < quantities[i]) {
        throw Exception("Stok produk ${cartItems[i].name} tidak mencukupi");
      }
    }

    // Verify balance
    if (student.balance < totalAmount) {
      throw Exception("Saldo Anda tidak mencukupi untuk melakukan transaksi ini");
    }

    // Verify spending limit
    if (student.dailySpendingLimit > 0.0 && student.remainderDailyLimit < totalAmount) {
      throw Exception("Transaksi melebihi batas pengeluaran harian Anda!");
    }

    // Check allergens
    final allergensTriggered = checkCartForAllergens(studentNis, cartItems);
    if (allergensTriggered.isNotEmpty && !bypassAllergen) {
      throw AllergenWarningException(allergensTriggered);
    }

    // Deduct balance and limits
    student.balance -= totalAmount;
    if (student.dailySpendingLimit > 0.0) {
      student.remainderDailyLimit -= totalAmount;
    }

    // Deduct stock
    for (int i = 0; i < cartItems.length; i++) {
      final prodIdx = products.indexWhere((p) => p.id == cartItems[i].id);
      if (prodIdx != -1) {
        products[prodIdx].stock -= quantities[i];
      }
    }

    // Generate token
    final String token = _generateRandomToken();
    final DateTime expiry = DateTime.now().add(const Duration(minutes: 30));

    final summaryList = <String>[];
    for (int i = 0; i < cartItems.length; i++) {
      summaryList.add("${quantities[i]}x ${cartItems[i].name}");
    }

    final newTx = TransactionModel(
      id: 'TX${Random().nextInt(90000) + 10000}',
      studentNis: student.nis,
      studentName: student.name,
      merchantId: merchant.id,
      merchantName: merchant.name,
      itemsSummary: summaryList.join(", "),
      amount: totalAmount,
      appliedVoucherCode: voucherCode,
      type: 'Pembelian',
      status: 'Menunggu',
      hasAllergenWarning: allergensTriggered.isNotEmpty,
      triggeredAllergenCodes: allergensTriggered,
      timestamp: DateTime.now(),
      qrToken: token,
      qrTokenExpiry: expiry,
    );

    transactions.insert(0, newTx);

    // Persist to Supabase
    _db.from('transactions').insert(newTx.toJson())
        .catchError((e) => debugPrint('initiatePurchase tx error: $e'));
    _db.from('students').update({
      'balance': student.balance,
      'remainder_daily_limit': student.remainderDailyLimit,
    }).eq('nis', student.nis)
        .catchError((e) => debugPrint('initiatePurchase student update error: $e'));
    for (int i = 0; i < cartItems.length; i++) {
      final prodIdx = products.indexWhere((p) => p.id == cartItems[i].id);
      if (prodIdx != -1) {
        _db.from('products').update({'stock': products[prodIdx].stock})
            .eq('id', cartItems[i].id)
            .catchError((e) => debugPrint('initiatePurchase stock update error: $e'));
      }
    }

    if (allergensTriggered.isNotEmpty) {
      _triggerAllergenAlertNotification(student, merchant.name, summaryList.join(", "), allergensTriggered);
    }
    _checkLowBalanceAlert(student);

    if (currentRole == 'siswa' && currentUser.nis == student.nis) {
      currentUser = student;
    }

    notifyListeners();
    return newTx;
  }

  // ─── MERCHANT PORTAL ──────────────────────────────────────────────────────

  TransactionModel verifyAndProcessToken(String merchantId, String tokenCode) {
    final txIdx = transactions.indexWhere(
      (tx) => tx.qrToken == tokenCode && tx.merchantId == merchantId && tx.status == 'Menunggu',
    );
    if (txIdx == -1) throw Exception("Token tidak valid atau tidak ditemukan");

    final tx = transactions[txIdx];
    if (tx.qrTokenExpiry != null && DateTime.now().isAfter(tx.qrTokenExpiry!)) {
      tx.status = 'Dibatalkan';
      _db.from('transactions').update({'status': 'Dibatalkan'})
          .eq('id', tx.id)
          .catchError((e) => debugPrint('verifyToken cancel error: $e'));
      notifyListeners();
      throw Exception("Token sudah kadaluarsa (melebihi 30 menit)");
    }

    tx.status = 'Selesai';
    _db.from('transactions').update({'status': 'Selesai'})
        .eq('id', tx.id)
        .catchError((e) => debugPrint('verifyToken complete error: $e'));

    final student = students.firstWhere((s) => s.nis == tx.studentNis);
    _sendParentTransactionNotification(student, tx);

    notifyListeners();
    return tx;
  }

  void addOrUpdateProduct({
    required String merchantId,
    String? productId,
    required String name,
    required double price,
    required int stock,
    required String category,
    required List<String> allergens,
    required String imageUrl,
  }) {
    if (productId != null) {
      final idx = products.indexWhere((p) => p.id == productId);
      if (idx != -1) {
        products[idx] = Product(
          id: productId,
          merchantId: merchantId,
          name: name,
          price: price,
          stock: stock,
          category: category,
          allergens: allergens,
          imageUrl: imageUrl,
        );
        _db.from('products').upsert(products[idx].toJson())
            .catchError((e) => debugPrint('updateProduct error: $e'));
      }
    } else {
      final newProd = Product(
        id: 'P${Random().nextInt(9000) + 1000}',
        merchantId: merchantId,
        name: name,
        price: price,
        stock: stock,
        category: category,
        allergens: allergens,
        imageUrl: imageUrl.isNotEmpty
            ? imageUrl
            : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200',
      );
      products.add(newProd);
      _db.from('products').insert(newProd.toJson())
          .catchError((e) => debugPrint('addProduct error: $e'));
    }
    notifyListeners();
  }

  void deleteProduct(String productId) {
    products.removeWhere((p) => p.id == productId);
    _db.from('products').delete().eq('id', productId)
        .catchError((e) => debugPrint('deleteProduct error: $e'));
    notifyListeners();
  }

  void updateProductStock(String productId, int newStock) {
    final idx = products.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      products[idx].stock = newStock;
      _db.from('products').update({'stock': newStock}).eq('id', productId)
          .catchError((e) => debugPrint('updateStock error: $e'));
      notifyListeners();
    }
  }

  // ─── PARENT PORTAL ────────────────────────────────────────────────────────

  void updateChildSpendingLimit(String studentNis, double limit) {
    final idx = students.indexWhere((s) => s.nis == studentNis);
    if (idx != -1) {
      students[idx].dailySpendingLimit = limit;
      students[idx].remainderDailyLimit = limit;
      _db.from('students').update({
        'daily_spending_limit': limit,
        'remainder_daily_limit': limit,
      }).eq('nis', studentNis)
          .catchError((e) => debugPrint('updateSpendingLimit error: $e'));
      notifyListeners();
    }
  }

  void updateChildAllergens(String studentNis, List<String> allergenCodes) {
    final idx = students.indexWhere((s) => s.nis == studentNis);
    if (idx != -1) {
      students[idx].allergens = allergenCodes;
      _db.from('students').update({'allergens': allergenCodes}).eq('nis', studentNis)
          .catchError((e) => debugPrint('updateAllergens error: $e'));
      notifyListeners();
    }
  }

  void updateParentNotificationSetting(String phone, String key, bool value) {
    final idx = parents.indexWhere((p) => p.phone == phone);
    if (idx != -1) {
      parents[idx].notificationSettings[key] = value;
      _db.from('parents').update({
        'notification_settings': parents[idx].notificationSettings,
      }).eq('phone', phone)
          .catchError((e) => debugPrint('updateNotificationSetting error: $e'));
      if (currentRole == 'ortu' && currentUser.phone == phone) {
        currentUser = parents[idx];
      }
      notifyListeners();
    }
  }

  void linkChildAccount(String phone, String linkingCode) {
    final studentIdx = students.indexWhere((s) => s.linkingCode == linkingCode);
    if (studentIdx == -1) throw Exception("Kode linking anak tidak ditemukan");

    final student = students[studentIdx];
    final parentIdx = parents.indexWhere((p) => p.phone == phone);

    if (parentIdx != -1) {
      final p = parents[parentIdx];
      if (p.linkedStudentNises.contains(student.nis)) {
        throw Exception("Anak ini sudah terhubung dengan akun Anda");
      }
      if (p.linkedStudentNises.length >= 5) {
        throw Exception("Maksimal 5 akun anak yang dapat terhubung");
      }
      p.linkedStudentNises.add(student.nis);
      student.isLinked = true;

      _db.from('parents').update({'linked_student_nises': p.linkedStudentNises})
          .eq('phone', phone)
          .catchError((e) => debugPrint('linkChild parent error: $e'));
      _db.from('students').update({'is_linked': true}).eq('nis', student.nis)
          .catchError((e) => debugPrint('linkChild student error: $e'));

      if (currentRole == 'ortu' && currentUser.phone == phone) {
        currentUser = p;
      }
      notifyListeners();
    }
  }

  void topUpWallet({
    required String studentNis,
    required double amount,
    required String method,
  }) {
    if (amount < 10000.0) throw Exception("Minimal top up adalah Rp 10.000");

    final studentIdx = students.indexWhere((s) => s.nis == studentNis);
    if (studentIdx == -1) throw Exception("Siswa tidak ditemukan");

    final student = students[studentIdx];
    double adminFee = 0.0;
    if (method == 'Alfamart' || method == 'Indomaret') {
      adminFee = 2500.0;
    }

    if (student.balance + amount > 500000.0) {
      throw Exception("Maksimal akumulasi saldo adalah Rp 500.000");
    }

    student.balance += amount;

    final newTx = TransactionModel(
      id: 'TX${Random().nextInt(90000) + 10000}',
      studentNis: student.nis,
      studentName: student.name,
      merchantId: 'SYSTEM',
      merchantName: 'SekolahPRO TopUp',
      itemsSummary: 'Top Up E-Wallet via $method${adminFee > 0 ? ' (Fee Rp ${adminFee.toInt()})' : ''}',
      amount: amount,
      type: method.contains('VA')
          ? 'Top Up VA'
          : (method == 'QRIS'
              ? 'Top Up QRIS'
              : (method == 'Manual' ? 'Top Up Manual' : 'Top Up Minimarket')),
      status: 'Selesai',
      triggeredAllergenCodes: [],
      timestamp: DateTime.now(),
    );

    transactions.insert(0, newTx);

    _db.from('transactions').insert(newTx.toJson())
        .catchError((e) => debugPrint('topUp tx error: $e'));
    _db.from('students').update({'balance': student.balance}).eq('nis', student.nis)
        .catchError((e) => debugPrint('topUp balance error: $e'));

    _sendParentTopUpNotification(student, amount, method);

    if (currentRole == 'siswa' && currentUser.nis == student.nis) {
      currentUser = student;
    }
    notifyListeners();
  }

  // ─── ADMIN PORTAL ─────────────────────────────────────────────────────────

  void addOrUpdateMerchantAdmin({
    String? merchantId,
    required String name,
    required String category,
    required String username,
    required String password,
    required String startTime,
    required String endTime,
  }) {
    if (merchantId != null) {
      final idx = merchants.indexWhere((m) => m.id == merchantId);
      if (idx != -1) {
        merchants[idx] = Merchant(
          id: merchantId,
          name: name,
          category: category,
          username: username,
          password: password,
          startTime: startTime,
          endTime: endTime,
          isOpen: merchants[idx].isOpen,
          isTempClosed: merchants[idx].isTempClosed,
        );
        _db.from('merchants').upsert(merchants[idx].toJson())
            .catchError((e) => debugPrint('updateMerchant error: $e'));
      }
    } else {
      final newMerchant = Merchant(
        id: 'M${(merchants.length + 1).toString().padLeft(3, '0')}',
        name: name,
        category: category,
        username: username,
        password: password,
        startTime: startTime,
        endTime: endTime,
        isOpen: true,
      );
      merchants.add(newMerchant);
      _db.from('merchants').insert(newMerchant.toJson())
          .catchError((e) => debugPrint('addMerchant error: $e'));
    }
    notifyListeners();
  }

  void toggleMerchantTempClosed(String merchantId, bool isTempClosed) {
    final idx = merchants.indexWhere((m) => m.id == merchantId);
    if (idx != -1) {
      merchants[idx].isTempClosed = isTempClosed;
      _db.from('merchants').update({'is_temp_closed': isTempClosed}).eq('id', merchantId)
          .catchError((e) => debugPrint('toggleMerchant error: $e'));
      notifyListeners();
    }
  }

  void resetStudentPinByAdmin(String nis, String defaultPin) {
    final idx = students.indexWhere((s) => s.nis == nis);
    if (idx != -1) {
      students[idx].pin = defaultPin;
      _db.from('students').update({'pin': defaultPin}).eq('nis', nis)
          .catchError((e) => debugPrint('resetPin error: $e'));
      notifyListeners();
    }
  }

  void toggleStudentAccountStatus(String nis, bool isBlocked) {
    final idx = students.indexWhere((s) => s.nis == nis);
    if (idx != -1) {
      students[idx].isBlocked = isBlocked;
      _db.from('students').update({'is_blocked': isBlocked}).eq('nis', nis)
          .catchError((e) => debugPrint('toggleStudent error: $e'));
      notifyListeners();
    }
  }

  String regenerateStudentLinkingCode(String nis) {
    final idx = students.indexWhere((s) => s.nis == nis);
    if (idx != -1) {
      final newCode =
          "${students[idx].name.substring(0, min(students[idx].name.length, 4)).toUpperCase()}${Random().nextInt(900) + 100}";
      students[idx].linkingCode = newCode;
      _db.from('students').update({'linking_code': newCode}).eq('nis', nis)
          .catchError((e) => debugPrint('regenerateLinkingCode error: $e'));
      notifyListeners();
      return newCode;
    }
    return '';
  }

  void addVoucherAdmin({
    required String code,
    required String type,
    required double value,
    required String description,
    required int expiryDays,
    String? merchantId,
  }) {
    final newVoucher = Voucher(
      code: code.toUpperCase(),
      type: type,
      value: value,
      description: description,
      expiryDate: DateTime.now().add(Duration(days: expiryDays)),
      merchantId: merchantId,
    );
    vouchers.add(newVoucher);
    _db.from('vouchers').insert(newVoucher.toJson())
        .catchError((e) => debugPrint('addVoucher error: $e'));
    notifyListeners();
  }

  void toggleVoucherAdmin(String code) {
    vouchers.removeWhere((v) => v.code == code);
    _db.from('vouchers').delete().eq('code', code)
        .catchError((e) => debugPrint('deleteVoucher error: $e'));
    notifyListeners();
  }

  int simulateBulkImport(String csvContent) {
    final lines = csvContent.split('\n');
    int count = 0;
    for (var line in lines) {
      final parts = line.split(',');
      if (parts.length >= 3) {
        final nis = parts[0].trim();
        final name = parts[1].trim();
        final cls = parts[2].trim();
        double balance = parts.length > 3 ? (double.tryParse(parts[3].trim()) ?? 0.0) : 0.0;

        if (nis.isNotEmpty && name.isNotEmpty && !students.any((s) => s.nis == nis)) {
          final newStudent = Student(
            nis: nis,
            pin: '123456',
            name: name,
            className: cls,
            balance: balance,
            remainderDailyLimit: 0.0,
            allergens: [],
            vouchers: ['DISKON10'],
            linkingCode:
                "${name.substring(0, min(name.length, 4)).toUpperCase()}${Random().nextInt(900) + 100}",
          );
          students.add(newStudent);
          _db.from('students').insert(newStudent.toJson())
              .catchError((e) => debugPrint('bulkImport error: $e'));
          count++;
        }
      }
    }
    notifyListeners();
    return count;
  }

  // ─── INTERNAL HELPERS ─────────────────────────────────────────────────────

  String _generateRandomToken() {
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final r = Random();
    return List.generate(8, (index) => chars[r.nextInt(chars.length)]).join();
  }

  void _sendParentTransactionNotification(Student student, TransactionModel tx) {
    final parentList = parents.where((p) => p.linkedStudentNises.contains(student.nis));
    for (var parent in parentList) {
      if (parent.notificationSettings['transaksi'] == true) {
        final formattedTime =
            "${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}";
        final formattedDate = "${tx.timestamp.day}/${tx.timestamp.month}/${tx.timestamp.year}";
        final smsMessage =
            "[SekolahPRO] ${student.name} baru saja membeli di ${tx.merchantName}:\n"
            "- ${tx.itemsSummary} — Rp ${tx.amount.toInt()}\n"
            "Total: Rp ${tx.amount.toInt()} | Sisa saldo: Rp ${student.balance.toInt()}\n"
            "Waktu: $formattedTime, $formattedDate";

        systemNotifications.insert(0, {
          'id': 'NOTIF_${Random().nextInt(99999)}',
          'parentPhone': parent.phone,
          'title': 'Transaksi Baru: ${student.name}',
          'body': smsMessage,
          'timestamp': DateTime.now(),
          'type': 'transaksi',
          'isRead': false,
        });
      }
    }
  }

  void _sendParentTopUpNotification(Student student, double amount, String method) {
    final parentList = parents.where((p) => p.linkedStudentNises.contains(student.nis));
    for (var parent in parentList) {
      if (parent.notificationSettings['topup'] == true) {
        final smsMessage =
            "[SekolahPRO] Top up saldo ${student.name} berhasil sebesar Rp ${amount.toInt()} via $method.\n"
            "Saldo saat ini: Rp ${student.balance.toInt()}";

        systemNotifications.insert(0, {
          'id': 'NOTIF_${Random().nextInt(99999)}',
          'parentPhone': parent.phone,
          'title': 'Top Up Berhasil: ${student.name}',
          'body': smsMessage,
          'timestamp': DateTime.now(),
          'type': 'topup',
          'isRead': false,
        });
      }
    }
  }

  void _checkLowBalanceAlert(Student student) {
    if (student.balance < 5000.0) {
      final parentList = parents.where((p) => p.linkedStudentNises.contains(student.nis));
      for (var parent in parentList) {
        if (parent.notificationSettings['saldo_rendah'] == true) {
          final smsMessage =
              "[SekolahPRO] Saldo ${student.name} tersisa Rp ${student.balance.toInt()}.\n"
              "Tap di sini untuk top up sekarang.";

          systemNotifications.insert(0, {
            'id': 'NOTIF_${Random().nextInt(99999)}',
            'parentPhone': parent.phone,
            'title': 'Peringatan Saldo Rendah!',
            'body': smsMessage,
            'timestamp': DateTime.now(),
            'type': 'saldo_rendah',
            'isRead': false,
          });
        }
      }
    }
  }

  void _triggerAllergenAlertNotification(
    Student student,
    String merchantName,
    String summary,
    List<String> allergenCodes,
  ) {
    final parentList = parents.where((p) => p.linkedStudentNises.contains(student.nis));
    for (var parent in parentList) {
      if (parent.notificationSettings['alergen'] == true) {
        final formattedTime =
            "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}";
        final formattedDate =
            "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";

        final allergenNames = allergenCodes.map((code) {
          switch (code) {
            case 'SF':
              return 'Seafood 🦐';
            case 'ML':
              return 'Susu 🥛';
            case 'EG':
              return 'Telur 🥚';
            case 'NT':
              return 'Kacang-kacangan 🥜';
            case 'GL':
              return 'Gluten 🌾';
            case 'SY':
              return 'Kedelai 🫘';
            case 'CH':
              return 'Cabai 🌶️';
            default:
              return 'Alergen Terdaftar';
          }
        }).join(", ");

        final smsMessage =
            "[SekolahPRO] Perhatian! ${student.name} membeli menu ($summary) di $merchantName "
            "yang mengandung alergen: $allergenNames.\nWaktu: $formattedTime, $formattedDate";

        systemNotifications.insert(0, {
          'id': 'NOTIF_${Random().nextInt(99999)}',
          'parentPhone': parent.phone,
          'title': '⚠️ PERINGATAN ALERGEN!',
          'body': smsMessage,
          'timestamp': DateTime.now(),
          'type': 'alergen',
          'isRead': false,
        });
      }
    }
  }
}

// Custom exception for allergen popups
class AllergenWarningException implements Exception {
  final List<String> allergenCodes;
  AllergenWarningException(this.allergenCodes);

  @override
  String toString() {
    return "Menu mengandung alergen terdaftar anak Anda.";
  }
}
