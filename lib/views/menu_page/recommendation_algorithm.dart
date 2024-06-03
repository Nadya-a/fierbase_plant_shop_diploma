import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../../exports.dart';

// Функция для вычисления TF
Map<String, double> calculateTF(String text) {
  Map<String, double> tfMap = {};
  List<String> words = text.split(' ');
  int totalWords = words.length;
  for (String word in words) {
    tfMap[word] = (tfMap.containsKey(word)) ? tfMap[word]! + (1 / totalWords) : 1 / totalWords;
  }
  return tfMap;
}

// Функция для вычисления IDF
Map<String, double> calculateIDF(List<PlantsListing> listings) {
  Map<String, double> idfMap = {};
  int totalDocuments = listings.length;
  for (PlantsListing listing in listings) {
    Set<String> uniqueWords = Set.from(listing.features.split(' '));
    for (String word in uniqueWords) {
      idfMap[word] = (idfMap.containsKey(word)) ? idfMap[word]! + 1 : 1;
    }
  }
  idfMap.forEach((key, value) {
    idfMap[key] = log(totalDocuments / (value + 1)); // Добавляем 1, чтобы избежать деления на ноль
  });
  return idfMap;
}

// Функция для вычисления TF-IDF
Map<String, double> calculateTFIDF(PlantsListing listing, Map<String, double> idfMap) {
  Map<String, double> tfMap = calculateTF(listing.features);
  Map<String, double> tfIdfMap = {};
  tfMap.forEach((word, tf) {
    tfIdfMap[word] = tf * idfMap[word]!;
  });
  return tfIdfMap;
}

// Функция для вычисления косинусного сходства между двумя векторами
double calculateCosineSimilarity(Map<String, double> vecA, Map<String, double> vecB) {
  double dotProduct = 0.0;
  double normA = 0.0;
  double normB = 0.0;
  vecA.forEach((word, value) {
    dotProduct += value * (vecB.containsKey(word) ? vecB[word]! : 0);
    normA += value * value;
  });
  vecB.forEach((word, value) {
    normB += value * value;
  });
  return dotProduct / (sqrt(normA) * sqrt(normB));
}

// Основная функция для получения рекомендаций на основе списка listingIds
Future<List<Map<String, dynamic>>> getRecommendations(List<String> listingIds) async {
  // Получаем все объявления из Firestore
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('listings').get();
  List<PlantsListing> listings = querySnapshot.docs.map((doc) {
    var data = doc.data() as Map<String, dynamic>;
    return PlantsListing.fromJson(data);
  }).toList();

  // Фильтруем объявления по listingIds
  List<PlantsListing> targetListings = listings.where((listing) => listingIds.contains(listing.documentId)).toList();

  // Проверяем, чтобы были найдены все целевые объявления
  if (targetListings.length != listingIds.length) {
    throw Exception('Some target listings not found');
  }

  // Вычисляем IDF для всех объявлений
  Map<String, double> idfMap = calculateIDF(listings);

  // Вычисляем TF-IDF векторы для целевых объявлений и создаем суммарный вектор
  Map<String, double> averageTFIDF = {};
  for (PlantsListing listing in targetListings) {
    Map<String, double> tfidf = calculateTFIDF(listing, idfMap);
    tfidf.forEach((word, value) {
      averageTFIDF[word] = (averageTFIDF.containsKey(word)) ? averageTFIDF[word]! + value : value;
    });
  }
  averageTFIDF.updateAll((key, value) => value / targetListings.length);

  // Вычисляем TF-IDF векторы для всех объявлений
  Map<String, Map<String, double>> tfidfVectors = {};
  for (PlantsListing listing in listings) {
    tfidfVectors[listing.documentId] = calculateTFIDF(listing, idfMap);
  }

  // Вычисляем косинусное сходство между средним вектором и остальными объявлениями
  Map<String, double> similarities = {};
  for (PlantsListing listing in listings) {
    if (!listingIds.contains(listing.documentId)) {
      double similarity = calculateCosineSimilarity(averageTFIDF, tfidfVectors[listing.documentId]!);
      similarities[listing.documentId] = similarity;
    }
  }

  // Сортируем объявления по косинусному сходству
  var sortedListings = similarities.keys.toList()
    ..sort((a, b) => similarities[b]!.compareTo(similarities[a]!));

  // Возвращаем отсортированные объявления
  List<Map<String, dynamic>> recommendations = [];
  for (var docId in sortedListings) {
    var listing = listings.firstWhere((listing) => listing.documentId == docId);
    recommendations.add(listing.toJson());
  }
  return recommendations;
}
