class PaymentRecord {
  final int? id;
  final int cardId;
  final DateTime dueDate;
  final bool isPaid;
  final DateTime? paidDate;

  PaymentRecord({
    this.id,
    required this.cardId,
    required this.dueDate,
    required this.isPaid,
    this.paidDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cardId': cardId,
      'dueDate': dueDate.toIso8601String(),
      'isPaid': isPaid ? 1 : 0,
      'paidDate': paidDate?.toIso8601String(),
    };
  }

  factory PaymentRecord.fromMap(Map<String, dynamic> map) {
    return PaymentRecord(
      id: map['id'],
      cardId: map['cardId'],
      dueDate: DateTime.parse(map['dueDate']),
      isPaid: map['isPaid'] == 1,
      paidDate: map['paidDate'] != null
          ? DateTime.parse(map['paidDate'])
          : null,
    );
  }
}