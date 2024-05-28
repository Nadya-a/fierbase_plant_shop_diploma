import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../exports.dart';

class SelectTypePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Выберите тип'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('plants_types').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки типов'));
          }

          final types = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: types.length,
            itemBuilder: (context, index) {
              final typeDoc = types[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: ListTile(
                  leading: typeDoc['imageURL'] != null
                      ? Image.network(
                    typeDoc['imageURL'],
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                  )
                      : Icon(Icons.image, size: 70),
                  title: Text(
                    typeDoc['name'],
                    style: TextStyle(
                      fontSize: 22,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectSpeciesPage(
                          typeId: typeDoc.id,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
