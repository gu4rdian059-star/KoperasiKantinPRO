import '../models/student.dart';
import '../models/parent.dart';
import '../models/merchant.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../models/voucher.dart';

class MockDatabase {
  static List<Student> students = [
    Student(
      nis: '123456',
      pin: '123456',
      name: 'Budi Setyawan',
      className: 'X-IPA 1',
      balance: 150000.0,
      dailySpendingLimit: 50000.0,
      remainderDailyLimit: 40000.0,
      allergens: ['ML', 'NT'], // Susu, Kacang
      vouchers: ['DISKON10', 'SUBSIDI50', 'REWARD5000'],
      isLinked: true,
      linkingCode: 'BUDI123',
    ),
    Student(
      nis: '654321',
      pin: '111111',
      name: 'Siti Aminah',
      className: 'XI-IPS 2',
      balance: 25000.0,
      dailySpendingLimit: 0.0, // No limit
      remainderDailyLimit: 0.0,
      allergens: ['SF'], // Seafood
      vouchers: ['DISKON10'],
      isLinked: true,
      linkingCode: 'SITI321',
    ),
    Student(
      nis: '111222',
      pin: '222222',
      name: 'Andi Pratama',
      className: 'XII-IPA 3',
      balance: 4500.0, // Red warning (< Rp 5.000)
      dailySpendingLimit: 20000.0,
      remainderDailyLimit: 20000.0,
      allergens: [],
      vouchers: [],
      isLinked: false,
      linkingCode: 'ANDI555',
    ),
  ];

  static List<Parent> parents = [
    Parent(
      phone: '08123456789',
      name: 'Bapak Setyawan',
      password: 'password',
      linkedStudentNises: ['123456', '654321'],
      notificationSettings: {
        'transaksi': true,
        'saldo_rendah': true,
        'alergen': true,
        'rekap': true,
        'topup': true,
      },
    ),
  ];

  static List<Merchant> merchants = [
    Merchant(
      id: 'M001',
      name: 'Kantin Sekolah',
      category: 'Makanan & Minuman',
      username: 'kantin',
      password: 'password',
      startTime: '07:00',
      endTime: '15:00',
      isOpen: true,
    ),
    Merchant(
      id: 'M002',
      name: 'Koperasi Sekolah',
      category: 'ATK & Perlengkapan',
      username: 'koperasi',
      password: 'password',
      startTime: '07:00',
      endTime: '16:00',
      isOpen: true,
    ),
  ];

  static List<Product> products = [
    // Kantin M001
    Product(
      id: 'P001',
      merchantId: 'M001',
      name: 'Nasi Ayam Geprek Sambal Korek',
      price: 15000.0,
      stock: 12,
      category: 'Makanan Berat',
      allergens: ['GL'], // Gluten
      imageUrl: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=200',
    ),
    Product(
      id: 'P002',
      merchantId: 'M001',
      name: 'Siomay Bandung Spesial Bumbu Kacang',
      price: 10000.0,
      stock: 4, // Hampir Habis (1-5)
      category: 'Snack',
      allergens: ['SF', 'EG', 'NT'], // Seafood, Telur, Kacang
      imageUrl: 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=200',
    ),
    Product(
      id: 'P003',
      merchantId: 'M001',
      name: 'Susu Kotak Coklat UHT Ultra',
      price: 5000.0,
      stock: 25,
      category: 'Minuman',
      allergens: ['ML'], // Susu
      imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=200',
    ),
    Product(
      id: 'P004',
      merchantId: 'M001',
      name: 'Es Teh Manis Jumbo Segar',
      price: 3000.0,
      stock: 35,
      category: 'Minuman',
      allergens: [],
      imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=200',
    ),
    Product(
      id: 'P005',
      merchantId: 'M001',
      name: 'Batagor Renyah Mang Asep',
      price: 8000.0,
      stock: 0, // Habis
      category: 'Snack',
      allergens: ['GL', 'NT'],
      imageUrl: 'https://images.unsplash.com/photo-1626804475315-9644b37a2fe4?w=200',
    ),

    // Koperasi M002
    Product(
      id: 'P101',
      merchantId: 'M002',
      name: 'Buku Tulis Sinar Dunia 38 Lembar',
      price: 4000.0,
      stock: 50,
      category: 'Buku & Kertas',
      allergens: [],
      imageUrl: 'https://images.unsplash.com/photo-1586075010923-2dd4570fb338?w=200',
    ),
    Product(
      id: 'P102',
      merchantId: 'M002',
      name: 'Pulpen Pilot Ballpoint Hitam 0.5',
      price: 3500.0,
      stock: 30,
      category: 'Alat Tulis',
      allergens: [],
      imageUrl: 'https://images.unsplash.com/photo-1583485088034-697b5bc54ccd?w=200',
    ),
    Product(
      id: 'P103',
      merchantId: 'M002',
      name: 'Seragam Putih OSIS SMA Lengan Pendek (L)',
      price: 65000.0,
      stock: 10,
      category: 'Perlengkapan Sekolah',
      allergens: [],
      imageUrl: 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=200',
    ),
    Product(
      id: 'P104',
      merchantId: 'M002',
      name: 'Dasi Sekolah Bordir SekolahPRO Biru/Abu',
      price: 15000.0,
      stock: 2, // Hampir Habis
      category: 'Perlengkapan Sekolah',
      allergens: [],
      imageUrl: 'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?w=200',
    ),
    Product(
      id: 'P105',
      merchantId: 'M002',
      name: 'Gunting Kertas Joyko Stainless Steel',
      price: 7500.0,
      stock: 12,
      category: 'Peralatan Lain',
      allergens: [],
      imageUrl: 'https://images.unsplash.com/photo-1533228818585-618844837bb5?w=200',
    ),
  ];

  static List<Voucher> vouchers = [
    Voucher(
      code: 'DISKON10',
      type: 'Diskon',
      value: 10.0, // 10%
      description: 'Potongan 10% untuk transaksi apa saja di merchant terdaftar',
      expiryDate: DateTime.now().add(const Duration(days: 30)),
    ),
    Voucher(
      code: 'SUBSIDI50',
      type: 'Subsidi',
      value: 10000.0, // Rp 10.000
      description: 'Bantuan subsidi makanan sekolah gratis senilai Rp 10.000',
      expiryDate: DateTime.now().add(const Duration(days: 7)),
    ),
    Voucher(
      code: 'REWARD5000',
      type: 'Hadiah',
      value: 5000.0, // Rp 5.000
      description: 'Reward apresiasi sekolah berprestasi senilai Rp 5.000',
      expiryDate: DateTime.now().add(const Duration(days: 15)),
    ),
  ];

  static List<TransactionModel> transactions = [
    TransactionModel(
      id: 'TX001',
      studentNis: '123456',
      studentName: 'Budi Setyawan',
      merchantId: 'M001',
      merchantName: 'Kantin Sekolah',
      itemsSummary: '1x Nasi Ayam Geprek Sambal Korek',
      amount: 15000.0,
      type: 'Pembelian',
      status: 'Selesai',
      hasAllergenWarning: false,
      triggeredAllergenCodes: [],
      timestamp: DateTime.now().subtract(const Duration(hours: 24)),
    ),
    TransactionModel(
      id: 'TX002',
      studentNis: '123456',
      studentName: 'Budi Setyawan',
      merchantId: 'M002',
      merchantName: 'Koperasi Sekolah',
      itemsSummary: '1x Buku Tulis Sinar Dunia, 1x Pulpen Pilot',
      amount: 7500.0,
      type: 'Pembelian',
      status: 'Selesai',
      hasAllergenWarning: false,
      triggeredAllergenCodes: [],
      timestamp: DateTime.now().subtract(const Duration(hours: 22)),
    ),
    TransactionModel(
      id: 'TX003',
      studentNis: '123456',
      studentName: 'Budi Setyawan',
      merchantId: 'SYSTEM',
      merchantName: 'SekolahPRO Bank Transfer',
      itemsSummary: 'Top Up Saldo E-Wallet via Mandiri VA',
      amount: 100000.0,
      type: 'Top Up VA',
      status: 'Selesai',
      hasAllergenWarning: false,
      triggeredAllergenCodes: [],
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TransactionModel(
      id: 'TX004',
      studentNis: '654321',
      studentName: 'Siti Aminah',
      merchantId: 'M001',
      merchantName: 'Kantin Sekolah',
      itemsSummary: '1x Es Teh Manis Jumbo Segar',
      amount: 3000.0,
      type: 'Pembelian',
      status: 'Selesai',
      hasAllergenWarning: false,
      triggeredAllergenCodes: [],
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    TransactionModel(
      id: 'TX005',
      studentNis: '123456',
      studentName: 'Budi Setyawan',
      merchantId: 'M001',
      merchantName: 'Kantin Sekolah',
      itemsSummary: '1x Siomay Bandung Spesial Bumbu Kacang',
      amount: 10000.0,
      type: 'Pembelian',
      status: 'Selesai',
      hasAllergenWarning: true,
      triggeredAllergenCodes: ['NT'], // Kacang warning, but proceeded
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
  ];
}
