import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../exports.dart';

class PlantsListing {
  final String name;
  final String description;
  final int price;
  final String imageURL;
  final String documentId;
  final String speciesId;
  final String typeId;
  final String height;
  final String width;

  PlantsListing({
    required this.name,
    required this.description,
    required this.price,
    required this.imageURL,
    required this.documentId,
    required this.speciesId,
    required this.typeId,
    required this.height,
    required this.width,
  });

  factory PlantsListing.fromJson(Map<String, dynamic> json) {
    return PlantsListing(
      name: json['name'],
      description: json['description'],
      price: json['price'],
      imageURL: json['imageURL'],
      documentId: json['documentId'],
      speciesId: json['species_id'],
      typeId: json['type_id'],
      width: json['width'],
      height: json['height'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageURL': imageURL,
      'documentId': documentId,
      'species_id': speciesId, // Новое поле
      'type_id': typeId, // Новое поле
    };
  }
}

Future<List<Map<String, dynamic>>> getListings() async {
  List<Map<String, dynamic>> listings = [];

  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('listings')
        .get(); // Получение данных из коллекции "listings"

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> listingData = doc.data() as Map<String, dynamic>;
      listingData['documentId'] = doc.id; // Добавление идентификатора документа в данные объявления
      listings.add(listingData);
    }

    return listings;
  } catch (e) {
    print('Error fetching listings: $e');
    return []; // В случае ошибки возвращаем пустой список
  }
}



Future<List<Map<String, dynamic>>> getUsersListings(String userId) async {
  List<Map<String, dynamic>> listings = [];

  try {
    // Запрашиваем объявления, где в поле 'userId' указан переданный айди пользователя
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('listings')
        .where("userID", isEqualTo: userId)
        .get();

    // Проходим по всем документам в полученной выборке
    querySnapshot.docs.forEach((doc) {
      // Получаем данные объявления
      Map<String, dynamic> listingData = doc.data() as Map<String, dynamic>;
      listings.add(listingData); // Добавляем данные объявления в список
    });

    return listings;
  }


  catch (e) {
    print('Error fetching user listings: $e');
    return []; // В случае ошибки возвращаем пустой список
  }
}


void createListingsInDatabase(String name, String desc, File imageFile, int price, String userID, String speciesId, String typeId,  String height, String width) async {
  // Проверяем, выбрано ли изображение
  if (imageFile == null) {
    print('Ошибка: изображение не выбрано.');
    return;
  }

  // Загружаем изображение в Firebase Storage
  try {
    // Создаем ссылку на местоположение в Firebase Storage, куда хотим загрузить изображение
    Reference storageRef = FirebaseStorage.instance.ref().child('listings_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

    // Загружаем изображение
    await storageRef.putFile(imageFile);

    // Получаем URL загруженного изображения
    String imageURL = await storageRef.getDownloadURL();

    // Создаем новый документ в коллекции "listings" и получаем его ID
    DocumentReference newListingRef = FirebaseFirestore.instance.collection('listings').doc();

    // Сохраняем данные в базе данных Firestore
    await newListingRef.set({
      'name': name,
      'description': desc,
      'price': price,
      'imageURL': imageURL,
      'userID': userID,
      'documentId': newListingRef.id, // Добавляем documentId как отдельное поле
      'species_id': speciesId, // Добавляем новое поле
      'type_id': typeId, // Добавляем новое поле
      'height': height, // Добавляем новое поле
      'width': width, // Добавляем новое поле
    });

    print('Объявление успешно добавлено в базу данных.');
  } catch (e) {
    print('Ошибка при добавлении объявления в базу данных: $e');
  }
}


Future<void> createFavoritesInDatabase(String listingId) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    String userId = user.uid;
    DocumentReference userFavoritesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(listingId);

    DocumentSnapshot docSnapshot = await userFavoritesRef.get();

    if (docSnapshot.exists) {
      await userFavoritesRef.delete();
    } else {
      await userFavoritesRef.set({'listingId': listingId});
    }
  } catch (e) {
    print('Error toggling favorite in database: $e');
  }
}



Future<List<Map<String, dynamic>>> fetchFavoritesFromDatabase() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];

  String userId = user.uid;
  final userFavoritesRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('favorites');

  QuerySnapshot querySnapshot = await userFavoritesRef.get();
  List<String> favoriteIds = querySnapshot.docs.map((doc) => doc.id).toList();

  List<Map<String, dynamic>> favorites = [];
  for (String id in favoriteIds) {
    DocumentSnapshot listingSnapshot = await FirebaseFirestore.instance
        .collection('listings')
        .doc(id)
        .get();

    if (listingSnapshot.exists) {
      Map<String, dynamic>? listingData = listingSnapshot.data() as Map<String, dynamic>?;
      if (listingData != null) {
        listingData['documentId'] = listingSnapshot.id;
        favorites.add(listingData);
      }
    }
  }

  return favorites;
}

Future<void> toggleFavorite(String listingId) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception('User not authenticated');
  }

  String userId = user.uid;
  DocumentReference userFavoritesRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('favorites')
      .doc(listingId);

  DocumentSnapshot docSnapshot = await userFavoritesRef.get();

  if (docSnapshot.exists) {
    await userFavoritesRef.delete();
  } else {
    await userFavoritesRef.set({'listingId': listingId});
  }
}
