import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../exports.dart';

class MyButton extends StatelessWidget {
  final String text;
  final void Function ()? onTap;

  const MyButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: buttonPink,
          border: Border.all(color: Colors.black45, width: 1.0), // добавляем белую границу
          borderRadius: BorderRadius.circular(40),
        ),
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
          ],
        ),
      ),
    ); // Container
  }
}
