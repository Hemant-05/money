import 'package:flutter/material.dart';
import 'package:money_tracker/Database/DataBaseHelper.dart';
import 'package:money_tracker/Models/ExpenseModel.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({
    super.key,
  });

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<ExpenseModel> list = [];

  @override
  void initState()  {
    getList();
    super.initState();
  }

  getList() async {
    setState(() {
    });
    List<ExpenseModel> temp = [];
    var data = await DataBaseHelper.allExpenses();
    data.forEach((element) {
      temp.add(element);
    });
    list.clear();
    list.addAll(temp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: (){
          return getList();
        },
        child: ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                list[index].type,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              trailing: Text(
                '${list[index].expense}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            );
          },
        ),
      )
    );
  }
}
