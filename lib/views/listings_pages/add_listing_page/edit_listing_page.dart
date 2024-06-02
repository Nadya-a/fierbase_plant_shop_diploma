import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../exports.dart';

import 'package:image_picker/image_picker.dart';

class EditListingPage extends StatefulWidget {
  final String name;
  final String description;
  final String imageURL;
  final String documentId;
  final num price;
  final String speciesId;
  final String typeId;
  final String height;
  final String width;

  EditListingPage({required this.name, required this.description, required this.imageURL, required this.documentId, required this.price, required this.speciesId, required this.typeId, required this.height, required this.width});

  @override
  _EditListingPageState createState() => _EditListingPageState();
}

class _EditListingPageState extends State<EditListingPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  File? _imageFile; // переменная для хранения выбранного изображения

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _selectedTypeId;
  String? _selectedSpeciesId;
  double _height = 0; // default height value
  double _width = 0; // default width value
  List<DocumentSnapshot> _types = [];
  List<DocumentSnapshot> _allSpecies = [];
  List<DocumentSnapshot> _filteredSpecies = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      nameController.text = widget.name;
      descriptionController.text = widget.description;
      priceController.text = widget.price.toString();
      _selectedSpeciesId = widget.speciesId;
      _selectedTypeId = widget.typeId;
      _height = double.parse(widget.height);
      _width = double.parse(widget.width);

    });
    _fetchTypesAndSpecies();
  }

  Future<void> _fetchTypesAndSpecies() async {
    try {
      // Загрузка типов растений
      QuerySnapshot typeSnapshot = await FirebaseFirestore.instance.collection('plants_types').get();
      // Загрузка всех видов растений
      QuerySnapshot speciesSnapshot = await FirebaseFirestore.instance.collection('plants_species').get();

      setState(() {
        _types = typeSnapshot.docs;
        _allSpecies = speciesSnapshot.docs;
        _filterSpeciesByType(_selectedTypeId);
      });
    } catch (e) {
      print('Error fetching types and species: $e');
    }
  }

  void _filterSpeciesByType(String? typeId) {
    if (typeId == null) return;
    setState(() {
      _filteredSpecies = _allSpecies.where((species) => species['type_id'] == typeId).toList();
      if (_filteredSpecies.isNotEmpty && !_filteredSpecies.any((species) => species.id == _selectedSpeciesId)) {
        _selectedSpeciesId = _filteredSpecies.first.id;
      } else if (_filteredSpecies.isEmpty) {
        _selectedSpeciesId = null;
      }
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context, String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Вы уверены, что хотите удалить это объявление?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрыть диалог
              },
              child: Text(
                'Назад',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                deleteListingFromDatabase(documentId).then((_) {
                  Navigator.of(context).pop(); // Закрыть диалог
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Объявление удалено')),
                  );
                  Navigator.pushNamed(context, '/listingspage');
                }).catchError((error) {
                  Navigator.of(context).pop(); // Закрыть диалог
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка при удалении объявления: $error')),
                  );
                });
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white),
                backgroundColor: MaterialStateProperty.all(Colors.red),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Colors.red),
                  ),
                ),
              ),
              child: Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Редактировать объявление'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedTypeId,
                items: _types.map((type) {
                  return DropdownMenuItem<String>(
                    value: type.id,
                    child: Text(type['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTypeId = value;
                    _filterSpeciesByType(value);
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Тип',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 8), // Добавляем небольшой вертикальный отступ между элементами
              DropdownButtonFormField<String>(
                value: _selectedSpeciesId,
                items: _filteredSpecies.map((species) {
                  return DropdownMenuItem<String>(
                    value: species.id,
                    child: Text(species['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSpeciesId = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Вид',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Поля для ввода данных объявления
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Название',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Цена',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text('Высота (height): ${_height} см'),
              Slider(
                value: _height,
                min: 0,
                max: 200,
                divisions: 40,
                label: _height.round().toString(),
                activeColor: backgroundGreen,
                onChanged: (value) {
                  setState(() {
                    _height = value;
                  });
                },
              ),
              SizedBox(height: 16),
              Text('Ширина (width): ${_width} см'),
              Slider(
                value: _width,
                min: 0,
                max: 200,
                divisions: 40,
                label: _width.round().toString(),
                activeColor: backgroundGreen,
                onChanged: (value) {
                  setState(() {
                    _width = value;
                  });
                },
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  // Вызываем метод для выбора изображения
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 360,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imageFile != null
                      ? Image.file(
                    _imageFile!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : widget.imageURL.isNotEmpty
                      ? Image.network(
                    widget.imageURL,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                ),
              ),
              SizedBox(height: 16),
              // Кнопки для сохранения и удаления изменений
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      updateListingInDatabase(
                        widget.documentId,
                        nameController.text,
                        descriptionController.text,
                        _imageFile,
                        priceController.text,
                        _selectedSpeciesId ?? '',
                        _selectedTypeId ?? '',
                        _height.toInt().toString(),
                        _width.toInt().toString(),
                      ).then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Объявление изменено')),
                        );
                        Navigator.pushNamed(context, '/listingspage');
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ошибка при изменении объявления: $error')),
                        );
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(backgroundGreen),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    child: Text('Сохранить', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showDeleteConfirmationDialog(context, widget.documentId);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    child: Text('Удалить', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
