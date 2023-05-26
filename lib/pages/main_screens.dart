import 'package:flutter/material.dart';

import '../app_logic/auth.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'account_page.dart';
import 'friends_page.dart';

class MainScreens extends StatefulWidget {
  const MainScreens({super.key});

  @override
  State<MainScreens> createState() => _MainScreensState();
}

class _MainScreensState extends State<MainScreens> {
  int _curScreen = 0;
  var screens = [
    const HomePage(),
    const SearchPage(),
    const FriendsPage(),
    AccountPage(uid: Auth().currentUser?.uid ?? '')
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(
      // Here we take the value from the MyHomePage object that was created by
      // the App.build method, and use it to set our appbar title.
      //title: Text(widget.title),
      //),
      body: screens[_curScreen],
      // The actual body of the Scaffold depends on the currently selected tab in bottom navigation
      bottomNavigationBar: NavigationBar(
        //type: BottomNavigationBarType.fixed,
        selectedIndex: _curScreen,
        //selectedFontSize: 14,
        //unselectedFontSize: 14,
        onDestinationSelected: (value) {
          setState(() => {_curScreen = value}); // The current screen is changed
        },
        destinations: const [
          NavigationDestination(
            label: 'Home',
            icon: Icon(Icons.home),
          ),
          NavigationDestination(
            label: 'Search',
            icon: Icon(Icons.search),
          ),
          NavigationDestination(
            label: 'Friends',
            icon: Icon(Icons.people),
          ),
          NavigationDestination(
            label: 'Account',
            icon: Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}
