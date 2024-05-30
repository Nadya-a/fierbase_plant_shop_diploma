import 'package:flutter/material.dart';
import '../../../../exports.dart';

Widget buildListingCard(Map<String, dynamic> listing, BuildContext context) {
  return Card(
    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    child: Stack(
      children: [
        // Виджет с изображением и текстом
        GestureDetector(
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
                  speciesId: listing['species_id'],
                  typeId: listing['type_id'],
                  height: listing['height'],
                  width: listing['width'],
                ),
              ),
            );
          },
          child: Row(
            children: [
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing['name'] ?? '',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        listing['description'] ?? '',
                        style: TextStyle(fontSize: 16.0),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        "${listing['price'] ?? ''} ₽",
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
        // Иконка редактирования в правом верхнем углу
        Positioned(
          top: 1.0,
          right: 1.0,
          child: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditListingPage(
                    name: listing['name'],
                    description: listing['description'],
                    imageURL: listing['imageURL'],
                    documentId: listing['documentId'],
                    price: listing['price'],
                    speciesId: listing['species_id'],
                    typeId: listing['type_id'],
                    height: listing['height'],
                    width: listing['width'], // Передаем идентификатор объявления
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
