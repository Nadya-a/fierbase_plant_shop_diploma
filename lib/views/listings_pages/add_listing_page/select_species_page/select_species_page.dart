import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../exports.dart';

class SelectSpeciesPage extends StatelessWidget {
  final String typeId;

  SelectSpeciesPage({required this.typeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Выберите вид'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('plants_species').where('type_id', isEqualTo: typeId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки видов'));
          }

          final species = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: species.length,
            itemBuilder: (context, index) {
              final speciesDoc = species[index];
              return ListTile(
                title: Text(speciesDoc['name'],
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddListingPage(
                        speciesId: speciesDoc.id,
                        typeId: typeId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
