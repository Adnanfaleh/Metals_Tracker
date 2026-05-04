import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:metals_tracker/domain/models/transaction_model.dart';
import 'package:metals_tracker/presentation/providers/portfolio_provider.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  AssetType _selectedAsset = AssetType.silver;
  TransactionType _selectedType = TransactionType.buy;

  final _amountController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  // 🌟 NEW: State variable to track the chosen date (defaults to today)
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // 🌟 NEW: The function that triggers the calendar popup
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000), // How far back they can scroll
      lastDate: DateTime.now(), // Prevents picking future dates
    );

    // If they picked a new date, update the screen
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        final repository = ref.read(transactionRepositoryProvider);

        final newTransaction = TransactionModel(
          id: '',
          asset: _selectedAsset,
          type: _selectedType,
          amountGr: double.parse(_amountController.text),
          pricePerGr: double.parse(_priceController.text),
          date: _selectedDate, // 🌟 NOW SAVING THE ACTUAL SELECTED DATE
          notes:
              _notesController.text.isNotEmpty ? _notesController.text : null,
        );

        await repository.addTransaction(newTransaction);

        // Refresh both the specific asset and the total portfolio
        ref.invalidate(transactionsProvider(_selectedAsset));
        ref.invalidate(totalPortfolioProvider);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Transaction Saved Successfully!'),
                backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding pushes the sheet up when the keyboard opens
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Log Transaction',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<AssetType>(
                      value: _selectedAsset,
                      decoration: const InputDecoration(
                          labelText: 'Asset', border: OutlineInputBorder()),
                      items: AssetType.values
                          .map((asset) => DropdownMenuItem(
                                value: asset,
                                child: Text(asset.name.toUpperCase()),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedAsset = val!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<TransactionType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                          labelText: 'Type', border: OutlineInputBorder()),
                      items: TransactionType.values
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.name.toUpperCase()),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedType = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // The interactive Date Picker UI Box
              InkWell(
                onTap: () => _pickDate(context),
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Transaction Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Formats the raw DateTime into DD/MM/YYYY
                      Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today,
                          size: 20, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                    labelText: 'Amount (grams)', border: OutlineInputBorder()),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter amount' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                    labelText: 'Price per gram (\$)',
                    border: OutlineInputBorder()),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter price' : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save Transaction',
                        style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
