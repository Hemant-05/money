import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/Custom/CusSnackBar.dart';
import 'package:money_tracker/Custom/CusText.dart';
import 'package:money_tracker/Database/DataBaseHelper.dart';
import 'package:money_tracker/Models/ExpenseModel.dart';
import 'package:money_tracker/Screens/ExpenseListScreen.dart';
import 'package:money_tracker/getx/ChartTimeFrame.dart';
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
  ChartTimeFrameController timeFrameController =
      Get.put(ChartTimeFrameController());

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
          month: model.month,
          year: model.year,
          time: model.time,
          day: model.day,
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
          ),
          IconButton(
              onPressed: () {
                // Get.to(ListScreen());
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListScreen(),
                  ),
                );
              },
              icon: Icon(Icons.format_list_numbered_sharp))
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              flex: 8,
              child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  series: <ChartSeries>[
                    ColumnSeries<ExpenseModel, String>(
                      color: Colors.blue,
                      dataSource: data,
                      xValueMapper: (ExpenseModel model, _) => '${model.type}',
                      yValueMapper: (ExpenseModel model, _) => model.expense,
                      name: "Expense",
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8)),
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                    )
                  ],
                ),
              ),
            Expanded(
              flex: 1,
              child: _temp(context),
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
            Expanded(flex: 14, child: _expenseListBuilder(context)),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        child: Text('Add'),
        onPressed: () {
          int id = -1;
          ExpenseModel temp = ExpenseModel(
              time: '',
              type: '',
              day: '',
              date: 0,
              month: '',
              year: 0,
              expense: -1,
              total_exp: -1,
              id: id);
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
                          int date =
                              int.parse(DateFormat.d().format(currentTime));
                          String month = DateFormat.MMM().format(currentTime);
                          int year =
                              int.parse(DateFormat.y().format(currentTime));
                          String day = DateFormat.EEEE().format(currentTime);
                          String time = DateFormat.jm().format(currentTime);
                          int exp = int.parse(expenseContoroller.value.text);
                          String type = typeContoroller.value.text;
                          ExpenseModel model;
                          int c;
                          if (isNew) {
                            model = ExpenseModel(
                              time: time.toString(),
                              month: month,
                              year: year,
                              day: day,
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
                              month: month,
                              year: year,
                              day: day,
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
                            CusSnackBar1(context, snackText);
                          } else {
                            CusSnackBar1(context, 'Error !');
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
                CusSnackBar1(context, '${deleteModel.type} deleted !!');
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
                CusSnackBar1(context, 'Not Deleted');
                Navigator.pop(context);
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  Widget _temp(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: timeFrameController.frameList.length,
      itemBuilder: (context, index) {
        return Obx(
          () => GestureDetector(
            onTap: () => timeFrameController.selectedIndex.value = index,
            child: AnimatedContainer(
              height: 10,
              width: 24,
              margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                  color: (timeFrameController.selectedIndex.value == index)
                      ? Colors.black
                      : Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  border: Border.all(color: Colors.black, width: 1)),
              duration: Duration(milliseconds: 200),
              child: Center(
                child: Text(
                  timeFrameController.frameList[index],
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: (timeFrameController.selectedIndex.value == index)
                          ? Colors.white
                          : Colors.black),
                ),
              ),
            ),
          ),
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
            text:
                '${expenses[index]['time']} | ${expenses[index]['date']}/${expenses[index]['month']}/${expenses[index]['year']}',
            size: 15,
          ),
        );
      },
    );
  }
}
