class ExpenseModel {
  final int date;
  final String month;
  final String day;
  final int year;
  final String time;
  final int expense;
  final String type;
  final int? total_exp;

  ExpenseModel(
      {required this.month,
      required this.year,
      required this.day,
      required this.time,
      required this.type,
      required this.date,
      required this.expense,
      this.id,
      this.total_exp});

  final int? id;

  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'year': year,
      'time': time,
      'day' : day,
      'type': type,
      'date': date,
      'expense': expense,
      'id': id,
      'total_exp': total_exp,
    };
  }

  factory ExpenseModel.fromjson(Map<String, dynamic> json) {
    return ExpenseModel(
      month: json['month'],
      year: json['year'],
      day: json['day'],
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
    return 'ExpenseModel{day : $day, month : $month,year : $year,time: $time, type: $type, date: $date, expense : $expense, total_exp : $total_exp}';
  }
}
