import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../exports.dart';

class ChatCard extends StatelessWidget {
  final Map<String, dynamic> chatData;

  ChatCard({required this.chatData});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chatData['otherUserName'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              height: 1.2, // Устанавливаем высоту строки для уменьшения расстояния
            ),
          ),
          Text(
            '${chatData['listingName']}, ${chatData['listingPrice']} ₽',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              height: 1.2, // Устанавливаем высоту строки для уменьшения расстояния
            ),
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${chatData['lastMessageText']}',
              style: const TextStyle(
                height: 1.2, // Устанавливаем высоту строки для уменьшения расстояния
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis, // Ограничиваем текст в одной строке
            ),
          ),
          Text(
            chatData['lastMessageTime'] != null
                ? DateFormat('HH:mm').format(chatData['lastMessageTime'])
                : '',
            style: const TextStyle(
              height: 1.2, // Устанавливаем высоту строки для уменьшения расстояния
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      leading: CircleAvatar(
        radius: 42,
        backgroundImage: NetworkImage(chatData['listingImageURL']),
      ),
      onTap: () {
        // Обработка нажатия на чат
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              chatTitle: chatData['otherUserName'],
              otherUserName: chatData['otherUserName'],
              listingName: chatData['listingName'],
              listingPrice: chatData['listingPrice'],
              listingImageURL: chatData['listingImageURL'],
              chatId: chatData['chatId'],
            ),
          ),
        );
      },
    );
  }
}
