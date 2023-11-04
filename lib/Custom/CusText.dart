import 'package:flutter/material.dart';

class CusText extends StatelessWidget {
  const CusText({super.key, required this.text, required this.size});
  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(text,
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: size,
    ),);
  }
}
