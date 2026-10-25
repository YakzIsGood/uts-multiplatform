class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final String type; // 'income' atau 'expense'
  final String date;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
  });

  // Mengubah objek menjadi Map untuk disimpan ke SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'date': date,
    };
  }

  // Mengubah Map dari SQLite kembali menjadi objek
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      type: map['type'],
      date: map['date'],
    );
  }
}