import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExpenseTrackerPage(),
    );
  }
}

class Expense {
  final String description;
  final double amount;
  final DateTime date;

  Expense({required this.description, required this.amount, required this.date});
}

class ExpenseTrackerPage extends StatefulWidget {
  const ExpenseTrackerPage({super.key});

  @override
  State<ExpenseTrackerPage> createState() => _ExpenseTrackerPageState();
}

class _ExpenseTrackerPageState extends State<ExpenseTrackerPage> {
  final List<Expense> _expenses = [];
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  void _addExpense() {
    final String description = _descriptionController.text;
    final double? amount = double.tryParse(_amountController.text);

    if (description.isNotEmpty && amount != null && amount > 0) {
      setState(() {
        _expenses.add(Expense(
          description: description,
          amount: amount,
          date: DateTime.now(),
        ));
      });
      _descriptionController.clear();
      _amountController.clear();
      FocusScope.of(context).unfocus(); // Dismiss keyboard
    }
  }

  double get _totalDailyExpense {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    double total = 0.0;
    for (var expense in _expenses) {
      final expenseDate = DateTime(expense.date.year, expense.date.month, expense.date.day);
      if (expenseDate.isAtSameMomentAs(today)) {
        total += expense.amount;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Expense Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInputSection(),
            const SizedBox(height: 20),
            _buildTotalSection(),
            const SizedBox(height: 10),
            Expanded(child: _buildExpenseTable()),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addExpense,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total for Today:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            '\$${_totalDailyExpense.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseTable() {
    final todayExpenses = _getTodayExpenses();

    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
        ],
        rows: todayExpenses.map((expense) {
          return DataRow(cells: [
            DataCell(Text(DateFormat('HH:mm').format(expense.date))),
            DataCell(Text(expense.description)),
            DataCell(Text('\$${expense.amount.toStringAsFixed(2)}')),
          ]);
        }).toList(),
      ),
    );
  }

  List<Expense> _getTodayExpenses() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _expenses.where((expense) {
       final expenseDate = DateTime(expense.date.year, expense.date.month, expense.date.day);
       return expenseDate.isAtSameMomentAs(today);
    }).toList();
  }
}
