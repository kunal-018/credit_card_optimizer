import 'package:flutter/material.dart';
import 'package:credit_card_optimizer/widgets/app_dropdown.dart';
import 'package:credit_card_optimizer/models/card_model.dart';
import 'package:credit_card_optimizer/database/database_helper.dart';

class AddCardScreen extends StatefulWidget {
  final CardModel? card;

  const AddCardScreen({
    super.key,
    this.card,
  });
  @override
  State<AddCardScreen> createState() => _AddCardScreenState();

}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();

 String? selectedBank;
  String? selectedNetwork;
  bool get isEditMode => widget.card != null;
  String? selectedCardColor;
final cardNameController = TextEditingController();
final List<String>banks = ['SBI',
  'HDFC',
  'ICICI',
  'AXIS',
  'FEDERAL',
  'YES',
  'SBI',];
final last4DigitsController = TextEditingController();
final List<String> networks = [
  'Visa',
  'Mastercard',
  'RuPay',
  'American Express',
];
final List<String> cardColors = [
  "Blue",
  "Black",
  "Green",
  "Red",
  "Purple",
  "Grey",
  "Magenta",
  "Orange",
];
final List<int> days = List.generate(31, (index) => index + 1);
int? selectedBillingDay;
int? selectedDueDay;


  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      cardNameController.text = widget.card!.cardName;
      last4DigitsController.text = widget.card!.last4Digits;

      selectedBank = widget.card!.bankName;
      selectedNetwork = widget.card!.network;
      selectedBillingDay = widget.card!.billingDay;
      selectedDueDay = widget.card!.dueDay;
      selectedCardColor = widget.card?.cardColor;
    }
  }

  @override
void dispose() {
  cardNameController.dispose();
  last4DigitsController.dispose();
  super.dispose();
}

Future<void> saveCard() async {
if (!_formKey.currentState!.validate()) {
  return;
}

final card = CardModel(
 id: isEditMode ? widget.card!.id : null,
    cardName: cardNameController.text.trim(),
    bankName: selectedBank!,
    network: selectedNetwork!,
    cardColor: selectedCardColor!,
    billingDay: selectedBillingDay!,
    dueDay: selectedDueDay!,
    last4Digits: last4DigitsController.text.trim(),
    
    
);
if (isEditMode) {
  await DatabaseHelper.instance.updateCard(card);
} else {
  await DatabaseHelper.instance.insertCard(card);
}
if (mounted) {
  Navigator.pop(context, true);
}
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Credit Card"),
      ),
      body: SafeArea(
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Form(
      key: _formKey,
      child: Column(
      children: [

        TextFormField(
          controller: cardNameController,
          decoration: const InputDecoration(
            labelText: "Card Name",
            border: OutlineInputBorder(),
          ),
          validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter card name";
    }
    return null;
  },
        ),

        const SizedBox(height: 16),

        AppDropdown(
  label: "Bank Name",
  value: selectedBank,
  items: banks,
  onChanged: (value) {
    setState(() {
      selectedBank = value;
    });
  },
),
const SizedBox(height: 20),
AppDropdown(
  label: "Network",
  value: selectedNetwork,
  items: networks,
  onChanged: (value) {
    setState(() {
      selectedNetwork = value;
    });
  },
),

const SizedBox(height: 20),
AppDropdown<String>(
  value: selectedCardColor,
  items: cardColors,
  onChanged: (value) {
    setState(() {
      selectedCardColor = value;
    });
  },
  validator: (value) {
    if (value == null) {
      return "Select card color";
    }
    return null;
  },
  label: "Card Color",
),
const SizedBox(height: 20),
TextFormField(
        keyboardType: TextInputType.number,
          maxLength: 4,
          controller: last4DigitsController,
          decoration: const InputDecoration(
            labelText: "Last 4 Digits",
            border: OutlineInputBorder(),
            counterText: "",
          ),
           validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return "Enter last 4 digits";
    }

    if (value.length != 4) {
      return "Must be exactly 4 digits";
    }

    if (int.tryParse(value) == null) {
      return "Only numbers allowed";
    }

    return null;
  },
        ),
const SizedBox(height: 20),
Row(
  children: [

    Expanded(
      child: AppDropdown<int>(
        label: "Billing Day",
        value: selectedBillingDay,
        items: days,
        onChanged: (value) {
          setState(() {
            selectedBillingDay = value;
          });
        },
      ),
    ),

    const SizedBox(width: 16),

    Expanded(
      child: AppDropdown<int>(
        label: "Due Day",
        value: selectedDueDay,
        items: days,
        onChanged: (value) {
          setState(() {
            selectedDueDay = value;
          });
        },
      ),
    ),

  ],
),

const SizedBox(height: 16),
SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: saveCard,
    child:  Text(
      isEditMode ? "Update Card" : "Save Card",
    ),
  ),
),


      ],
    ),
  ),
),
    ),
    );
  }

}
