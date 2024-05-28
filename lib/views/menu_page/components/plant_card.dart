import 'package:flutter/material.dart';
import '../../../exports.dart';

class PlantCard extends StatelessWidget {
  final String name;
  final String description;
  final String imageURL;
  final String documentId;
  final int price;
  final String speciesId;
  final String typeId;
  final String height;
  final String width;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const PlantCard({
    required this.name,
    required this.description,
    required this.imageURL,
    required this.documentId,
    required this.price,
    required this.speciesId,
    required this.typeId,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlantDetailsPage(
                name: name,
                description: description,
                imageURL: imageURL,
                price: price,
                documentId: documentId,
                speciesId: speciesId,
                typeId: typeId,
                height: height,
                width: width,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(10), // скругленные углы только сверху
              ),
              child: Stack(
                children: [
                  Image.network(
                    imageURL,
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
                    height: 170,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    right: 1.0,
                    top: 1.0,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite_rounded: Icons.favorite_border_rounded,
                        color: isFavorite ? dustyRed : Colors.grey,
                      ),
                      onPressed: onFavoriteToggle,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "$price ₽",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
