import 'package:flutter/material.dart';
import '../../../exports.dart';

class ListingsPage extends StatefulWidget {
  const ListingsPage({Key? key}) : super(key: key);

  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  List<Map<String, dynamic>> _listings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserAuthentication();
  }

  Future<void> _checkUserAuthentication() async {
    // Получаем текущего авторизованного пользователя
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Если пользователь авторизован, получаем список его объявлений
      String userId = user.uid;
      List<Map<String, dynamic>> userlistings = await getUsersListings(userId);

      setState(() {
        _listings = userlistings;
        _isLoading = false;
      });
    } else {
      // Если пользователь не авторизован, устанавливаем флаг isLoading в false
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      selectedIndex: 2,
      child: Scaffold(
        appBar: AppBar(
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
        ),

        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _listings.isEmpty
            ? Center(
          child: Text('Войдите в аккаунт, чтобы создать объявление'),)
            : ListView.builder(
          itemCount: _listings.length,
          itemBuilder: (context, index) {
            // Здесь создайте карточку для каждого объявления в списке _listings
            return buildListingCard(_listings[index], context); // Вызов функции buildListingCard
          },
        ),
        floatingActionButton: Theme(
          data: ThemeData(
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: backgroundGreen, // Задаем цвет фона для кнопки
              foregroundColor: Colors.white, // Задаем цвет иконки
            ),
          ),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectTypePage(
                  ),
                ),
              );
            },
            child: Icon(Icons.add),
          ),
        ),

      ),
    );
  }

}
