import 'package:flutter/material.dart';
import '../../exports.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Map<String, dynamic>> _listings = [];
  List<Map<String, dynamic>> favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchListings();
  }

  Future<void> _fetchListings() async {
    try {
      List<Map<String, dynamic>> fetchedListings = await getListings();
      List<Map<String,
          dynamic>> favoriteListings = await fetchFavoritesFromDatabase();

      // Обновляем состояние с полученными данными
      setState(() {
        _listings = fetchedListings.map((listing) {
          listing['isFavorite'] =
              favoriteListings.any((favorite) => favorite['documentId'] ==
                  listing['documentId']);
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

  @override
  Widget build(BuildContext context) {
    return BasePage(
      selectedIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Объявления'),
          backgroundColor: backgroundGreen,
        ),
        body: _isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(backgroundGreen),
          ),
        )
            : _listings.isEmpty
            ? Center(
          child: Text('Нет доступных объявлений'),
        )
            : GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.79,
          ),
          itemCount: _listings.length,
          itemBuilder: (context, index) {
            var listing = _listings[index];
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
            );
          },
        ),
      ),
    );
  }
}
