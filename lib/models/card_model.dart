class CardModel {
  int? id;
  String cardName;
  int billingDay;
  int dueDay;
  String bankName;
  String network;
  String last4Digits;
  String cardColor;

  CardModel({
    this.id,
    required this.cardName,
    required this.billingDay,
    required this.dueDay,
    required this.bankName,
    required this.network,
    required this.last4Digits,
    required this.cardColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cardName': cardName,
      'billingDay': billingDay,
      'dueDay': dueDay,
      'bankName': bankName,
      'network': network,
      'last4Digits': last4Digits,
      'cardColor': cardColor,
    };
  }

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'],
      cardName: map['cardName'],
      billingDay: map['billingDay'],
      dueDay: map['dueDay'],
      bankName: map['bankName'],
      network: map['network'],
      last4Digits: map['last4Digits'],
      cardColor: map['cardColor'],
    );
  }
}