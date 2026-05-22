enum UserRole {
  siswa,
  orangTua,
  merchant,
  admin,
}

enum TransactionStatus {
  pending,
  confirmed,
  completed,
  cancelled,
  failed,
}

enum StockStatus {
  available,
  low,
  outOfStock,
}

enum MerchantStatus {
  open,
  closed,
  temporarilyClosed,
}

enum AllergenType {
  seafood, // SF - Seafood
  dairy, // ML - Susu & Produk Susu
  egg, // EG - Telur
  nuts, // NT - Kacang-kacangan
  gluten, // GL - Gluten
  soy, // SY - Kedelai
  spicy, // CH - Cabai / Pedas
}

enum VoucherType {
  subsidi,
  diskon,
  hadiah,
}

enum TopUpMethod {
  bankTransfer,
  qris,
  minimarket,
  manual,
}

enum NotificationType {
  transaction,
  lowBalance,
  allergenWarning,
  weeklyRecap,
  topUpSuccess,
}

enum ProductCategory {
  makananBerat,
  snack,
  minuman,
  alatTulis,
  bukuKertas,
  perlengkapanSekolah,
  peralatanLain,
  semua,
}

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.siswa:
        return 'Siswa';
      case UserRole.orangTua:
        return 'Orang Tua';
      case UserRole.merchant:
        return 'Merchant';
      case UserRole.admin:
        return 'Admin';
    }
  }
}

extension TransactionStatusExtension on TransactionStatus {
  String get label {
    switch (this) {
      case TransactionStatus.pending:
        return 'Menunggu Konfirmasi';
      case TransactionStatus.confirmed:
        return 'Dikonfirmasi';
      case TransactionStatus.completed:
        return 'Selesai';
      case TransactionStatus.cancelled:
        return 'Dibatalkan';
      case TransactionStatus.failed:
        return 'Gagal';
    }
  }
}

extension StockStatusExtension on StockStatus {
  String get label {
    switch (this) {
      case StockStatus.available:
        return 'Tersedia';
      case StockStatus.low:
        return 'Hampir Habis';
      case StockStatus.outOfStock:
        return 'Habis';
    }
  }
}

extension MerchantStatusExtension on MerchantStatus {
  String get label {
    switch (this) {
      case MerchantStatus.open:
        return 'Buka';
      case MerchantStatus.closed:
        return 'Tutup';
      case MerchantStatus.temporarilyClosed:
        return 'Tutup Sementara';
    }
  }
}

extension AllergenTypeExtension on AllergenType {
  String get label {
    switch (this) {
      case AllergenType.seafood:
        return 'Seafood';
      case AllergenType.dairy:
        return 'Susu & Produk Susu';
      case AllergenType.egg:
        return 'Telur';
      case AllergenType.nuts:
        return 'Kacang-kacangan';
      case AllergenType.gluten:
        return 'Gluten';
      case AllergenType.soy:
        return 'Kedelai';
      case AllergenType.spicy:
        return 'Cabai / Pedas';
    }
  }

  String get code {
    switch (this) {
      case AllergenType.seafood:
        return 'SF';
      case AllergenType.dairy:
        return 'ML';
      case AllergenType.egg:
        return 'EG';
      case AllergenType.nuts:
        return 'NT';
      case AllergenType.gluten:
        return 'GL';
      case AllergenType.soy:
        return 'SY';
      case AllergenType.spicy:
        return 'CH';
    }
  }

  String get icon {
    switch (this) {
      case AllergenType.seafood:
        return '🦐';
      case AllergenType.dairy:
        return '🥛';
      case AllergenType.egg:
        return '🥚';
      case AllergenType.nuts:
        return '🥜';
      case AllergenType.gluten:
        return '🌾';
      case AllergenType.soy:
        return '🫘';
      case AllergenType.spicy:
        return '🌶️';
    }
  }
}

extension VoucherTypeExtension on VoucherType {
  String get label {
    switch (this) {
      case VoucherType.subsidi:
        return 'Subsidi';
      case VoucherType.diskon:
        return 'Diskon';
      case VoucherType.hadiah:
        return 'Hadiah';
    }
  }
}

extension TopUpMethodExtension on TopUpMethod {
  String get label {
    switch (this) {
      case TopUpMethod.bankTransfer:
        return 'Transfer Bank';
      case TopUpMethod.qris:
        return 'QRIS';
      case TopUpMethod.minimarket:
        return 'Minimarket';
      case TopUpMethod.manual:
        return 'Top Up Manual';
    }
  }

  double get adminFee {
    switch (this) {
      case TopUpMethod.bankTransfer:
        return 0;
      case TopUpMethod.qris:
        return 0;
      case TopUpMethod.minimarket:
        return 2500;
      case TopUpMethod.manual:
        return 0;
    }
  }
}

extension NotificationTypeExtension on NotificationType {
  String get label {
    switch (this) {
      case NotificationType.transaction:
        return 'Setiap transaksi';
      case NotificationType.lowBalance:
        return 'Saldo rendah';
      case NotificationType.allergenWarning:
        return 'Peringatan alergen';
      case NotificationType.weeklyRecap:
        return 'Rekap mingguan';
      case NotificationType.topUpSuccess:
        return 'Top up berhasil';
    }
  }
}

extension ProductCategoryExtension on ProductCategory {
  String get label {
    switch (this) {
      case ProductCategory.makananBerat:
        return 'Makanan Berat';
      case ProductCategory.snack:
        return 'Snack';
      case ProductCategory.minuman:
        return 'Minuman';
      case ProductCategory.alatTulis:
        return 'Alat Tulis';
      case ProductCategory.bukuKertas:
        return 'Buku & Kertas';
      case ProductCategory.perlengkapanSekolah:
        return 'Perlengkapan Sekolah';
      case ProductCategory.peralatanLain:
        return 'Peralatan Lain';
      case ProductCategory.semua:
        return 'Semua';
    }
  }
}
