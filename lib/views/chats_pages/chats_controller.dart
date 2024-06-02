import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../exports.dart';

class Chat {
  final String user1Id;
  final String user2Id;
  final int listingId;
  final String chatId;
  // final String otherUserName;
  // final String listingName;
  // final String listingPrice;
  // final String listingImageURL;

  Chat({
    required this.user1Id,
    required this.user2Id,
    required this.listingId,
    required this.chatId,
    // required this.otherUserName,
    // required this.listingName,
    // required this.listingPrice,
    // required this.listingImageURL,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      user1Id: json['user1Id'],
      user2Id: json['user2Id'],
      listingId: json['listingId'],
      chatId: json['chatId'],
      // otherUserName: json['otherUserName'],
      // listingName: json['listingName'],
      // listingPrice: json['listingPrice'],
      // listingImageURL: json['listingImageURL'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user1Id': user1Id,
      'user2Id': user2Id,
      'listingId': listingId,
      'chatId': chatId,
    };
  }
}

Future<Map<String, dynamic>> createChat(String user1Id, String user2Id, String listingId) async {
  // Проверка на одинаковые user1Id и user2Id
  if (user1Id == user2Id) {
    return {
      'errorMessage': 'Вы не сможете связаться с продавцом, потому что продавец - это вы :)',
      'chatId': 'none'
    };
  }

  // Ссылка на коллекцию "chats"
  CollectionReference chatsCollection = FirebaseFirestore.instance.collection('chats');

  // Проверка существования чата
  QuerySnapshot existingChats = await chatsCollection
      .where('user1Id', isEqualTo: user1Id)
      .where('user2Id', isEqualTo: user2Id)
      .where('listingId', isEqualTo: listingId)
      .get();

  if (existingChats.docs.isNotEmpty) {
    return {
      'errorMessage': 'Добро пожаловать в чат с продавцом!',
      'chatId': existingChats.docs.first.id
    };
  }

  // Ссылка на новый документ в коллекции "chats"
  DocumentReference chatDoc = chatsCollection.doc();

  // Добавляем документ в коллекцию "chats"
  await chatDoc.set({
    'user1Id': user1Id,
    'user2Id': user2Id,
    'listingId': listingId,
    'chatId': chatDoc.id,
  });

  return {
    'errorMessage': 'Добро пожаловать в чат с продавцом!',
    'chatId': chatDoc.id
  };
}





Future<List<Map<String, dynamic>>> fetchChatsForCurrentUser() async {
  try {
    // Получаем текущего пользователя из Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Получаем идентификатор текущего пользователя
      String userId = user.uid;

      // Ссылка на коллекцию "chats"
      CollectionReference chatsCollection = FirebaseFirestore.instance.collection('chats');

      // Запрос на получение чатов, где указанный пользователь участвует
      QuerySnapshot querySnapshot1 = await chatsCollection.where('user1Id', isEqualTo: userId).get();
      List<Map<String, dynamic>> user1Chats = querySnapshot1.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      // Запрос на получение чатов, где указанный пользователь участвует
      QuerySnapshot querySnapshot2 = await chatsCollection.where('user2Id', isEqualTo: userId).get();
      List<Map<String, dynamic>> user2Chats = querySnapshot2.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      // Объединяем результаты обоих запросов в один список
      List<Map<String, dynamic>> allChats = [];
      allChats.addAll(user1Chats);
      allChats.addAll(user2Chats);

      // Дополнительно загружаем данные пользователей и объявлений
      List<Map<String, dynamic>> extendedChats = [];
      for (var chat in allChats) {
        String otherUserId = chat['user1Id'] == userId ? chat['user2Id'] : chat['user1Id'];
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(otherUserId).get();
        DocumentSnapshot listingDoc = await FirebaseFirestore.instance.collection('listings').doc(chat['listingId']).get();

        // Получаем последнее сообщение
        QuerySnapshot lastMessageSnapshot = await chatsCollection
            .doc(chat['chatId'])
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        String lastMessageText = '';
        DateTime? lastMessageTime;

        if (lastMessageSnapshot.docs.isNotEmpty) {
          var lastMessageData = lastMessageSnapshot.docs.first.data() as Map<String, dynamic>;
          lastMessageText = lastMessageData['messageText'];
          lastMessageTime = (lastMessageData['timestamp'] as Timestamp).toDate();
        }

        Map<String, dynamic> extendedChat = {
          'chatId': chat['chatId'],
          'user1Id': chat['user1Id'],
          'user2Id': chat['user2Id'],
          'listingId': chat['listingId'],
          'otherUserName': userDoc['displayName'],
          'listingName': listingDoc['name'],
          'listingPrice': listingDoc['price'],
          'listingImageURL': listingDoc['imageURL'],
          'lastMessageText': lastMessageText,
          'lastMessageTime': lastMessageTime,
        };

        extendedChats.add(extendedChat);
      }

      return extendedChats;
    } else {
      return [];
    }
  } catch (e) {
    print('Ошибка при получении чатов: $e');
    return [];
  }
}

