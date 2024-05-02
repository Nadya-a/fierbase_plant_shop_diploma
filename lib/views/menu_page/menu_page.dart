import 'package:flutter/material.dart';

import '../../exports.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}
class _MenuPageState extends State<MenuPage> {
  late List<Map<String, dynamic>> listings;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchListings();
  }

  Future<void> _fetchListings() async {
    try {
      List<Map<String, dynamic>> fetchedListings = await getListings();
      setState(() {
        listings = fetchedListings;
        isLoading = false; // Устанавливаем isLoading в false после загрузки данных
      });
    } catch (e) {
      print('Error fetching listings: $e');
      setState(() {
        listings = []; // В случае ошибки присваиваем пустой список
        isLoading = false; // Устанавливаем isLoading в false в случае ошибки
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        title: Text('Каталог магазина'),
        backgroundColor: backgroundGreen,
      ),
      body:  isLoading?
      Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(backgroundGreen),
        ),
      )

      :Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Поиск...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,//количество элементов в сетке на кросс-оси (горизонтальной оси в случае GridView.count).
              crossAxisSpacing: 8.0,//ространство между элементами на кросс-оси в пикселях
              mainAxisSpacing: 8.0,//пространство между элементами на основной оси (вертикальной оси)
              childAspectRatio: 0.79, // задает отношение ширины карточки к её высоте. 0.7 задает ширину карточки в 70% от её высоты
              children: List.generate(
                listings.length, // Используем widget.listings для доступа к списку listings
                    (index) {
                  return PlantCard(
                    name: listings[index]['name'],
                    description: listings[index]['description'],
                    imageURL: listings[index]['imageURL'],
                    price: listings[index]['price'],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}