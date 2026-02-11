import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../data/card_repository.dart';
import '../domain/card_model.dart';
import 'add_card_screen.dart';
import 'widgets/card_widget.dart';
import 'card_detail_screen.dart';
import '../../transactions/domain/transaction_model.dart'; // Import TransactionType
import '../../settings/presentation/settings_screen.dart';

// Provider to fetch cards
final cardsProvider = FutureProvider<List<CardModel>>((ref) async {
  final repo = ref.watch(cardRepositoryProvider);
  return repo.getAllCards();
});

// State for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered and Sorted cards provider
final filteredCardsProvider = Provider<List<CardModel>>((ref) {
  final cards = ref.watch(cardsProvider).value ?? [];
  final query = ref.watch(searchQueryProvider).toLowerCase();
  
  // Sort by usage count descending (frequently accessed first)
  final sortedCards = List<CardModel>.from(cards)
    ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
  
  if (query.isEmpty) return sortedCards;
  
  return sortedCards.where((card) {
    return card.bankName.toLowerCase().contains(query) ||
           card.holderName.toLowerCase().contains(query) ||
           card.subCategory.toLowerCase().contains(query) ||
           card.cardNumber.endsWith(query); // Search by last 4 digits
  }).toList();
});

class CardStackScreen extends ConsumerWidget {
  const CardStackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch filtered cards instead of raw cardsProvider
    final cards = ref.watch(filteredCardsProvider);
    final isLoading = ref.watch(cardsProvider).isLoading;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Cards'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: 'Search cards...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddCardScreen()),
              );
              // Refresh cards
              ref.invalidate(cardsProvider);
            },
          ),
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : cards.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.credit_card_off, size: 64, color: Colors.white24),
                    const SizedBox(height: 16),
                    Text(
                      ref.read(searchQueryProvider).isEmpty 
                        ? 'No cards added yet' 
                        : 'No cards found',
                      style: const TextStyle(color: Colors.white54),
                    ),
                    if (ref.read(searchQueryProvider).isEmpty) ...[
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                           await Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) => const AddCardScreen()),
                           );
                           ref.invalidate(cardsProvider);
                        }, 
                        child: const Text("Add Your First Card")
                      )
                    ]
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: cards.length,
                separatorBuilder: (context, index) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final card = cards[index];
                  // Calculate total debited
                  final transactionsAsync = ref.watch(transactionsProvider(card.id));
                  
                  return GestureDetector(
                    onTap: () async {
                        // Increment usage count
                        await ref.read(cardRepositoryProvider).incrementUsageCount(card.id);
                        // Invalidate provider to refresh sort order
                        ref.invalidate(cardsProvider);
                        
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CardDetailScreen(card: card),
                            ),
                          );
                        }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: card.id,
                          child: CardWidget(card: card),
                        ),
                        const SizedBox(height: 8),
                        transactionsAsync.when(
                          data: (transactions) {
                            // Calculate spent amount
                            double spent = 0;
                            for (var t in transactions) {
                              if (t.type == TransactionType.debit) spent += t.amount;
                              if (t.type == TransactionType.credit) spent -= t.amount;
                            }
                            
                            Color valueColor = Colors.white70;
                            if (spent > 0) {
                              valueColor = Colors.red;
                            } else if (spent < 0) {
                              valueColor = Colors.green;
                            }

                            return Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                "Total Debited: \₹${spent.toStringAsFixed(2)}",
                                style: TextStyle(color: valueColor, fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                          loading: () => const SizedBox(),
                          error: (_, __) => const SizedBox(),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}

