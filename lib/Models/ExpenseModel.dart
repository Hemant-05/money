class ExpenseModel {
  final String date;
  final String time;
  final int expense;
  final String type;
  final int? total_exp;

  ExpenseModel(
      {required this.time,
      required this.type,
      required this.date,
      required this.expense,
      this.id,
      this.total_exp});

  final int? id;

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'type': type,
      'date': date,
      'expense': expense,
      'id': id,
      'total_exp' : total_exp,
    };
  }

  factory ExpenseModel.fromjson(Map<String, dynamic> json) {
    return ExpenseModel(
        time: json['time'],
        type: json['type'],
        date: json['date'],
        expense: json['expense'],
        id: json['id'],
      total_exp: json['total_exp'],
    );
  }
  @override
  String toString() {
    return 'ExpenseModel{time: $time, type: $type, date: $date, expense : $expense, total_exp : $total_exp}';
  }
}
