import 'package:flutter/material.dart';
import '../../exports.dart';
import '../menu_page/recommendation_algorithm.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Map<String, dynamic>> _listings = [];
  List<Map<String, dynamic>> favorites = [];
  List<Map<String, dynamic>> recommendations = [];
  bool _isLoading = true;
  String _searchQuery = '';
  late String? typeId = '';
  late String? speciesId = '';
  late int? minPrice = 0;
  late int? maxPrice = 10000000;

  @override
  void initState() {
    super.initState();
    _fetchListings(typeId, speciesId, minPrice, maxPrice);
    _fetchRecommendations();
  }

  Future<void> _fetchListings(String? typeId, String? speciesId, int? minPrice, int? maxPrice) async {
    try {
      List<Map<String, dynamic>> fetchedListings = await getListings(typeId, speciesId, minPrice, maxPrice);
      List<Map<String, dynamic>> favoriteListings = await fetchFavoritesFromDatabase();

      setState(() {
        _listings = fetchedListings.map((listing) {
          listing['isFavorite'] =
              favoriteListings.any((favorite) => favorite['documentId'] == listing['documentId']);
          return listing;
        }).toList();
        favorites = favoriteListings;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching listings: $e');
      setState(() {
        _listings = [];
        favorites = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchRecommendations() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid; // Метод для получения текущего userId
      List<String> activityIds = await fetchUserActivities(userId!);
      print(activityIds);
      List<Map<String, dynamic>> fetchedRecommendations = await getRecommendations(activityIds);

      setState(() {
        recommendations = fetchedRecommendations;
      });
    } catch (e) {
      print('Error fetching recommendations: $e');
    }
  }

  Future<void> _toggleFavorite(String listingId) async {
    setState(() {
      _listings = _listings.map((listing) {
        if (listing['documentId'] == listingId) {
          listing['isFavorite'] = !(listing['isFavorite'] ?? false);
        }
        return listing;
      }).toList();
    });

    try {
      await toggleFavorite(listingId);
    } catch (e) {
      print('Error toggling favorite: $e');
      setState(() {
        _listings = _listings.map((listing) {
          if (listing['documentId'] == listingId) {
            listing['isFavorite'] = !(listing['isFavorite'] ?? false);
          }
          return listing;
        }).toList();
      });
    }
  }

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredListings = _listings.where((listing) {
      return listing['name'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return BasePage(
      selectedIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Убирает стрелку "назад"
          title: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Поиск...',
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.grey[200], // Устанавливает светло-серый фон
                  ),
                  style: TextStyle(color: Colors.black),
                  onChanged: _updateSearchQuery,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0), // Уменьшает расстояние
                child: IconButton(
                  icon: Icon(Icons.tune, color: Colors.black),
                  onPressed: () async {
                    // Открываем FilterDialog и ждем возвращения выбранных фильтров
                    final filters = await Navigator.push(context, MaterialPageRoute(builder: (context) => FilterDialog()));

                    // Используем выбранные фильтры
                    if (filters != null) {
                      _isLoading = true;
                      typeId = filters['typeId'];
                      speciesId = filters['speciesId'];
                      minPrice = filters['minPrice'];
                      maxPrice = filters['maxPrice'];
                      _fetchListings(typeId, speciesId, minPrice, maxPrice);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        body: _isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(backgroundGreen),
          ),
        )
            : filteredListings.isEmpty
            ? Center(
          child: Text('Нет доступных объявлений'),
        )
            : Column(
          children: [
            SizedBox(height: 8,),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Рекомендации для вас',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            // Блок рекомендаций
            SizedBox(
              height: 254, // Устанавливаем высоту для прокручиваемого списка
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  var listing = recommendations[index];
                  return Container(
                    width: MediaQuery.of(context).size.width / 2, // Устанавливаем ширину для элементов
                    child: PlantCard(
                      name: listing['name'],
                      description: listing['description'],
                      imageURL: listing['imageURL'],
                      documentId: listing['documentId'],
                      price: listing['price'],
                      speciesId: listing['species_id'],
                      typeId: listing['type_id'],
                      height: listing['height'],
                      width: listing['width'],
                      isFavorite: listing['isFavorite'] ?? false,
                      onFavoriteToggle: () => _toggleFavorite(listing['documentId']),
                      userID: listing['userID'],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 8,),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Все объявления',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            // Основной список объявлений
            Expanded(

              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.79,
                ),
                itemCount: filteredListings.length,
                itemBuilder: (context, index) {
                  var listing = filteredListings[index];
                  return PlantCard(
                    name: listing['name'],
                    description: listing['description'],
                    imageURL: listing['imageURL'],
                    documentId: listing['documentId'],
                    price: listing['price'],
                    speciesId: listing['species_id'],
                    typeId: listing['type_id'],
                    height: listing['height'],
                    width: listing['width'],
                    isFavorite: listing['isFavorite'] ?? false,
                    onFavoriteToggle: () => _toggleFavorite(listing['documentId']),
                    userID: listing['userID'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
