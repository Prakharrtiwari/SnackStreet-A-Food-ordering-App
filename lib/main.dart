import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:streetorder/pages/cartPage.dart';
import 'package:streetorder/pages/homepage.dart';

import 'package:streetorder/pages/loginpage.dart';
import 'package:streetorder/pages/profilePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp()); // Ensure no 'const' here
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key); // Ensure no 'const' here

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Multi-Login App',
      theme: ThemeData(primarySwatch: Colors.yellow),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        // '/customerHome': (context) => HomePage(),
        '/userHome': (context) => HomePage(),// Ensure LoginScreen is not const
        '/cart': (context) => CartPage(),
        // '/chat': (context) => ChatPage(),
        '/profile': (context) => ProfilePage(),

      },
    );
  }
}
