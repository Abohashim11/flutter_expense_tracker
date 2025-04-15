import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'add_expense_screen.dart';
import 'expense_list_screen.dart';
import 'summary_screen.dart';

/// Main entry point of the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const ExpenseTrackerApp());
}

/// Custom theme data for the application
class AppTheme {
  static const primaryColor = Colors.purple;
  static const backgroundColor = Color(0xFFFFF8E1);
  static const fontFamily = 'WinkyRough';

  static ThemeData get lightTheme => ThemeData(
    primarySwatch: primaryColor,
    fontFamily: fontFamily,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
    ),
    scaffoldBackgroundColor: backgroundColor,
    cardTheme: CardTheme(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purpleAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
        ),
      ),
    ),
  );
}

/// Custom button style for the main menu
class MenuButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const MenuButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Comic Sans MS',
          ),
        ),
      ),
    );
  }
}

/// Main application widget
class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  /// Navigate to a new screen with error handling
  void _navigateToScreen(BuildContext context, Widget screen) {
    try {
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error navigating to screen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: Builder(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Expense Tracker',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontFamily: 'Comic Sans MS',
                  ),
                ),
                backgroundColor: Colors.purple,
              ),
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFF59D), Color(0xFFFFF176)],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Welcome to Expense Tracker 🎉\n\nManage your expenses with ease.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Comic Sans MS',
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      MenuButton(
                        text: 'Add Expense',
                        backgroundColor: Colors.purpleAccent,
                        onPressed:
                            () => _navigateToScreen(
                              context,
                              const AddExpenseScreen(),
                            ),
                      ),
                      const SizedBox(height: 16),
                      MenuButton(
                        text: 'View Expenses',
                        backgroundColor: Colors.blueAccent,
                        onPressed:
                            () => _navigateToScreen(
                              context,
                              const ExpenseListScreen(),
                            ),
                      ),
                      const SizedBox(height: 16),
                      MenuButton(
                        text: 'Summary',
                        backgroundColor: Colors.greenAccent,
                        onPressed:
                            () => _navigateToScreen(
                              context,
                              const SummaryScreen(),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
