import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': '🍔'},
    {'name': 'Transport', 'icon': '🚗'},
    {'name': 'Entertainment', 'icon': '🎮'},
    {'name': 'Bills', 'icon': '💡'},
    {'name': 'Other', 'icon': '📦'},
  ];

  void _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount.')),
      );
      return;
    }

    final expense = {
      'amount': amount,
      'category': _selectedCategory,
      'date': _selectedDate.toIso8601String(),
    };

    final box = await Hive.openBox('expenses');
    await box.add(expense);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Expense',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Color.fromARGB(255, 255, 255, 255),
            fontFamily: 'Comic Sans MS',
          ),
        ),
        backgroundColor: Colors.purple,
        // Changed to match the main screen color
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF59D), Color(0xFFFFF176)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 6,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.attach_money, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              labelStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an amount';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 6,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items:
                          _categories
                              .map(
                                (category) => DropdownMenuItem<String>(
                                  value: category['name'] as String,
                                  child: Row(
                                    children: [
                                      Text(category['icon'] as String),
                                      const SizedBox(width: 8),
                                      Text(category['name'] as String),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 6,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: InkWell(
                      onTap: () async {
                        try {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _selectedDate = pickedDate;
                            });
                          }
                        } catch (e) {
                          print('Error in showDatePicker: $e');
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Date: ${DateFormat.yMMMd().format(_selectedDate)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveExpense,
                    child: const Text('Save Expense'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditExpenseScreen extends StatefulWidget {
  final int expenseIndex;
  final Map<String, dynamic> expense;

  const EditExpenseScreen({
    super.key,
    required this.expenseIndex,
    required this.expense,
  });

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController _categoryController;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController(
      text: widget.expense['category'],
    );
    _amountController = TextEditingController(
      text: widget.expense['amount'].toString(),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount.')),
      );
      return;
    }

    final box = await Hive.openBox('expenses');
    final updatedExpense = {
      'category': _categoryController.text,
      'amount': amount,
      'date': widget.expense['date'],
    };

    try {
      await box.putAt(widget.expenseIndex, updatedExpense);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense updated successfully.')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update expense: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveExpense,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
