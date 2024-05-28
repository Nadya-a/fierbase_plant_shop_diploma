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
          title: Text('Мои объявления'),
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
