import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/card_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/card_repository.dart';
import '../card_stack_screen.dart'; // For invalidating provider

class CardWidget extends ConsumerWidget {
  final CardModel card;

  const CardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassContainer(
      height: 220,
      width: double.infinity,
      borderRadius: BorderRadius.circular(20),
      blur: 15,
      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      gradient: LinearGradient(
        colors: _getCardColors(card.colorIndex),
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Bank Name and Card Type
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.bankName.toUpperCase(),
                          style: GoogleFonts.sourceCodePro(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          card.cardType.name.toUpperCase(),
                          style: GoogleFonts.sourceCodePro(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),

                    // Card Sub-category
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        card.subCategory.toUpperCase(),
                        style: GoogleFonts.sourceCodePro(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          card.formattedCardNumber,
                          style: GoogleFonts.sourceCodePro(
                            fontSize: 20, 
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        return IconButton(
                          icon: const Icon(Icons.copy, color: Colors.white, size: 20),
                          tooltip: "Copy Number",
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () async {
                            Clipboard.setData(ClipboardData(text: card.cardNumber));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Card number copied!')),
                            );
                            
                            // Increment usage count
                            await ref.read(cardRepositoryProvider).incrementUsageCount(card.id);
                            ref.invalidate(cardsProvider);
                          },
                        );
                      }
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HOLDER', style: GoogleFonts.sourceCodePro(fontSize: 9, color: Colors.white60)),
                        const SizedBox(height: 2),
                        Text(
                          card.holderName.toUpperCase(),
                          style: GoogleFonts.sourceCodePro(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EXPIRES', style: GoogleFonts.sourceCodePro(fontSize: 9, color: Colors.white60)),
                        const SizedBox(height: 2),
                        Text(
                          card.expiryDate,
                          style: GoogleFonts.sourceCodePro(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CVV', style: GoogleFonts.sourceCodePro(fontSize: 9, color: Colors.white60)),
                        const SizedBox(height: 2),
                        Text(
                          card.cvv,
                          style: GoogleFonts.sourceCodePro(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getCardColors(int index) {
    const options = [
      [Color(0xFF1A2980), Color(0xFF26D0CE)], // Blue
      [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // Purple
      [Color(0xFFee9ca7), Color(0xFFffdde1)], // Pink
      [Color(0xFF000000), Color(0xFF434343)], // Black
    ];
    // Safety check
    if (index < 0 || index >= options.length) return options[0];
    return options[index];
  }
}
