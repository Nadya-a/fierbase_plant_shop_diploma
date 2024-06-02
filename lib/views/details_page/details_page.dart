import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../exports.dart';

class PlantDetailsPage extends StatefulWidget {
  final String name;
  final String description;
  final String imageURL;
  final int price;
  final String documentId;
  final String speciesId;
  final String typeId;
  final String height;
  final String width;
  final String userID;

  const PlantDetailsPage({
    required this.name,
    required this.description,
    required this.imageURL,
    required this.price,
    required this.speciesId,
    required this.typeId,
    required this.documentId,
    required this.height,
    required this.width,
    required this.userID,
  });

  @override
  _PlantDetailsPageState createState() => _PlantDetailsPageState();
}

class _PlantDetailsPageState extends State<PlantDetailsPage> {
  bool isFavorite = false;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    try {
      String? userId = user?.uid;
      DocumentSnapshot favoriteDoc = await FirebaseFirestore.instance.collection('users').doc(userId).collection('favorites').doc(widget.documentId).get();
      setState(() {
        isFavorite = favoriteDoc.exists;
      });
    } catch (e) {
      print('Error checking favorite: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      await toggleFavorite(widget.documentId);
      _checkIfFavorite();
      setState(() {

      });
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  Future<String> _fetchSpeciesName() async {
    DocumentSnapshot speciesDoc = await FirebaseFirestore.instance.collection('plants_species').doc(widget.speciesId).get();
    return speciesDoc['name'] ?? 'Unknown Species';
  }

  Future<String> _fetchTypeName() async {
    DocumentSnapshot typeDoc = await FirebaseFirestore.instance.collection('plants_types').doc(widget.typeId).get();
    return typeDoc['name'] ?? 'Unknown Type';
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      selectedIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
          actions: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? dustyRed : Colors.grey, size: 28.0,
              ),
              onPressed: _toggleFavorite,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: 400,
                child: Image.network(
                  widget.imageURL,
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
                    return const Center(
                      child: Text('Ошибка загрузки изображения'),
                    );
                  },
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      "${widget.price} ₽",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 8),
                    // Кнопка "Связаться с продавцом"
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: () async {
                          Map<String, dynamic> result = await createChat(user!.uid, widget.userID, widget.documentId);
                          if (result['errorMessage'] != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result['errorMessage'])),
                            );
                          }
                          if (result['chatId'] != 'none' && result['chatId'] != null){
                            DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userID).get();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  chatTitle: userDoc['displayName'],
                                  otherUserName: userDoc['displayName'],
                                  listingName: widget.name,
                                  listingPrice: widget.price,
                                  listingImageURL: widget.imageURL,
                                  chatId: result['chatId'],
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          onPrimary: Colors.white,
                        ),
                        child: Text('Задать вопрос продавцу',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'Характеристики',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<String>(
                      future: _fetchSpeciesName(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Вид: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Загрузка...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: darkGreyColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Вид: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Ошибка загрузки',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: darkGreyColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Вид: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: '${snapshot.data}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: darkGreyColor,
                                  ),
                                ),
                              ],
                            ),
                          );

                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<String>(
                      future: _fetchTypeName(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Тип: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Загрузка...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: darkGreyColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return const Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Тип: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Ошибка загрузки',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Тип: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: '${snapshot.data}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: darkGreyColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Размер: ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: "D${widget.width} H${widget.height}",
                          style: TextStyle(
                            fontSize: 16,
                            color: darkGreyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                    const SizedBox(height: 16),
                    const Text(
                      'Описание',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: darkGreyColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
