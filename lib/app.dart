import 'package:flutter/material.dart';
import 'package:perantal/screens/auth/auth.dart';
import 'package:perantal/screens/home/homepage.dart';

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
      
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:  HomePage(),
        debugShowCheckedModeBanner: false, // Ajoutez cette ligne

    );
  }
}