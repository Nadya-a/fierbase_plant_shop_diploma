import 'package:cloud_firestore/cloud_firestore.dart';

import '../exports.dart';

class ViewingHistory {
  final String userId;
  final String listingId;
  final DateTime viewedAt;

  ViewingHistory({
    required this.userId,
    required this.listingId,
    required this.viewedAt,
  });

  factory ViewingHistory.fromJson(Map<String, dynamic> json) {
    return ViewingHistory(
      userId: json['userId'],
      listingId: json['listingId'],
      viewedAt: (json['viewedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'listingId': listingId,
      'viewedAt': viewedAt,
    };
  }
}

// Добавление записи о просмотре объявления
Future<void> addViewingHistory(String userId, String listingId) async {
  await FirebaseFirestore.instance.collection('users').doc(userId).collection('viewing_history').add({
    'userId': userId,
    'listingId': listingId,
    'viewedAt': FieldValue.serverTimestamp(),
  });
}

// Получение истории просмотра пользователя
Future<List<ViewingHistory>> getViewingHistory(String userId) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('viewing_history')
      .where('userId', isEqualTo: userId)
      .orderBy('viewedAt', descending: true)
      .get();

  return querySnapshot.docs.map((doc) {
    var data = doc.data() as Map<String, dynamic>;
    return ViewingHistory.fromJson(data);
  }).toList();
}

Future<List<String>> fetchUserActivities(String userId) async {
  try {
    List<String> listingIds = [];

    // Получаем документ пользователя
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    // Проверяем наличие документа и полей favorites и viewing_history
    if (userDoc.exists) {
      List<dynamic> favorites = userDoc.get('favorites');
      List<dynamic> viewingHistory = userDoc.get('viewing_history');

      // Сортируем избранные по времени добавления (по убыванию)
      favorites.sort((a, b) => b['addedAt'].compareTo(a['addedAt']));
      // Сортируем историю просмотров по времени просмотра (по убыванию)
      viewingHistory.sort((a, b) => b['viewedAt'].compareTo(a['viewedAt']));

      // Выбираем последние три добавленные в избранное и последние три просмотренные записи
      for (int i = 0; i < 3; i++) {
        if (i < favorites.length) {
          listingIds.add(favorites[i]['listingId']);
        }
        if (i < viewingHistory.length) {
          listingIds.add(viewingHistory[i]['listingId']);
        }
      }
    }

    return listingIds;
  } catch (e) {
    print('Error fetching user activities: $e');
    return []; // Возвращаем пустой список в случае ошибки
  }
}
