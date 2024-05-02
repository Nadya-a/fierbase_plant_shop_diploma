import 'package:flutter/material.dart';

import '../../exports.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGreen,
      body: Padding(
        padding: EdgeInsets.all(25.0),
        child: Column (
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 25),
              const Text(
                "Garden Market",
                style: TextStyle(
                  fontFamily: 'Neris-Black', // Укажите название вашего шрифта
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              //const SizedBox(height: 25),
              // icon
              Padding(
                padding: EdgeInsets.all(50.0),
                child: Image.asset('assets/images/logo.png'),
              ), // Padding

              const Text(
                "Превратите свой дом в зеленый рай!",
                style: TextStyle(
                  fontFamily: 'Neris-Black', // Укажите название вашего шрифта
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),

              /* const Text("FoliageHub Garden Market - ваш путь к красоте и уюту!",
                style: TextStyle(
                  //fontFamily: 'Neris-Black', // Укажите название вашего шрифта
                  fontSize: 22,
                  color: Colors.grey,
                  height: 1.5
                ),
              ), */

              //const SizedBox(height: 25),

              MyButton(
                  text: "Get started",
                onTap: () {
                    Navigator.pushNamed(context, '/menupage');
                },
              ),
            ]
        ),
      ),
    );
  }

}
