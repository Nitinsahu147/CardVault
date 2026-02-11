import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../domain/card_model.dart';
import '../../transactions/domain/transaction_model.dart';
import '../../transactions/data/transaction_repository.dart';
import '../data/card_repository.dart';
import 'card_stack_screen.dart';
import 'widgets/card_widget.dart';
import 'add_card_screen.dart';

final transactionsProvider = FutureProvider.family<List<TransactionModel>, String>((ref, cardId) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getTransactionsForCard(cardId);
});

class CardDetailScreen extends ConsumerWidget {
  final CardModel card;

  const CardDetailScreen({super.key, required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider(card.id));

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(card.bankName),
        backgroundColor: Colors.transparent,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'copy') {
                final details = "Bank: ${card.bankName + " " + card.subCategory}\nCard: ${card.cardNumber}\nExpiry: ${card.expiryDate}\nCVV: ${card.cvv}\nHolder: ${card.holderName}";
                Clipboard.setData(ClipboardData(text: details));
                ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Card details copied to clipboard')),
                );
              } else if (value == 'edit') {
                 await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCardScreen(cardToEdit: card)), // Pass card for editing
                );
                ref.invalidate(cardsProvider); // Refresh list
                // We might need to refresh the current screen if it doesn't automatically. 
                // Since this is a ConsumerWidget and we pass 'card' object, if the object itself is immutable and we get a new one from provider...
                // Actually, CardDetailScreen takes 'card' as a parameter. If we update it, the list updates, but this screen might hold stale data.
                // We should probably pop this screen or refetch the card using ID.
                // For now, let's pop back to stack after edit is simpler, or handle it better.
                // Let's pop to ensure data consistency.
                if (context.mounted) Navigator.pop(context);
              } else if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1E1E),
                    title: const Text('Delete Card?', style: TextStyle(color: Colors.white)),
                    content: const Text('Are you sure you want to delete this card? This action cannot be undone.', style: TextStyle(color: Colors.white70)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true), 
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete')
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref.read(cardRepositoryProvider).deleteCard(card.id);
                  ref.invalidate(cardsProvider);
                  if (context.mounted) Navigator.pop(context);
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'copy',
                child: Row(children: [Icon(Icons.copy, size: 20), SizedBox(width: 10), Text('Copy Details')]),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 10), Text('Edit Card')]),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 10), Text('Delete Card', style: TextStyle(color: Colors.red))]),
              ),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Hero(
              tag: card.id,
              child: CardWidget(card: card),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        Icon(Icons.filter_list, color: Colors.white70),
                      ],
                    ),
                  ),
                  if (card.cardType == CardType.credit && card.creditLimit != null)
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                     child: transactionsAsync.when(
                       data: (transactions) {
                         double spent = 0;
                         for (var t in transactions) {
                           if (t.type == TransactionType.debit) spent += t.amount;
                           if (t.type == TransactionType.credit) spent -= t.amount;
                         }
                           // Calculate available credit
                         final available = (card.creditLimit ?? 0) - spent;
                         
                         // Determine label and value based on available credit
                         String label = 'Available Credit';
                         double displayValue = available;
                         Color valueColor = available < 0 ? Colors.red : Colors.green;

                         if (available > (card.creditLimit ?? 0)) {
                           label = 'Total Debit';
                           displayValue = (card.creditLimit ?? 0) - available; // This will show the negative difference
                           valueColor = Colors.red;
                         }

                         return Container(
                           padding: const EdgeInsets.all(16),
                           decoration: BoxDecoration(
                             color: Colors.white.withOpacity(0.05),
                             borderRadius: BorderRadius.circular(16),
                             border: Border.all(color: Colors.white10),
                           ),
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                   Text(
                                     '\₹${displayValue.toStringAsFixed(2)}',
                                     style: TextStyle(color: valueColor, fontSize: 20, fontWeight: FontWeight.bold),
                                   ),
                                 ],
                               ),
                               Column(
                                 crossAxisAlignment: CrossAxisAlignment.end,
                                 children: [
                                   const Text('Total Limit', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                   Text(
                                     '\₹${card.creditLimit!.toStringAsFixed(0)}',
                                     style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                   ),
                                 ],
                               ),
                             ],
                           ),
                         );
                       },
                       loading: () => const SizedBox(),
                       error: (_,__) => const SizedBox(),
                     ),
                   ),
                   const SizedBox(height: 10),
                  Expanded(
                    child: transactionsAsync.when(
                      data: (transactions) {
                        if (transactions.isEmpty) {
                          return const Center(child: Text('No transactions yet', style: TextStyle(color: Colors.white54)));
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: transactions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            return ListTile(
                              onLongPress: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: const Color(0xFF1E1E1E),
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                                  builder: (context) => SafeArea(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.edit, color: Colors.white),
                                          title: const Text('Edit Transaction', style: TextStyle(color: Colors.white)),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _showAddTransactionSheet(context, ref, card.id, transactionToEdit: transaction);
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.delete, color: Colors.red),
                                          title: const Text('Delete Transaction', style: TextStyle(color: Colors.red)),
                                          onTap: () async {
                                            Navigator.pop(context);
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                backgroundColor: const Color(0xFF1E1E1E),
                                                title: const Text('Delete Transaction?', style: TextStyle(color: Colors.white)),
                                                content: const Text('Are you sure you want to delete this transaction?', style: TextStyle(color: Colors.white70)),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, true), 
                                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                                    child: const Text('Delete')
                                                  ),
                                                ],
                                              ),
                                            );
                                            
                                            if (confirm == true) {
                                              await ref.read(transactionRepositoryProvider).deleteTransaction(transaction.id);
                                              ref.invalidate(transactionsProvider(card.id));
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                backgroundColor: transaction.type == TransactionType.credit 
                                    ? Colors.green.withOpacity(0.2) 
                                    : Colors.red.withOpacity(0.2),
                                child: Icon(
                                  transaction.type == TransactionType.credit ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: transaction.type == TransactionType.credit ? Colors.green : Colors.red,
                                ),
                              ),
                              title: Text(transaction.note, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              subtitle: Text(DateFormat('MMM d, y').format(transaction.date), style: const TextStyle(color: Colors.white54)),
                              trailing: Text(
                                '${transaction.type == TransactionType.credit ? "+" : "-"} \₹${transaction.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: transaction.type == TransactionType.credit ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTransactionSheet(context, ref, card.id);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTransactionSheet(BuildContext context, WidgetRef ref, String cardId, {TransactionModel? transactionToEdit}) {
    final amountController = TextEditingController(text: transactionToEdit?.amount.toString());
    final noteController = TextEditingController(text: transactionToEdit?.note);
    DateTime selectedDate = transactionToEdit?.date ?? DateTime.now();
    TransactionType selectedType = transactionToEdit?.type ?? TransactionType.debit;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    transactionToEdit == null ? 'Add Transaction' : 'Edit Transaction',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Amount', prefixText: '\₹ '),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Note (e.g. Grocery, Netflix)'),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: AppTheme.primaryColor,
                                onPrimary: Colors.white,
                                surface: Color(0xFF1E1E1E),
                                onSurface: Colors.white,
                              ),
                              dialogBackgroundColor: const Color(0xFF1E1E1E),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat('MMM d, y').format(selectedDate),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Debit'),
                          selected: selectedType == TransactionType.debit,
                          onSelected: (selected) => setState(() => selectedType = TransactionType.debit),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Credit'),
                          selected: selectedType == TransactionType.credit,
                          onSelected: (selected) => setState(() => selectedType = TransactionType.credit),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final amount = double.tryParse(amountController.text);
                        if (amount == null || noteController.text.isEmpty) return;

                        final transaction = TransactionModel(
                          id: transactionToEdit?.id,
                          cardId: cardId,
                          amount: amount,
                          date: selectedDate, // Use selectedDate
                          note: noteController.text,
                          type: selectedType,
                        );

                        if (transactionToEdit == null) {
                          await ref.read(transactionRepositoryProvider).addTransaction(transaction);
                        } else {
                          await ref.read(transactionRepositoryProvider).updateTransaction(transaction);
                        }
                        
                        ref.invalidate(transactionsProvider(cardId));
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: Text(transactionToEdit == null ? 'Add Transaction' : 'Update Transaction'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      },
    );
  }
}
