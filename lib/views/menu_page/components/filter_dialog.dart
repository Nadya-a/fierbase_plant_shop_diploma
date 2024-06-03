import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../exports.dart';

class FilterDialog extends StatefulWidget {
  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String? _selectedTypeId;
  String? _selectedSpeciesId;
  int? _minPrice;
  int? _maxPrice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Фильтры'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Выберите тип растения:'),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('plants_types').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Ошибка загрузки типов'));
                }

                final types = snapshot.data?.docs ?? [];

                return DropdownButtonFormField<String>(
                  value: _selectedTypeId,
                  items: types.map((typeDoc) {
                    return DropdownMenuItem<String>(
                      value: typeDoc.id,
                      child: Text(typeDoc['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTypeId = value;
                      _selectedSpeciesId = null;
                    });
                  },
                );
              },
            ),
            SizedBox(height: 16),
            if (_selectedTypeId != null) ...[
              Text('Выберите вид растения:'),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('plants_species').where('type_id', isEqualTo: _selectedTypeId).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Ошибка загрузки видов'));
                  }

                  final species = snapshot.data?.docs ?? [];

                  return DropdownButtonFormField<String>(
                    value: _selectedSpeciesId,
                    items: species.map((speciesDoc) {
                      return DropdownMenuItem<String>(
                        value: speciesDoc.id,
                        child: Text(speciesDoc['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSpeciesId = value;
                      });
                    },
                  );
                },
              ),
            ],
            SizedBox(height: 16),
            Text('Укажите цену от и до:'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'От'),
                    onChanged: (value) {
                      setState(() {
                        _minPrice = int.tryParse(value);
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'До'),
                    onChanged: (value) {
                      setState(() {
                        _maxPrice = int.tryParse(value);
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Применить выбранные фильтры
                // Вызов метода для применения фильтров или передача значений обратно на основной экран
                Navigator.pop(context, {
                  'typeId': _selectedTypeId,
                  'speciesId': _selectedSpeciesId,
                  'minPrice': _minPrice,
                  'maxPrice': _maxPrice,
                });
              },
              child: Text('Применить фильтры'),
            ),
          ],
        ),
      ),
    );
  }
}

