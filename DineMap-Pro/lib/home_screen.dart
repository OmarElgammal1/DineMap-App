import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/store/store_cubit.dart';
import 'cubits/store/store_state.dart';
import 'cubits/user/user_cubit.dart';
import 'cubits/user/user_state.dart';
import 'custom_widgets/store_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) {
        if (state is StoreInitial) {
          return Center(child: CircularProgressIndicator());
        } else if (state is StoreError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is StoresLoaded) {
          var allStores = state.allStores;
          var storeList = allStores.entries.toList();

          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(top: 10.0),
                  sliver: SliverAppBar(
                    title: BlocBuilder<UserCubit, UserState>(
                      builder: (context, userState) {
                        String username = 'User'; // Default username as a fallback
                        if (userState is UserAuthenticated) {
                          username = userState.user.name;
                        }
                        return Text(
                          'Welcome, $username 👋',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    floating: true,
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 10.0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: 'Search Restaurants...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(15.0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      var storeEntry = storeList[index];
                      var store = storeEntry.value;
                      int id = storeEntry.key;

                      // // Calculate distance dynamically
                      // double storeLat = store['latitude'];
                      // double storeLng = store['longitude'];
                      // double distance = context.read<StoreCubit>().calculateDistance(storeLat, storeLng);

                      return StoreCard(
                        id: id,
                        storeName: store['restaurantName'],
                        imageUrl: store['imageUrl'],
                        district: store['district'],
                      );
                    }, childCount: storeList.length),
                  ),
                ),
              ],
            ),
          );
        }

        return SizedBox(); // Fallback
      },
    );
  }
}
