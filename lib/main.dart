import 'package:flutter/material.dart';
import 'package:money_tracker/Database/DataBaseHelper.dart';
import 'package:money_tracker/Screens/IntroPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DataBaseHelper.getDB();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Money Tracker',
      home: IntroPage(),
    );
  }
}

