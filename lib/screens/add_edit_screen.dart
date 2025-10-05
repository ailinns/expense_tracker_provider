//  add_edit_screen
import 'package:expense_tracker_provider/models/my_transaction.dart';
import 'package:expense_tracker_provider/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddEditScreen extends StatefulWidget {
  static const routeName = '/add-edit';
  final int? transactionId;
  const AddEditScreen({this.transactionId, super.key});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.transactionId != null) {
      _loadTransaction();
    }
  }

  Future<void> _loadTransaction() async {
    final tx = await context.read<TransactionProvider>().getById(
      widget.transactionId!,
    );
    if (tx != null) {
      setState(() {
        _isEditing = true;
        _titleController.text = tx.title;
        _amountController.text = tx.amount.toString();
      });
    }
  }

  Future<void> _save() async {
    await context.read<TransactionProvider>().addMyTransaction(
      _titleController.text,
      double.parse(_amountController.text),
      DateTime.now(),
      TransactionType.income,
      id: widget.transactionId, 
    );
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SQLite C.R.U.D. Lab')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: Text(_isEditing ? 'editData' : 'saveData'),
            ),
            // พื้นที่สำหรับแสดงผล (จะเพิ่มในขั้นตอนถัดไป)
          ],
        ),
      ),
    );
  }
}
