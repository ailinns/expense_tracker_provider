import 'package:expense_tracker_provider/screens/add_edit_screen.dart';
import 'package:expense_tracker_provider/screens/transaction_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TransactionProvider(),
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      initialRoute: TransactionListScreen.routeName,
      routes: {
        TransactionListScreen.routeName: (context) => const TransactionListScreen(),
        AddEditScreen.routeName: (context) => const AddEditScreen()
      } // เปลี่ยนเป็นหน้าจอหลัก
    );
  }
}