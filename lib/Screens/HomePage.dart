import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:money_tracker/Custom/CusText.dart';
import 'package:money_tracker/Database/DataBaseHelper.dart';
import 'package:money_tracker/Models/ExpenseModel.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class SalesData {
  final String month;
  final int year;

  SalesData(this.month, this.year);
}

class _HomePageState extends State<HomePage> {
  TextEditingController typeContoroller = TextEditingController();
  TextEditingController expenseContoroller = TextEditingController();
  List<Map<String, dynamic>> expenses = [];
  int total_exp = 0;
  final List<ExpenseModel> data = [];

  @override
  void initState() {
    refresh();
    super.initState();
  }

  refresh() async {
    getAllExpense();
    await Future.delayed(Duration(milliseconds: 100));
    getAllExpense();
    await Future.delayed(Duration(milliseconds: 100));
    getIntoExpModel(expenses);
    // await Future.delayed(Duration(milliseconds: 100));
    // getIntoExpModel(expenses);
  }

  getAllExpense() async {
    setState(() {});
    List<Map<String, dynamic>> temp = [];
    var data = await DataBaseHelper.allExpenses();
    for (var value in data) {
      temp.add(value.toMap());
    }
    if (temp.length == 0) {
      total_exp = 0;
    } else {
      total_exp = data[temp.length - 1].total_exp!;
    }
    expenses.clear();
    expenses.addAll(temp);
  }

  updateTotalExpInList() async {
    ExpenseModel model;
    int to = 0;
    for (int i = 0; i < expenses.length; i++) {
      ExpenseModel temp;
      model = ExpenseModel.fromjson(expenses[i]);
      /*int old_total =  expenses[i - 1]['total_exp'];
      int new_total = model.expense! + old_total;*/
      to += model.expense;
      temp = ExpenseModel(
          time: model.time,
          type: model.type,
          date: model.date,
          expense: model.expense,
          id: model.id,
          total_exp: to);
      await DataBaseHelper.update(temp);
    }
  }

  getIntoExpModel(List<Map<String, dynamic>> list) {
    setState(() {});
    List<ExpenseModel> temp = [];
    list.forEach((element) {
      temp.add(ExpenseModel.fromjson(element));
    });
    data.clear();
    data.addAll(temp);
  }

  customSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        padding: const EdgeInsets.all(12),
        behavior: SnackBarBehavior.floating,
        width: 180,
        duration: Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Expenses'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => refresh(),
            icon: Icon(
              Icons.refresh,
            ),
            tooltip: 'Refresh',
          )
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              flex: 8,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                // primaryYAxis:  NumericAxis(minimum: 0,interval: 40,maximum : 100),
                series: <ChartSeries<ExpenseModel, int>>[
                  ColumnSeries<ExpenseModel, int>(
                    color: Colors.blue,
                    dataSource: data,
                    xValueMapper: (ExpenseModel model, _) => model.expense,
                    yValueMapper: (ExpenseModel model, _) => model.expense,
                    name: "Expense",
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(8)),
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  'Total Expense : $total_exp ₹',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(flex: 10, child: _expenseListBuilder(context)),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        child: Text('Add'),
        onPressed: () {
          int id = -1;
          ExpenseModel temp = ExpenseModel(
              time: '', type: '', date: '', expense: -1, total_exp: -1, id: id);
          _openAddDialog(context, 'New Expense', 'ADD', true, temp);
        },
      ),
    );
  }

  Future _openAddDialog(BuildContext context, String title, String btText,
      bool isNew, ExpenseModel temp) {
    if (temp.total_exp != -1) {
      typeContoroller.text = temp.type;
      expenseContoroller.text = '${temp.expense}';
    } else {
      typeContoroller.clear();
      expenseContoroller.clear();
    }
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(title),
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                child: Column(
                  children: [
                    TextField(
                      controller: typeContoroller,
                      decoration: InputDecoration(hintText: 'Type of Expense'),
                    ),
                    TextField(
                      controller: expenseContoroller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(hintText: 'Total Amount'),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          var currentTime = DateTime.now();
                          String date = DateFormat.yMMMd().format(currentTime);
                          String time = DateFormat.jm().format(currentTime);
                          int exp = int.parse(expenseContoroller.value.text);
                          String type = typeContoroller.value.text;
                          ExpenseModel model;
                          int c;
                          if (isNew) {
                            model = ExpenseModel(
                              time: time.toString(),
                              type: type,
                              date: date,
                              expense: exp,
                              total_exp: total_exp + exp,
                            );
                            c = await DataBaseHelper.insert(model);
                          } else {
                            model = ExpenseModel(
                              time: temp.time.toString(),
                              type: '$type*',
                              date: temp.date,
                              expense: exp,
                              total_exp: total_exp,
                              id: temp.id,
                            );
                            c = await DataBaseHelper.update(model);
                            refresh();
                            await Future.delayed(
                                const Duration(milliseconds: 100));
                            updateTotalExpInList();
                          }
                          String snackText = (isNew)
                              ? 'Added successefully'
                              : 'Updated Successefully';
                          if (c != 0) {
                            expenseContoroller.clear();
                            typeContoroller.clear();
                            customSnackBar(context, snackText);
                          } else {
                            customSnackBar(context, 'Error !');
                          }
                          refresh();
                          Navigator.pop(context);
                        },
                        child: Text(btText)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future _openDeleteDialog(BuildContext context, ExpenseModel deleteModel) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const CusText(
            text: 'Delete....',
            size: 25,
          ),
          content: CusText(
            text: 'Are you sure ? \n To delete ${deleteModel.type}',
            size: 16,
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                int? id = deleteModel.id;
                await DataBaseHelper.delete(id!);
                customSnackBar(context, '${deleteModel.type} deleted !!');
                refresh();
                await Future.delayed(const Duration(milliseconds: 50));
                updateTotalExpInList();
                await Future.delayed(const Duration(milliseconds: 50));
                refresh();
                Navigator.pop(context);
              },
              child: Text('Yes'),
            ),
            ElevatedButton(
              onPressed: () {
                customSnackBar(context, 'Not Deleted');
                Navigator.pop(context);
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  Widget _expenseListBuilder(BuildContext context) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        int expense = expenses[index]['expense'];
        int id = expenses[index]['id'];
        String type = expenses[index]['type'];
        ExpenseModel temp = ExpenseModel.fromjson(expenses[index]);
        return ListTile(
          onTap: () {
            _openAddDialog(
                context, 'Update $type Expense', 'Edit', false, temp);
          },
          onLongPress: () {
            _openDeleteDialog(context, ExpenseModel.fromjson(expenses[index]));
          },
          title: CusText(
            text: type,
            size: 20,
          ),
          trailing: CusText(
            text: '$expense ₹',
            size: 20,
          ),
          subtitle: CusText(
            text: '${expenses[index]['time']} | ${expenses[index]['date']}',
            size: 15,
          ),
        );
      },
    );
  }
}
