import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home_screen.dart';
import '../favorites_screen.dart';
import '../utils/nav_bar.dart';
import '../providers/navigation_provider.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavigationProvider(),
      child: Consumer<NavigationProvider>(
        builder: (context, navigationProvider, _) {
          final List<Widget> screens = [
            HomeScreen(screenType: 'Home'),
            FavoritesScreen(screenType: 'Favorites'),
          ];

          return Scaffold(
            body: screens[navigationProvider.currentIndex],
            bottomNavigationBar: ShopNavBar(
              currentIndex: navigationProvider.currentIndex,
              onTabSelected: (index) {
                navigationProvider.navigateTo(index);
              },
            ),
          );
        },
      ),
    );
  }
}