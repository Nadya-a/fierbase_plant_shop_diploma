import 'package:flutter/material.dart';
import '../../../../exports.dart';

Widget buildListingCard(Map<String, dynamic> listing, BuildContext context) {
  return Card(
    //color: backgroundGreyGreen,
    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDetailsPage(
              name: listing['name'],
              description: listing['description'],
              imageURL: listing['imageURL'],
              documentId: listing['documentId'],
              price: listing['price'],
              speciesId: listing['species_id'], // передаем, но не отображаем
              typeId: listing['type_id'],
              height: listing['height'],
              width: listing['width'], // передаем, но не отображаем
            ),
          ),
        );
      },
      child: Row(
        children: [
          // Виджет с изображением слева
          Container(
            width: 130.0,
            height: 130.0,
            child: Image.network(
              listing['imageURL'],
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                }
              },
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                return Center(
                  child: Text('Ошибка загрузки изображения'),
                );
              },
              width: double.infinity,
              height: 110,
              fit: BoxFit.cover,
            ),
          ),
          // Виджет с текстом справа
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing['name'] ?? '', // Предполагается, что в данных объявления есть поле name для названия
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    listing['description'] ?? '', // Предполагается, что в данных объявления есть поле description для описания
                    style: TextStyle(fontSize: 16.0),
                    maxLines: 2, // Устанавливаем максимальное количество строк
                    overflow: TextOverflow.ellipsis, // Устанавливаем обрезку с троеточием
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    "${listing['price'] ?? ''} ₽", // Предполагается, что в данных объявления есть поле price для цены
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
