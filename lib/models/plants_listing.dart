import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../exports.dart';

class PlantsListing {
  final String name;
  final String description;
  final int price;
  final String imageURL;

  PlantsListing({
    required this.name,
    required this.description,
    required this.price,
    required this.imageURL,
  });

  factory PlantsListing.fromJson(Map<String, dynamic> json) {
    return PlantsListing(
      name: json['name'],
      description: json['description'],
      price: json['price'],
      imageURL: json['imageURL'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageURL': imageURL,
    };
  }
}

Future<List<Map<String, dynamic>>> getListings() async {
  List<Map<String, dynamic>> listings = [];

  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('listings')
        .get(); // Получение данных из коллекции "listings"

    querySnapshot.docs.forEach((doc) {
      // Проход по всем документам в полученной коллекции
      Map<String, dynamic> listingData = doc.data() as Map<String, dynamic>;
      listings.add(listingData); // Добавление данных объявления в список
    });

    return listings;
  } catch (e) {
    print('Error fetching listings: $e');
    return []; // В случае ошибки возвращаем пустой список
  }
}

/*void main() {
  List<PlantsListing> listings = [];

  for (int i = 1; i <= 16; i++) {
    listings.add(
      PlantsListing(
        name: 'Название товара $i',
        description: 'Описание товара $i',
        price: 100,
        imageURL: 'assets/images/ficus.png',
      ),
    );
  }

  List<Map<String, dynamic>> jsonListings = listings.map((listing) => listing.toJson()).toList();

  String jsonString = jsonEncode(jsonListings);
  //print(jsonString);
} */

/*List<Map<String, dynamic>> getListings() {
  List<PlantsListing> listings = [];

  for (int i = 1; i <= 16; i++) {
    listings.add(
      PlantsListing(
        name: 'Название товара $i',
        description: 'Описание товара $i',
        price: 100,
        imageURL: 'assets/images/ficus.png',
      ),
    );
  }

  List<Map<String, dynamic>> jsonListings = listings.map((listing) => listing.toJson()).toList();
  return jsonListings;
} */

void createListingsInDatabase() {
  final storage = FirebaseStorage.instance;
  FirebaseFirestore.instance.collection('listings').doc('listing6').set({
    'name': 'Test',
    'description': 'Test',
    'price': 80,
    'imageURL': 'assets/images/zambaria.jpg',
  });

}

