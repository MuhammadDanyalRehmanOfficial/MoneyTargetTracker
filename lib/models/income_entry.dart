// lib/models/income_entry.dart
class IncomeEntry {
  final String id;
  final double amount;
  final DateTime timestamp;
  final String note;

  IncomeEntry({
    required this.id,
    required this.amount,
    required this.timestamp,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'note': note,
      };

  factory IncomeEntry.fromJson(Map<String, dynamic> json) => IncomeEntry(
        id: json['id'],
        amount: json['amount'].toDouble(),
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
        note: json['note'] ?? '',
      );

  IncomeEntry copyWith({
    String? id,
    double? amount,
    DateTime? timestamp,
    String? note,
  }) {
    return IncomeEntry(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }
}