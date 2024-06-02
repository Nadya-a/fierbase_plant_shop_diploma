import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'exports.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAfODsSWy_HCHtmknoDJXcfui5NGfVD2R4',
        appId: 'AIzaSyAfODsSWy_HCHtmknoDJXcfui5NGfVD2R4',
        messagingSenderId: '104998893072',
        projectId: 'fierbase-diploma',
        storageBucket: 'fierbase-diploma.appspot.com',
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
      home: LoginScreen(),
      routes: {
        '/intropage' : (context) => IntroPage(),
        '/login' : (context) => LoginScreen(),
        '/userprofile' : (context) => UserProfile(),
        '/menupage' : (context) => MenuPage(),
        '/listingspage' : (context) => ListingsPage(),
        //'/addlistingpage' : (context) => AddListingPage(),
        '/favorites' : (context) => FavoritesPage(),
        '/chats' : (context) => ChatListPage(),
      },
    );
  }
}

