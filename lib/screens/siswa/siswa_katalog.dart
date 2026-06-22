import 'dart:async';
import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../state/app_state_provider.dart';
import '../../models/merchant.dart';
import '../../models/product.dart';
import '../../models/student.dart';
import '../../models/voucher.dart';
import 'siswa_token_screen.dart';

// --- KATALOG PAGE: LIST OF MERCHANTS ---
class SiswaKatalogPage extends StatelessWidget {
  const SiswaKatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daftar Merchant Aktif',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pilih kantin atau koperasi di bawah untuk mulai berbelanja cashless',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: appState.merchants.length,
              itemBuilder: (context, index) {
                final merchant = appState.merchants[index];
                return _buildMerchantListItem(context, merchant);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantListItem(BuildContext context, Merchant merchant) {
    Color statusColor = const Color(0xFF4CAF50);
    String statusText = 'Buka';

    if (merchant.isTempClosed) {
      statusColor = const Color(0xFFFFC107);
      statusText = 'Tutup Sementara';
    } else if (!merchant.isOpen) {
      statusColor = const Color(0xFF9E9E9E);
      statusText = 'Tutup Hari Ini';
    }

    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.04),
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (merchant.id == 'M001' ? const Color(0xFFEF4444) : const Color(0xFF3B82F6)).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            merchant.id == 'M001' ? Icons.fastfood : Icons.menu_book,
            color: merchant.id == 'M001' ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
            size: 24,
          ),
        ),
        title: Text(
          merchant.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Kategori: ${merchant.category}', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 2),
            Text('Jam Operasional: ${merchant.startTime} - ${merchant.endTime}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor, width: 1),
              ),
              child: Text(
                statusText,
                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SiswaMerchantKatalogScreen(merchantId: merchant.id),
            ),
          );
        },
      ),
    );
  }
}

// --- CATALOG SCREEN FOR SPECIFIC MERCHANT ---
class SiswaMerchantKatalogScreen extends StatefulWidget {
  final String merchantId;

  const SiswaMerchantKatalogScreen({super.key, required this.merchantId});

  @override
  State<SiswaMerchantKatalogScreen> createState() => _SiswaMerchantKatalogScreenState();
}

class _SiswaMerchantKatalogScreenState extends State<SiswaMerchantKatalogScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  
  // Cart management: product_id -> quantity
  final Map<String, int> _cart = {};
  
  String? _selectedVoucherCode;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final Student student = appState.currentUser as Student;
    final Merchant merchant = appState.merchants.firstWhere((m) => m.id == widget.merchantId);
    
    // Filtered products list
    final List<Product> merchantProducts = appState.products
        .where((p) => p.merchantId == widget.merchantId && p.isActive)
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .where((p) => _selectedCategory == 'Semua' || p.category == _selectedCategory)
        .toList();

    // Identify unique categories for filter tabs
    final categories = ['Semua'];
    final allCats = appState.products
        .where((p) => p.merchantId == widget.merchantId)
        .map((p) => p.category)
        .toSet()
        .toList();
    categories.addAll(allCats);

    // Calculate subtotal
    double subtotal = 0.0;
    _cart.forEach((prodId, qty) {
      final p = appState.products.firstWhere((prod) => prod.id == prodId);
      subtotal += p.price * qty;
    });

    // Check discount
    double discount = 0.0;
    if (_selectedVoucherCode != null) {
      final vIdx = appState.vouchers.indexWhere((v) => v.code == _selectedVoucherCode);
      if (vIdx != -1) {
        final v = appState.vouchers[vIdx];
        if (v.type == 'Diskon') {
          discount = subtotal * (v.value / 100);
        } else {
          discount = v.value;
        }
      }
    }
    double total = subtotal - discount;
    if (total < 0) total = 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(merchant.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              // Pull-to-refresh simulation
              await Future.delayed(const Duration(milliseconds: 500));
              setState(() {});
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
          setState(() {});
        },
        child: Column(
          children: [
            // Search & Category Filters
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Cari makanan atau perlengkapan...',
                      prefixIcon: const Icon(Icons.search),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Category pills
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, idx) {
                        final cat = categories[idx];
                        final bool isSelected = _selectedCategory == cat;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF1A56DB) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF475569),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Products Grid
            Expanded(
              child: merchantProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'Produk tidak ditemukan',
                            style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: merchantProducts.length,
                      itemBuilder: (context, idx) {
                        final p = merchantProducts[idx];
                        return _buildProductCard(context, p, student);
                      },
                    ),
            ),

            // Cart & Checkout Panel
            if (_cart.isNotEmpty) _buildCartCheckoutPanel(context, subtotal, discount, total, appState, student),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, Student student) {
    final int qtyInCart = _cart[product.id] ?? 0;
    
    // Stock indicators matching rules:
    // Tersedia (Hijau, > 5), Hampir Habis (Kuning, 1-5), Habis (Merah, 0)
    Color stockColor = const Color(0xFF10B981);
    String stockText = 'Tersedia (${product.stock})';
    if (product.stock == 0) {
      stockColor = const Color(0xFFEF4444);
      stockText = 'Habis';
    } else if (product.stock <= 5) {
      stockColor = const Color(0xFFF59E0B);
      stockText = 'Hampir Habis (${product.stock})';
    }

    // Check if contains allergens registered by student
    final hasAllergen = product.allergens.any((a) => student.allergens.contains(a));

    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.04),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Icon
          Expanded(
            child: Stack(
              children: [
                product.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Image.network(
                          product.imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                widget.merchantId == 'M001' ? Icons.fastfood : Icons.menu_book,
                                color: const Color(0xFF64748B).withOpacity(0.3),
                                size: 44,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                        ),
                        child: Center(
                          child: Icon(
                            widget.merchantId == 'M001' ? Icons.fastfood : Icons.menu_book,
                            color: const Color(0xFF64748B).withOpacity(0.3),
                            size: 44,
                          ),
                        ),
                      ),
                // Allergen Badge
                if (hasAllergen && widget.merchantId == 'M001') ...[
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFEE2E2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⚠️ ', style: TextStyle(fontSize: 10)),
                          Text(
                            product.allergens.firstWhere((a) => student.allergens.contains(a)),
                            style: const TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 4),
                // Stock indicator
                Text(
                  stockText,
                  style: TextStyle(color: stockColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp ${product.price.toInt()}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A56DB)),
                    ),
                    if (product.stock == 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                        child: const Text('Nonaktif', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      )
                    else if (qtyInCart == 0)
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart, color: Color(0xFF1A56DB), size: 20),
                        onPressed: () {
                          setState(() {
                            _cart[product.id] = 1;
                          });
                        },
                      )
                    else
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (qtyInCart == 1) {
                                  _cart.remove(product.id);
                                } else {
                                  _cart[product.id] = qtyInCart - 1;
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                              child: const Icon(Icons.remove, size: 14, color: Color(0xFF475569)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('$qtyInCart', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (qtyInCart >= product.stock) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Batas stok maksimal tercapai!')),
                                );
                                return;
                              }
                              setState(() {
                                _cart[product.id] = qtyInCart + 1;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Color(0xFF1A56DB), shape: BoxShape.circle),
                              child: const Icon(Icons.add, size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartCheckoutPanel(
    BuildContext context,
    double subtotal,
    double discount,
    double total,
    AppState appState,
    Student student,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Voucher select button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.confirmation_num, color: Color(0xFFEF4444), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _selectedVoucherCode != null ? 'Voucher Terpasang: $_selectedVoucherCode' : 'Gunakan Voucher Diskon/Subsidi',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _showVouchersModal(context, appState, student),
                  child: Text(_selectedVoucherCode != null ? 'Ganti' : 'Pilih Voucher', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(height: 8),
            // Checkout breakdowns
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal belanja', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('Rp ${subtotal.toInt()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            if (discount > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Potongan voucher', style: TextStyle(fontSize: 12, color: Color(0xFFEF4444))),
                  Text('- Rp ${discount.toInt()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Pembayaran', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(
                      'Rp ${total.toInt()}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A56DB)),
                    ),
                  ],
                ),
                // Purchase button
                ElevatedButton(
                  onPressed: () => _handleCheckoutClick(context, appState, total),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A56DB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                  child: const Text('Bayar Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showVouchersModal(BuildContext context, AppState appState, Student student) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (context) {
        // List owned vouchers details
        final myVouchers = appState.vouchers
            .where((v) => student.vouchers.contains(v.code) && !v.isExpired)
            .toList();

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pilih Voucher Belanja', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (myVouchers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Text('Anda tidak memiliki voucher aktif saat ini', style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: myVouchers.length,
                    itemBuilder: (context, idx) {
                      final v = myVouchers[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          leading: const Icon(Icons.confirmation_num, color: Color(0xFFEF4444)),
                          title: Text('${v.code} (${v.type})', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(v.description, style: const TextStyle(fontSize: 12)),
                          trailing: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedVoucherCode = v.code;
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Gunakan'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              if (_selectedVoucherCode != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedVoucherCode = null;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Batalkan Penggunaan Voucher', style: TextStyle(color: Colors.red)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _handleCheckoutClick(BuildContext context, AppState appState, double total) {
    // 1. Compile products & quantities lists
    final List<Product> items = [];
    final List<int> qtys = [];
    _cart.forEach((prodId, qty) {
      final p = appState.products.firstWhere((prod) => prod.id == prodId);
      items.add(p);
      qtys.add(qty);
    });

    final student = appState.currentUser as Student;

    try {
      // Initiate checkout. Will throw AllergenWarningException if allergen alert is needed
      final newTx = appState.initiatePurchase(
        studentNis: student.nis,
        merchantId: widget.merchantId,
        cartItems: items,
        quantities: qtys,
        voucherCode: _selectedVoucherCode,
        bypassAllergen: false,
      );

      // Successfully processed immediately, open token screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SiswaTokenScreen(transaction: newTx),
        ),
      );
    } on AllergenWarningException catch (e) {
      // Trigger allergen alert dialog modal as in spec: "Batalkan" or "Tetap Lanjutkan"
      _showAllergenWarningPopup(context, appState, items, qtys, e.allergenCodes);
    } catch (e) {
      // General error dialog (like insufficient balance)
      _showErrorDialog(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showAllergenWarningPopup(
    BuildContext context,
    AppState appState,
    List<Product> items,
    List<int> qtys,
    List<String> allergenCodes,
  ) {
    final student = appState.currentUser as Student;
    final allergenNames = allergenCodes.map((code) {
      switch (code) {
        case 'SF': return 'Seafood (ikan, udang, cumi) 🦐';
        case 'ML': return 'Susu & Produk Susu 🥛';
        case 'EG': return 'Telur 🥚';
        case 'NT': return 'Kacang-kacangan 🥜';
        case 'GL': return 'Gluten (tepung terigu) 🌾';
        case 'SY': return 'Kedelai 🫘';
        case 'CH': return 'Cabai / Pedas 🌶️';
        default: return 'Alergen Terdaftar';
      }
    }).join("\n- ");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Color(0xFFEF4444)),
              SizedBox(width: 8),
              Text(
                'PERINGATAN ALERGEN!',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Menu yang Anda pilih mengandung alergen yang terdaftar di profil kesehatan Anda:',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFEE2E2)),
                ),
                child: Text(
                  '- $allergenNames',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B), fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Melanjutkan pembelian ini berisiko bagi kesehatan anak Anda. Sistem akan mencatat flag alergen dan mengirim notifikasi khusus ke Orang Tua.',
                style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Canceled
              child: const Text('Batalkan', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close warning popup
                _bypassAllergenAndCheckout(context, appState, student.nis, items, qtys);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              child: const Text('Tetap Lanjutkan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _bypassAllergenAndCheckout(
    BuildContext context,
    AppState appState,
    String studentNis,
    List<Product> items,
    List<int> qtys,
  ) {
    try {
      final newTx = appState.initiatePurchase(
        studentNis: studentNis,
        merchantId: widget.merchantId,
        cartItems: items,
        quantities: qtys,
        voucherCode: _selectedVoucherCode,
        bypassAllergen: true, // bypass allergen confirmation triggers
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SiswaTokenScreen(transaction: newTx),
        ),
      );
    } catch (e) {
      _showErrorDialog(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Checkout Gagal', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
