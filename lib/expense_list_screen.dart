import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  Future<List<Map<String, dynamic>>> _getExpenses() async {
    final box = await Hive.openBox('expenses');
    final expenses =
        box.values
            .map((e) => Map<String, dynamic>.from(e as Map<dynamic, dynamic>))
            .toList();

    return expenses.cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expenses',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Color.fromARGB(255, 255, 255, 255),
            fontFamily: 'Comic Sans MS',
          ),
        ),
        backgroundColor: Colors.purple,
      ),
      body: Expanded(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF59D), Color(0xFFFFF176)],
            ),
          ),
          child: FutureBuilder(
            future: _getExpenses(),
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
                      color: Colors.black,
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
                  // ignore: unused_local_variable
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

                  return ExpansionTile(
                    title: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: categoryColor,
                          child: Icon(categoryIcon, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'Comic Sans MS',
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: TextEditingController(
                                text: expense['amount'].toString(),
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Amount',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                expense['amount'] =
                                    double.tryParse(value) ?? expense['amount'];
                              },
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: category,
                              items: [
                                DropdownMenuItem(
                                  value: 'Transport',
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.directions_car,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Transport'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Food',
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.fastfood,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Food'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Shopping',
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.shopping_bag,
                                        color: Colors.pink,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Shopping'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Other',
                                  child: Row(
                                    children: const [
                                      Icon(Icons.category, color: Colors.grey),
                                      SizedBox(width: 8),
                                      Text('Other'),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (newValue) {
                                setState(() {
                                  expense['category'] =
                                      newValue ?? expense['category'];
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'Category',
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: TextEditingController(
                                text: DateFormat.yMMMd().format(date),
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Date',
                              ),
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: date,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (pickedDate != null && pickedDate != date) {
                                  setState(() {
                                    expense['date'] =
                                        pickedDate.toIso8601String();
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    final box = await Hive.openBox('expenses');
                                    await box.putAt(index, expense);
                                    setState(() {});
                                  },
                                  child: const Text('Save Changes'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final box = await Hive.openBox('expenses');
                                    await box.deleteAt(index);
                                    setState(() {});
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
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
    );
  }
}
