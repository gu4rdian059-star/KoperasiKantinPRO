import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../state/app_state_provider.dart';
import '../../models/student.dart';
import '../../models/transaction.dart';

class SiswaRiwayatPage extends StatefulWidget {
  const SiswaRiwayatPage({super.key});

  @override
  State<SiswaRiwayatPage> createState() => _SiswaRiwayatPageState();
}

class _SiswaRiwayatPageState extends State<SiswaRiwayatPage> {
  String _timeRange = 'Semua'; // 'Semua', 'Hari Ini', '7 Hari', '30 Hari', 'Tanggal'
  String _selectedMerchantFilter = 'Semua';
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final Student student = appState.currentUser as Student;

    // Filter transactions
    List<TransactionModel> myTransactions = appState.transactions
        .where((tx) => tx.studentNis == student.nis)
        .toList();

    // 1. Merchant filter
    if (_selectedMerchantFilter != 'Semua') {
      myTransactions = myTransactions
          .where((tx) => tx.merchantName.toLowerCase().contains(_selectedMerchantFilter.toLowerCase()))
          .toList();
    }

    // 2. Time range filter
    final DateTime now = DateTime.now();
    if (_timeRange == 'Hari Ini') {
      myTransactions = myTransactions.where((tx) {
        return tx.timestamp.day == now.day &&
            tx.timestamp.month == now.month &&
            tx.timestamp.year == now.year;
      }).toList();
    } else if (_timeRange == '7 Hari') {
      final weekAgo = now.subtract(const Duration(days: 7));
      myTransactions = myTransactions.where((tx) => tx.timestamp.isAfter(weekAgo)).toList();
    } else if (_timeRange == '30 Hari') {
      final monthAgo = now.subtract(const Duration(days: 30));
      myTransactions = myTransactions.where((tx) => tx.timestamp.isAfter(monthAgo)).toList();
    } else if (_timeRange == 'Tanggal' && _customStartDate != null && _customEndDate != null) {
      myTransactions = myTransactions.where((tx) {
        // Normalize time
        final date = tx.timestamp;
        final start = DateTime(_customStartDate!.year, _customStartDate!.month, _customStartDate!.day);
        final end = DateTime(_customEndDate!.year, _customEndDate!.month, _customEndDate!.day, 23, 59, 59);
        return date.isAfter(start) && date.isBefore(end);
      }).toList();
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saring Riwayat Belanja',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 12),
                // Time Range filters horizontal pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTimePill('Semua'),
                      _buildTimePill('Hari Ini'),
                      _buildTimePill('7 Hari'),
                      _buildTimePill('30 Hari'),
                      _buildTimePill('Tanggal'),
                    ],
                  ),
                ),
                if (_timeRange == 'Tanggal') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 14),
                          label: Text(
                            _customStartDate != null
                                ? '${_customStartDate!.day}/${_customStartDate!.month}/${_customStartDate!.year}'
                                : 'Mulai',
                            style: const TextStyle(fontSize: 11),
                          ),
                          onPressed: () => _selectCustomDateRange(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('s/d', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 14),
                          label: Text(
                            _customEndDate != null
                                ? '${_customEndDate!.day}/${_customEndDate!.month}/${_customEndDate!.year}'
                                : 'Akhir',
                            style: const TextStyle(fontSize: 11),
                          ),
                          onPressed: () => _selectCustomDateRange(context),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                // Merchant filters
                Row(
                  children: [
                    const Text('Merchant:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedMerchantFilter,
                            items: const [
                              DropdownMenuItem(value: 'Semua', child: Text('Semua Merchant', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'Kantin', child: Text('Kantin Sekolah', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'Koperasi', child: Text('Koperasi Sekolah', style: TextStyle(fontSize: 12))),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedMerchantFilter = val);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Logs listing
          Expanded(
            child: myTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        const Text(
                          'Tidak ada transaksi yang cocok',
                          style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: myTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = myTransactions[index];
                      return _buildTransactionRow(tx);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePill(String value) {
    final bool isSelected = _timeRange == value;
    return Container(
      margin: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF475569))),
        selected: isSelected,
        selectedColor: const Color(0xFF1A56DB),
        backgroundColor: Colors.grey.shade100,
        checkmarkColor: Colors.white,
        onSelected: (selected) {
          if (selected) setState(() => _timeRange = value);
        },
      ),
    );
  }

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDateRange: _customStartDate != null && _customEndDate != null
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
          : null,
    );

    if (range != null) {
      setState(() {
        _customStartDate = range.start;
        _customEndDate = range.end;
      });
    }
  }

  Widget _buildTransactionRow(TransactionModel tx) {
    Color typeColor = const Color(0xFF10B981);
    IconData typeIcon = Icons.add_circle;

    if (tx.type == 'Pembelian') {
      typeColor = const Color(0xFFEF4444);
      typeIcon = Icons.shopping_bag;
    }

    Color statusColor = const Color(0xFF9E9E9E);
    if (tx.status == 'Selesai') {
      statusColor = const Color(0xFF4CAF50);
    } else if (tx.status == 'Menunggu') {
      statusColor = const Color(0xFFFFC107);
    } else if (tx.status == 'Dibatalkan') {
      statusColor = const Color(0xFFF44336);
    }

    final formattedDate = "${tx.timestamp.day}/${tx.timestamp.month}/${tx.timestamp.year} ${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(typeIcon, color: typeColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tx.merchantName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      tx.type == 'Pembelian' ? '- Rp ${tx.amount.toInt()}' : '+ Rp ${tx.amount.toInt()}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: tx.type == 'Pembelian' ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tx.itemsSummary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                if (tx.hasAllergenWarning) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, color: Color(0xFFD97706), size: 10),
                        SizedBox(width: 4),
                        Text(
                          'Alergen Dilanjutkan',
                          style: TextStyle(color: Color(0xFFB45309), fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tx.status,
              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
