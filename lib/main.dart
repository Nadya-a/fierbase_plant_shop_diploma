import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() async {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
=======

import 'exports.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
>>>>>>> 6d076c4 (Initial commit)
        apiKey: 'AIzaSyAfODsSWy_HCHtmknoDJXcfui5NGfVD2R4',
        appId: 'AIzaSyAfODsSWy_HCHtmknoDJXcfui5NGfVD2R4',
        messagingSenderId: '104998893072',
        projectId: 'fierbase-diploma',
        storageBucket: 'fierbase-diploma.appspot.com',
<<<<<<< HEAD
    )
    );
    FirebaseFirestore.instance.collection('test').doc('doc1').set({'data': 'example'});

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
=======
      )
  );
  //createListingsInDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IntroPage(),
      routes: {
        '/intropage' : (context) => const IntroPage(),
        '/menupage' : (context) => MenuPage(),
      },
    );
  }
}



//void _incrementCounter() async {
//     FirebaseFirestore.instance.collection('test').doc('doc1').set({'data': 'example'});
//
//   }

>>>>>>> 6d076c4 (Initial commit)
