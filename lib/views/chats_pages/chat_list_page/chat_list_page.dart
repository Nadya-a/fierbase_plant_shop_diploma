import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../exports.dart'; // Импортируйте ваш файл экспорта здесь

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<Map<String, dynamic>> chatList = [];

  @override
  void initState() {
    super.initState();
    fetchAndSetChats();
  }

  Future<void> fetchAndSetChats() async {
    List<Map<String, dynamic>> chats = await fetchChatsForCurrentUser();
    setState(() {
      chatList = chats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      selectedIndex: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Сообщения'),
        ),
        body: ListView.builder(
          itemCount: chatList.length,
          itemBuilder: (context, index) {
            // Получаем данные чата из списка
            Map<String, dynamic> chatData = chatList[index];

            return ChatCard(chatData: chatData);
          },
        ),
      ),
    );
  }
}