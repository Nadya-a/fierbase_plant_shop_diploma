import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  TextEditingController heightController = TextEditingController();
  TextEditingController widthController = TextEditingController();
  File? _imageFile; // переменная для хранения выбранного изображения
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
                TextFormField(
                  controller: heightController,
                  decoration: InputDecoration(
                    labelText: 'Высота (height)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: widthController,
                  decoration: InputDecoration(
                    labelText: 'Ширина (width)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
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
                        widget.speciesId,
                        widget.typeId,
                        heightController.text,
                        widthController.text,
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
