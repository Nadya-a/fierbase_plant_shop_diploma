import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../exports.dart';

class ChatPage extends StatelessWidget {
  final String chatId;
  final String chatTitle;
  final String otherUserName;
  final String listingName;
  final int listingPrice;
  final String listingImageURL;

  const ChatPage({
    Key? key,
    required this.chatTitle,
    required this.otherUserName,
    required this.listingName,
    required this.listingPrice,
    required this.listingImageURL,
    required this.chatId,
  }) : super(key: key);

  Future<void> sendMessage(String messageText) async {
    try {
      // Ссылка на коллекцию "messages" внутри документа чата
      CollectionReference messagesCollection = FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages');

      // Добавление нового сообщения
      await messagesCollection.add({
        'senderId': FirebaseAuth.instance.currentUser!.uid,
        'messageText': messageText,
        'timestamp': Timestamp.now(),
        'chatId': chatId,
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(listingImageURL),
              radius: 28,
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherUserName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                Text(
                  '$listingName, $listingPrice ₽',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Ошибка: ${snapshot.error}');
                }
                // Данные получены успешно
                List<DocumentSnapshot> messages = snapshot.data!.docs;

                Map<String, List<DocumentSnapshot>> groupedMessages = {};

                // Группировка сообщений по дате
                for (var message in messages) {
                  DateTime messageTime = (message.data() as Map<String, dynamic>)['timestamp'].toDate();
                  String dateKey = DateFormat('yyyy-MM-dd').format(messageTime);
                  if (!groupedMessages.containsKey(dateKey)) {
                    groupedMessages[dateKey] = [];
                  }
                  groupedMessages[dateKey]!.add(message);
                }

                return ListView.builder(
                  reverse: true, // Для отображения сообщений снизу вверх
                  itemCount: groupedMessages.length,
                  itemBuilder: (context, index) {
                    var groupKey = groupedMessages.keys.elementAt(index);
                    var messagesInGroup = groupedMessages[groupKey]!;
                    var firstMessageTime = (messagesInGroup.first.data() as Map<String, dynamic>)['timestamp'].toDate();
                    var lastMessageTime = (messagesInGroup.last.data() as Map<String, dynamic>)['timestamp'].toDate();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              _getGroupHeader(firstMessageTime),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        for (var message in messagesInGroup.reversed) ...[
                          Align(
                            alignment: (message.data() as Map<String, dynamic>)['senderId'] == FirebaseAuth.instance.currentUser!.uid ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (message.data() as Map<String, dynamic>)['senderId'] == FirebaseAuth.instance.currentUser!.uid ? messageGreen : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (message.data() as Map<String, dynamic>)['messageText'],
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    DateFormat.Hm().format((message.data() as Map<String, dynamic>)['timestamp'].toDate()),
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController, // Привязываем контроллер
                    decoration: InputDecoration(

                      hintText: 'Введите сообщение',
                      border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24), // Скругленные края
                    ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    String messageText = _messageController.text; // Получаем текст из контроллера
                    sendMessage(messageText); // Отправляем сообщение с текстом
                    _messageController.clear(); // Очищаем контроллер после отправки сообщения
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(50, 50), // Устанавливаем размер кнопки
                    maximumSize: Size(50, 50), // Устанавливаем размер кнопки
                    backgroundColor: backgroundGreen,
                  ),
                  child: Transform.rotate(
                    angle: -3.14 / 2, // Поворачиваем иконку на 90 градусов влево
                    child: Icon(Icons.arrow_forward, color: Colors.white,),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGroupHeader(DateTime groupDate) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);

    if (groupDate.year == today.year && groupDate.month == today.month && groupDate.day == today.day) {
      return 'Сегодня';
    } else if (groupDate.year == yesterday.year && groupDate.month == yesterday.month && groupDate.day == yesterday.day) {
      return 'Вчера';
    } else {
      return DateFormat('dd MMMM').format(groupDate);
    }
  }

}
