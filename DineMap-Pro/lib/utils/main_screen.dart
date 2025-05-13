import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../home_screen.dart';
import '../favorites_screen.dart';
import '../utils/nav_bar.dart';
import '../cubits/navigation/navigation_cubit.dart';
import '../cubits/navigation/navigation_state.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        final List<Widget> screens = [
          HomeScreen(screenType: 'Home'),
          FavoritesScreen(screenType: 'Favorites'),
        ];

        return Scaffold(
          body: screens[state.currentIndex],
          bottomNavigationBar: ShopNavBar(
            currentIndex: state.currentIndex,
            onTabSelected: (index) {
              context.read<NavigationCubit>().navigateTo(index);
            },
          ),
        );
      },
    );
  }
}