import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/store/store_cubit.dart';
import 'cubits/store/store_state.dart';
import 'cubits/user/user_cubit.dart';
import 'cubits/user/user_state.dart';
import 'models/store.dart';
import 'custom_widgets/store_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) {
        if (state is StoreInitial || state is StoreLoading) { // Handle loading state
          return const Center(child: CircularProgressIndicator());
        } else if (state is StoreError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is StoresLoaded) {
          // state.allStores is now Map<int, Store>
          var storeList = state.allStores.values.toList(); // Get list of Store objects

          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(top: 10.0),
                  sliver: SliverAppBar(
                    title: BlocBuilder<UserCubit, UserState>(
                      builder: (context, userState) {
                        String username = 'User';
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
                      enabled: false, // Consider enabling this for actual search functionality
                      decoration: InputDecoration(
                        hintText: 'Search Restaurants...',
                        prefixIcon: const Icon(Icons.search),
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        Store store = storeList[index]; // store is now a Store object

                        // The commented-out distance calculation can be re-enabled if needed:
                        // double distance = 0.0;
                        // if (state.currentPosition != null && store.latitude != null && store.longitude != null) {
                        //   distance = context.read<StoreCubit>().calculateDistance(store.latitude, store.longitude);
                        // }
                        // You could then pass `distance` to StoreCard if it's designed to display it.

                        return StoreCard(
                          // Ensure StoreCard constructor matches these parameters
                          // and that Store object has `restaurantID` or adapt as needed.
                          id: store.restaurantID, // Assuming Store has restaurantID
                          storeName: store.restaurantName,
                          imageUrl: store.imageUrl,
                          district: store.district,
                          // Add other parameters like distance if you implement it
                        );
                      },
                      childCount: storeList.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink(); // Fallback, should ideally not be reached if states are handled
      },
    );
  }
}
