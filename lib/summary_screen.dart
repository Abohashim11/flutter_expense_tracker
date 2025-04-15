import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'add_expense_screen.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  Future<List<Map<String, dynamic>>> _getAllExpenses() async {
    final box = await Hive.openBox('expenses');
    final expenses =
        box.values.map((e) {
          if (e is Map<dynamic, dynamic>) {
            return Map<String, dynamic>.from(e);
          } else {
            throw Exception('Invalid data format in Hive box: $e');
          }
        }).toList();
    return expenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Summary',
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
      body: Column(
        children: [
          // Total Expenses Card with Cartoon Style
          Card(
            elevation: 6,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder(
                future: _getAllExpenses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.sentiment_dissatisfied,
                          color: Colors.red,
                          size: 30,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'No Expenses Yet!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Comic Sans MS',
                          ),
                        ),
                      ],
                    );
                  }

                  final expenses = snapshot.data as List<Map<String, dynamic>>;
                  final totalExpenses = expenses.fold<double>(
                    0.0,
                    (sum, expense) => sum + (expense['amount'] as double),
                  );

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.star, color: Colors.orange, size: 30),
                          SizedBox(width: 10),
                          Text(
                            'Total Expenses:',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontFamily: 'Comic Sans MS',
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '\$${totalExpenses.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontFamily: 'Comic Sans MS',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Expenses List with Cartoon Style
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFF59D), Color(0xFFFFF176)],
                ),
              ),
              child: FutureBuilder(
                future: _getAllExpenses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                    return const Center(
                      child: Text(
                        'No expenses found.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          fontFamily: 'Comic Sans MS',
                        ),
                      ),
                    );
                  }

                  final expenses = snapshot.data as List<Map<String, dynamic>>;

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      final category = expense['category'] as String;
                      final amount = expense['amount'] as double;
                      final date = DateTime.parse(expense['date'] as String);

                      IconData categoryIcon;
                      Color categoryColor;

                      switch (category) {
                        case 'Transport':
                          categoryIcon = Icons.directions_car;
                          categoryColor = Colors.blue;
                          break;
                        case 'Food':
                          categoryIcon = Icons.fastfood;
                          categoryColor = Colors.orange;
                          break;
                        case 'Shopping':
                          categoryIcon = Icons.shopping_bag;
                          categoryColor = Colors.pink;
                          break;
                        default:
                          categoryIcon = Icons.category;
                          categoryColor = Colors.grey;
                      }

                      return Card(
                        elevation: 6,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: categoryColor,
                                child: Icon(categoryIcon, color: Colors.white),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        fontFamily: 'Comic Sans MS',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      DateFormat.yMMMd().format(date),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                        fontFamily: 'Comic Sans MS',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '\$${amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontFamily: 'Comic Sans MS',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
