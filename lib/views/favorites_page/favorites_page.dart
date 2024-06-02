import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../exports.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    try {
      List<Map<String, dynamic>> fetchedListings = await fetchFavoritesFromDatabase();
      setState(() {
        favorites = fetchedListings;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching listings: $e');
      setState(() {
        favorites = [];
        isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(String listingId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }
      String userId = user.uid;
      final userFavoritesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites');

      DocumentSnapshot docSnapshot = await userFavoritesRef.doc(listingId).get();
      if (docSnapshot.exists) {
        await userFavoritesRef.doc(listingId).delete();
      } else {
        await userFavoritesRef.doc(listingId).set({});
      }

      setState(() {
        favorites.removeWhere((listing) => listing['documentId'] == listingId);
      });
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      selectedIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true, // Центрирует текст
          title: Text(
            'Избранное',
            style: TextStyle(color: Colors.black), // Цвет текста, если необходимо
          ),
          toolbarHeight: 40.0, // Устанавливает высоту AppBar
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

        body: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(backgroundGreen),
          ),
        )
            : favorites.isEmpty
            ? Center(
          child: Text('Нет избранных объявлений'),
        )
            : GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.79,
          ),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            var listing = favorites[index];
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
              isFavorite: true,
              onFavoriteToggle: () => _toggleFavorite(listing['documentId']),
              userID: listing['userID'],
            );
          },
        ),
      ),
    );
  }
}
