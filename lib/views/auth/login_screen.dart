import 'dart:developer';
import 'package:flutter/material.dart';
import '../../exports.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final FirebaseAuth _isauth = FirebaseAuth.instance;
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    super.dispose();
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
                    Text('Кажется, вы уже авторизованы!',
                      style: TextStyle(
                        fontSize: 21, // Установка размера текста
                      ),
                    ),
                    TextButton(
                      onPressed: () => goToIntroPage(context),
                      child: Text(
                        "Вернуться на начальную страницу",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16, // Установка размера текста
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(backgroundGreen),
                      ),
                    ),
                  ]
              ),
            );
          } else {
            return _buildLoginDetails();
          }
        },
      ),
    );
  }



  Widget _buildLoginDetails() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const Spacer(),
            const Text("Авторизация",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500)),
            const SizedBox(height: 50),
            CustomTextField(
              hint: "Введите почту",
              label: "Почта",
              controller: _email,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Введите пароль",
              label: "Пароль",
              controller: _password,
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: _login,
              child: Text(
                "Войти",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17, // Установка размера текста
                ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(backgroundGreen),
              ),
            ),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Еще нет аккаунта? "),
              InkWell(
                onTap: () => goToSignup(context),
                child: const Text("Регистрация", style: TextStyle(color: Colors.red)),
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
      ),
    );
  }

  goToSignup(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SignupScreen()),
  );

  goToIntroPage(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const IntroPage()),
  );

  _login() async {
    final user =
    await _auth.loginUserWithEmailAndPassword(_email.text, _password.text);

    if (user != null) {
      log("Пользователь авторизован");
      goToIntroPage(context);
    }
  }
}
