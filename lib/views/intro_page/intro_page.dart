import 'package:flutter/material.dart';

import '../../exports.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/indoor-plant2.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(14.0),
                  // decoration: BoxDecoration(
                  //   color: Colors.white,
                  //   borderRadius: BorderRadius.circular(20.0),
                  // ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      SizedBox(height: 20),
                      Text(
                        "Garden Market",
                        style: TextStyle(
                          fontFamily: 'Neris-Black',
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "Превратите свой дом в зеленый рай",
                        style: TextStyle(
                          fontFamily: 'Neris-Black',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 96.0),
                SizedBox(height: 180),
                SizedBox(height: 105),
                MyButton(
                  text: "Перейти к каталогу",
                  onTap: () {
                    Navigator.pushNamed(context, '/menupage');
                  },
                ),
                MyButton(
                  text: "Войти в аккаунт",
                  onTap: () async {
                    goToLogin(context);
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  goToLogin(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );
}
