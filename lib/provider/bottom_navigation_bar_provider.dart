import 'package:flutter/material.dart';

class BottomNavigationBarProvider with ChangeNotifier {
  int selectedIndex = 0;
  int get currentIndex => selectedIndex;
  set currentIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}