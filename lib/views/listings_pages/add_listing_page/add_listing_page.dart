import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../exports.dart';

import 'package:image_picker/image_picker.dart';

class AddListingPage extends StatefulWidget {
  final String speciesId;
  final String typeId;

  AddListingPage({required this.speciesId, required this.typeId});

  @override
  _AddListingPageState createState() => _AddListingPageState();
}

class _AddListingPageState extends State<AddListingPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  File? _imageFile; // переменная для хранения выбранного изображения
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _selectedTypeId;
  String? _selectedSpeciesId;
  double _height = 100; // default height value
  double _width = 100; // default width value
  List<DocumentSnapshot> _types = [];
  List<DocumentSnapshot> _allSpecies = [];
  List<DocumentSnapshot> _filteredSpecies = [];

  @override
  void initState() {
    super.initState();
    _selectedTypeId = widget.typeId;
    _selectedSpeciesId = widget.speciesId;
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

  @override
  Widget build(BuildContext context) {
    return BasePage(
      selectedIndex: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Добавить объявление'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Название',
                    hintText: 'Введите название', // Текст по умолчанию
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),// Указываем вертикальный отступ
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: null, // Разрешить неограниченное количество строк
                  textAlignVertical: TextAlignVertical.top, // Отображение текста сверху вниз
                  decoration: InputDecoration(
                    labelText: 'Описание',
                    hintText: 'Введите описание', // Текст по умолчанию
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
                Text('Высота (height): ${_height.toInt()} см'),
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
                Text('Ширина (width): ${_width.toInt()} см'),
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
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _imageFile != null
                        ? Image.file(_imageFile!, width: double.infinity, height: double.infinity, fit: BoxFit.cover)
                        : Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final user = _auth.currentUser;
                    if (user != null) {
                      createListingsInDatabase(
                        nameController.text,
                        descriptionController.text,
                        _imageFile!,
                        int.tryParse(priceController.text) ?? 0,
                        user.uid, // передаем идентификатор пользователя
                        _selectedSpeciesId ?? '',
                        _selectedTypeId ?? '',
                        _height.toInt().toString(),
                        _width.toInt().toString(),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Объявление добавлено')),
                      );
                      Navigator.pushNamed(context, '/listingspage');
                    } else {
                      // Если пользователь не авторизован, вы можете обработать это здесь
                    }
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
