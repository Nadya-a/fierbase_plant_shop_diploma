import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../exports.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  String? _displayName;
  String? _email;
  File? _avatarImage;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return BasePage(
      selectedIndex: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Профиль пользователя'),
          actions: [
            StreamBuilder<User?>(
              stream: _auth.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasData && snapshot.data != null) {
                  return IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () async {
                      await _auth.signOut();
                    },
                  );
                } else {
                  return IconButton(
                    icon: Icon(Icons.login),
                    onPressed: () async {
                      // Код для перехода на экран авторизации
                      Navigator.pushNamed(context, '/login');
                    },
                  );
                }
              },
            ),
          ],
        ),
        body: StreamBuilder<User?>(
          stream: _auth.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData && snapshot.data != null) {
              User user = snapshot.data!;
              return _buildUserDetails(user);
            } else {
              return Center(
                child: Text('Войдите в аккаунт для доступа к данным пользователя'),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildUserDetails(User user) {
    _displayName = user.displayName;
    _email = user.email;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Поле для загрузки аватарки
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _avatarImage = File(pickedFile.path);
                  });
                }
              },
              child: _avatarImage != null
                  ? CircleAvatar(
                radius: 50,
                backgroundImage: FileImage(_avatarImage!),
              )
                  : user.photoURL != null
                  ? CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user.photoURL!),
              )
                  : CircleAvatar(
                radius: 50,
                child: Icon(Icons.add_a_photo),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              initialValue: _displayName,
              decoration: InputDecoration(
                labelText: 'Имя пользователя',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              ),
              onSaved: (value) {
                _displayName = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите имя пользователя';
                }
                return null;
              },
            ),
            SizedBox(height: 8),
            TextFormField(
              initialValue: _email,
              decoration: InputDecoration(
                labelText: 'Почта',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              ),
              onSaved: (value) {
                _email = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Укажите почту';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Пожалуйста, введите верную почту';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            _isSaving
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _saveChanges,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(backgroundGreen),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              child: Text(
                'Сохранить',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSaving = true;
      });

      User? user = _auth.currentUser;

      if (user != null) {
        try {
          // Сохранение аватарки в Firebase Storage
          if (_avatarImage != null) {
            final storageRef = FirebaseStorage.instance.ref().child('avatars/${user.uid}.jpg');

            await storageRef.putFile(_avatarImage!);
            final avatarUrl = await storageRef.getDownloadURL();
            await user.updatePhotoURL(avatarUrl);
          }

          await user.updateDisplayName(_displayName);
          await user.updateEmail(_email!);
          await user.reload();
          user = _auth.currentUser;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Профиль успешно обновлен')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Не удалось обновить профиль: $e')),
          );
        } finally {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }
}
