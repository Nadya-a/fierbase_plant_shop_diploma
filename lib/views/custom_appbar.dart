import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true, // Центрирует текст
      title: Text(
        'Объявления',
        style: TextStyle(color: Colors.black, fontSize: 22), // Цвет текста, если необходимо
      ),
      toolbarHeight: 45.0, // Устанавливает высоту AppBar
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.0), // Высота нижней границы
        child: Container(
          height: 0.6,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white, // Цвет по краям
                Colors.grey, // Цвет в центре
                Colors.grey, // Цвет в центре
                Colors.grey, // Цвет в центре
                Colors.white, // Цвет по краям
              ],
              stops: [0.0, 0.2, 0.5, 0.8, 1.0], // Расположение перехода цветов
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
