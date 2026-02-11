import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import '../../../../core/theme/app_theme.dart';
import '../domain/card_model.dart';
import '../data/card_repository.dart';

class AddCardScreen extends HookConsumerWidget {
  final CardModel? cardToEdit; // Parameter for edit mode

  const AddCardScreen({super.key, this.cardToEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useRef(GlobalKey<FormState>());
    // Controllers for text inputs
    final bankNameController = useTextEditingController(text: cardToEdit?.bankName);
    final subCategoryController = useTextEditingController(text: cardToEdit?.subCategory);
    final holderNameController = useTextEditingController(text: cardToEdit?.holderName);
    final cardNumberController = useTextEditingController(text: cardToEdit?.cardNumber);
    final expiryDateController = useTextEditingController(text: cardToEdit?.expiryDate);
    final cvvController = useTextEditingController(text: cardToEdit?.cvv);
    final creditLimitController = useTextEditingController(text: cardToEdit?.creditLimit?.toString());
    
    // Dropdown selections state
    final selectedBankDropdown = useState<String?>(cardToEdit != null ? (['HDFC', 'SBI', 'ICICI', 'Axis', 'Kotak', 'Yes Bank', 'RBL Bank', 'SBM Bank', 'Union Bank', 'HSBC', 'IDFC First Bank', 'IndusInd Bank', 'Other'].contains(cardToEdit!.bankName) ? cardToEdit!.bankName : 'Other') : 'HDFC');
    final selectedSubCategoryDropdown = useState<String?>(cardToEdit != null ? (['Amazon Pay', 'Flipkart Axis', 'Privilege', 'Amex Privilege', 'Cashback', 'Neo', 'Swiggy HDFC', 'Tata Neu', 'Millennia', 'Regalia', 'Coral', 'Sapphiro', 'Other'].contains(cardToEdit!.subCategory) ? cardToEdit!.subCategory : 'Other') : 'Amazon Pay');
    
    final selectedCardType = useState(cardToEdit?.cardType ?? CardType.credit);
    final selectedColorIndex = useState(cardToEdit?.colorIndex ?? 0);

    // Initial setup to sync dropdowns with controllers
    useEffect(() {
      if (selectedBankDropdown.value != 'Other') {
        bankNameController.text = selectedBankDropdown.value ?? '';
      }
      if (selectedSubCategoryDropdown.value != 'Other') {
        subCategoryController.text = selectedSubCategoryDropdown.value ?? '';
      }
      return null;
    }, []);

    return Scaffold(
      backgroundColor: Colors.black, // Deep black background
      appBar: AppBar(
        title: Text(cardToEdit == null ? 'Add New Card' : 'Edit Card'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card Preview
              GlassContainer(
                height: 220,
                width: double.infinity,
                borderRadius: BorderRadius.circular(20),
                blur: 20,
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Stack(
                  children: [
                    // Background Pattern/Gradient based on selection
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: _getCardColors(selectedColorIndex.value),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
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
                              Text(
                                bankNameController.text.isEmpty ? 'Bank Name' : bankNameController.text.toUpperCase(),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                selectedCardType.value.name.toUpperCase(),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            cardNumberController.text.isEmpty ? '**** **** **** ****' : cardNumberController.text,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(letterSpacing: 2),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('CARD HOLDER', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10)),
                                  Text(
                                    holderNameController.text.isEmpty ? 'YOUR NAME' : holderNameController.text.toUpperCase(),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              // Sub-category (replacing expiry in preview or adding it?)
                              // Let's keep expiry, maybe add sub-category somewhere small or replacing Network logo
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    subCategoryController.text.isEmpty ? 'SUB-CATEGORY' : subCategoryController.text.toUpperCase(),
                                     style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white70),
                                  ),
                                  Text(
                                    expiryDateController.text.isEmpty ? 'MM/YY' : expiryDateController.text,
                                    style: Theme.of(context).textTheme.bodyMedium,
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
              ),
              const SizedBox(height: 30),

              // Bank Name Input (Dropdown + Text)
              DropdownButtonFormField<String>(
                value: selectedBankDropdown.value,
                items: ['HDFC', 'SBI', 'ICICI', 'Axis', 'Kotak', 'Yes Bank', 'RBL Bank', 'SBM Bank', 'Union Bank', 'HSBC', 'IDFC First Bank', 'IndusInd Bank', 'Other']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  selectedBankDropdown.value = v;
                  if (v != 'Other') {
                    bankNameController.text = v!;
                  } else {
                    bankNameController.clear();
                  }
                  formKey.value.currentState?.setState(() {});
                },
                decoration: const InputDecoration(labelText: 'Select Bank', prefixIcon: Icon(Icons.account_balance)),
              ),
              if (selectedBankDropdown.value == 'Other') ...[
                 const SizedBox(height: 10),
                 TextFormField(
                  controller: bankNameController,
                  decoration: const InputDecoration(labelText: 'Enter Custom Bank Name', prefixIcon: Icon(Icons.edit)),
                  onChanged: (_) => formKey.value.currentState?.setState(() {}),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Sub Category Input (Dropdown + Text)
              DropdownButtonFormField<String>(
                value: selectedSubCategoryDropdown.value,
                items: ['Amazon Pay', 'Flipkart Axis', 'Privilege', 'Amex Privilege', 'Cashback', 'Neo', 'Swiggy HDFC', 'Tata Neu', 'Millennia', 'Regalia', 'Coral', 'Sapphiro', 'Other']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  selectedSubCategoryDropdown.value = v;
                  if (v != 'Other') {
                    subCategoryController.text = v!;
                  } else {
                    subCategoryController.clear();
                  }
                  formKey.value.currentState?.setState(() {});
                },
                decoration: const InputDecoration(labelText: 'Card Sub-Category', prefixIcon: Icon(Icons.category)),
              ),
              if (selectedSubCategoryDropdown.value == 'Other') ...[
                 const SizedBox(height: 10),
                 TextFormField(
                  controller: subCategoryController,
                  decoration: const InputDecoration(labelText: 'Enter Sub-Category (e.g. Platinum)', prefixIcon: Icon(Icons.edit)),
                  onChanged: (_) => formKey.value.currentState?.setState(() {}),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ],


              const SizedBox(height: 16),
              TextFormField(
                controller: holderNameController,
                decoration: const InputDecoration(labelText: 'Card Holder Name', prefixIcon: Icon(Icons.person)),
                onChanged: (_) => formKey.value.currentState?.setState(() {}),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: cardNumberController,
                decoration: const InputDecoration(labelText: 'Card Number', prefixIcon: Icon(Icons.credit_card)),
                keyboardType: TextInputType.number,
                maxLength: 19,
                onChanged: (_) => formKey.value.currentState?.setState(() {}),
                validator: (v) => v!.length < 16 ? 'Invalid Card Number' : null,
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              Row(
                children: [
                   Expanded(
                    child: TextFormField(
                      controller: expiryDateController,
                      decoration: const InputDecoration(labelText: 'Expiry (MM/YY)', prefixIcon: Icon(Icons.date_range)),
                      onChanged: (_) => formKey.value.currentState?.setState(() {}),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                      maxLength: 5,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                        CardExpiryInputFormatter(mask: 'MM/YY'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: cvvController,
                      decoration: const InputDecoration(labelText: 'CVV', prefixIcon: Icon(Icons.lock)),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      onChanged: (_) => formKey.value.currentState?.setState(() {}),
                      
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              DropdownButtonFormField<CardType>(
                value: selectedCardType.value,
                items: CardType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name.toUpperCase()))).toList(),
                onChanged: (v) => selectedCardType.value = v!,
                decoration: const InputDecoration(labelText: 'Card Type', prefixIcon: Icon(Icons.credit_card)),
              ),
              
              if (selectedCardType.value == CardType.credit) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: creditLimitController,
                  decoration: const InputDecoration(labelText: 'Credit Limit', prefixIcon: Icon(Icons.attach_money)),
                  keyboardType: TextInputType.number,
                ),
              ],

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.value.currentState!.validate()) {
                    final card = CardModel(
                      id: cardToEdit?.id, // Preserve ID for updates
                      bankName: bankNameController.text,
                      holderName: holderNameController.text,
                      cardNumber: cardNumberController.text,
                      expiryDate: expiryDateController.text,
                      cvv: cvvController.text,
                      cardType: selectedCardType.value,
                      subCategory: subCategoryController.text, // Updated
                      colorIndex: selectedColorIndex.value,
                      creditLimit: double.tryParse(creditLimitController.text),
                      usageCount: cardToEdit?.usageCount ?? 0, // Preserve usage count
                    );

                    await ref.read(cardRepositoryProvider).addCard(card); // addCard uses put() so it updates if ID exists
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text(cardToEdit == null ? 'Add Card' : 'Update Card'),
              ),
            ],
          ),
        ),
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
    return options[index % options.length];
  }
}

class CardExpiryInputFormatter extends TextInputFormatter {
  final String mask;
  CardExpiryInputFormatter({required this.mask});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != newText.length) {
        buffer.write('/');
      }
    }

    final string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}
