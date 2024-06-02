import 'package:flutter/material.dart';
import 'menu_page/components/old_bottom_navigation_bar.dart'; // Путь к вашему BottomNavBar
import '../exports.dart';

class BasePage extends StatefulWidget {
  final Widget child;
  final int selectedIndex; // Новый аргумент для хранения текущего индекса

  const BasePage({Key? key, required this.child, required this.selectedIndex}) : super(key: key);

  @override
  _BasePageState createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    // Устанавливаем значение _selectedIndex из переданного аргумента конструктора
    _selectedIndex = widget.selectedIndex;
  }

  void _onMenuItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Добавляем обработку нажатия на элементы BottomNavigationBar
    switch (index) {
      case 0: // Поиск
        Navigator.pushNamed(context, '/menupage');
        break;
      case 1:
          Navigator.pushNamed(context, '/favorites');
      case 2: // Объявления
        // Переходим на страницу объявлений
        Navigator.pushNamed(context, '/listingspage');
        break;
      case 3: // Чаты
      // Переходим на страницу объявлений
        Navigator.pushNamed(context, '/chats');
        break;
      case 4: //Профиль
        Navigator.pushNamed(context, '/userprofile');
        break;
    // Другие кейсы для других элементов
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onMenuItemTapped,
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      onTap: onItemTapped,
      currentIndex: selectedIndex,
      unselectedItemColor: Colors.grey,
      unselectedFontSize: 14,
      selectedItemColor: Colors.black,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Поиск',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Избранное',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Объявления',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Сообщения',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Профиль',
        ),
      ],
    );
  }
}
