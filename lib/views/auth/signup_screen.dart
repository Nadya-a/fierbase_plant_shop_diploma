import 'dart:developer';

import 'package:flutter/material.dart';

import '../../exports.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = AuthService();
  final FirebaseAuth _isauth = FirebaseAuth.instance;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          StreamBuilder<User?>(
            stream: _isauth.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasData && snapshot.data != null) {
                return IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () async {
                    await _isauth.signOut();
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
        stream: _isauth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data != null) {
            return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Кажется, вы уже авторизованы!',
                      style: TextStyle(
                        fontSize: 21, // Установка размера текста
                      ),
                    ),
                    TextButton(
                      onPressed: () => goToIntroPage(context),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(backgroundGreen),
                      ),
                      child: const Text(
                        "Вернуться на начальную страницу",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16, // Установка размера текста
                        ),
                      ),
                    ),
                  ]
              ),
            );
          } else {
            return _buildSignipDetails();
          }
        },
      ),
    );
  }


  Widget _buildSignipDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          const Spacer(),
          const Text("Регистрация",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500)),
          const SizedBox(
            height: 50,
          ),
          CustomTextField(
            hint: "Введите имя",
            label: "Имя",
            controller: _name,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            hint: "Введите почту",
            label: "Почта",
            controller: _email,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            hint: "Введите пароль",
            label: "Пароль",
            isPassword: true,
            controller: _password,
          ),
          const SizedBox(height: 30),
          TextButton(
            onPressed: _signup,
            child: Text(
              "Регистрация",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16, // Установка размера текста
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(backgroundGreen),
            ),
          ),
          const SizedBox(height: 5),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text("Уже есть аккаунт? "),
            InkWell(
              onTap: () => goToLogin(context),
              child: const Text("Войти", style: TextStyle(color: Colors.red)),
            )
          ]),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: TextButton(
              onPressed: () => goToIntroPage(context),
              child: Text(
                "К начальной странице",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16, // Установка размера текста
                ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(backgroundGreen),
              ),
            ),
          ),
        ],
      ),

    );
  }

  goToLogin(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );

  goToIntroPage(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const IntroPage()),
  );

  _signup() async {
    final user =
    await _auth.createUserWithEmailAndPassword(_email.text, _password.text);

    if (user != null) {
      await user.updateDisplayName(_name.text);

      log("Пользователь успешно зарегистрирован");
      goToIntroPage(context);
    }
  }
}