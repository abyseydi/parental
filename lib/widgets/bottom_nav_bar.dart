import 'package:flutter/material.dart';
import 'package:perantal/screens/home/homepage.dart';
import 'package:perantal/screens/settings/notification.dart';
import 'package:perantal/screens/settings/profile.dart';
import 'package:perantal/utils/colors.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [HomePage(), Profile()];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      backgroundColor: AppColors.k_background,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.k_background,
        selectedItemColor: AppColors.k_primary,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
