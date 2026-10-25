import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'database/db_helper.dart';
import 'models/transaction_model.dart';
import 'utils/prefs_helper.dart';

void main() {
  runApp(const MyApp());
}

class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String numericOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericOnly.isEmpty) return newValue.copyWith(text: '');

    final formatter = NumberFormat('#,###', 'en_US');
    String newText = formatter.format(double.parse(numericOnly));

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemeSetting();
  }

  Future<void> _loadThemeSetting() async {
    final isDark = await PrefsHelper.loadTheme();
    setState(() {
      _isDarkMode = isDark;
    });
  }

  void _toggleTheme(bool value) async {
    await PrefsHelper.saveTheme(value);
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UangKu - Pencatatan Keuangan',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: HomeScreen(
        isDarkMode: _isDarkMode,
        onThemeChanged: _toggleTheme,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const HomeScreen({super.key, required this.isDarkMode, required this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshTransactions();
  }

  Future<void> _refreshTransactions() async {
    setState(() => _isLoading = true);
    final data = await DBHelper.instance.fetchTransactions();
    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String type = 'Pengeluaran';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Tambah Transaksi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Keterangan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Nominal (Rp)',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: type,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: ['Pemasukan', 'Pengeluaran']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          type = val!;
                        });
                      },
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    String rawAmount = amountController.text.replaceAll(',', '');
                    
                    final newTransaction = TransactionModel(
                      title: titleController.text,
                      amount: double.tryParse(rawAmount) ?? 0,
                      type: type,
                      date: DateTime.now().toIso8601String(),
                    );
                    
                    await DBHelper.instance.insertTransaction(newTransaction);
                    _refreshTransactions(); 
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan'),
                )
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildTransactionList(List<TransactionModel> listData) {
    if (listData.isEmpty) {
      return const Center(child: Text('Belum ada transaksi di kategori ini.'));
    }
    
    final displayFormatter = NumberFormat('#,###', 'en_US');

    return ListView.builder(
      itemCount: listData.length,
      padding: const EdgeInsets.only(bottom: 80), 
      itemBuilder: (context, index) {
        final trx = listData[index];
        final date = DateFormat('dd MMM yyyy HH:mm').format(DateTime.parse(trx.date));
        final isIncome = trx.type == 'Pemasukan';
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isIncome ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
            title: Text(trx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(date),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Rp ${displayFormatter.format(trx.amount)}',
                  style: TextStyle(
                    color: isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: () async {
                    await DBHelper.instance.deleteTransaction(trx.id!);
                    _refreshTransactions();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final listPengeluaran = _transactions.where((t) => t.type == 'Pengeluaran').toList();
    final listPemasukan = _transactions.where((t) => t.type == 'Pemasukan').toList();

    return DefaultTabController(
      length: 3, 
      child: Scaffold(
        appBar: AppBar(
          title: const Text('UangKu'),
          actions: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline),
                Switch(
                  value: widget.isDarkMode,
                  onChanged: widget.onThemeChanged,
                ),
              ],
            )
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pengeluaran'),
              Tab(text: 'Pemasukan'),
              Tab(text: 'Campur'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildTransactionList(listPengeluaran),
                  _buildTransactionList(listPemasukan), 
                  _buildTransactionList(_transactions),  
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}