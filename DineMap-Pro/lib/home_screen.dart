import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart'; // For Position type
import 'cubits/store/store_cubit.dart';
import 'cubits/store/store_state.dart';
import 'cubits/user/user_cubit.dart';
import 'cubits/user/user_state.dart';
import 'models/store.dart';
import 'custom_widgets/store_card.dart';
import 'map_screen.dart'; // Import the new map screen

class HomeScreen extends StatefulWidget {
  final int? userId;
  const HomeScreen({ Key? key, required this.userId }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // once the widget is up, tell StoreCubit who we are

    context.read<StoreCubit>().setUserId(widget.userId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<StoreCubit, StoreState>(
        builder: (context, state) {
          List<Widget> slivers = [];

          // AppBar and Search Bar (always present)
          slivers.add(
            SliverPadding(
              padding: const EdgeInsets.only(top: 0.0),
              sliver: SliverAppBar(
                title: BlocBuilder<UserCubit, UserState>(
                  builder: (context, userState) {
                    String username = 'User'; // Default
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
                floating: true, // App bar floats
                pinned: true, // Search bar stays pinned
                centerTitle: true,
                backgroundColor:
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                elevation: 0.5,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(
                      kToolbarHeight + 10), // Space for TextField
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 10.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Products in Restaurants...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  // Fetch all stores again
                                  context
                                      .read<StoreCubit>()
                                      .fetchStoresFromApi();
                                  // Optionally, unfocus the TextField
                                  FocusScope.of(context).unfocus();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      onSubmitted: (String query) {
                        if (query.trim().isNotEmpty) {
                          context
                              .read<StoreCubit>()
                              .searchRestaurantsByProduct(query);
                        } else {
                          context.read<StoreCubit>().fetchStoresFromApi();
                        }
                      },
                      onChanged: (String query) {
                        // Rebuild to show/hide clear button
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
            ),
          );

          // Content based on state
          if (state is StoreInitial || state is StoreLoading) {
            slivers.add(const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator())));
          } else if (state is StoreSearchLoading) {
            slivers.add(const SliverFillRemaining(
                child: Center(
                    child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Searching for products...",
                    style: TextStyle(fontSize: 16)),
              ],
            ))));
          } else if (state is StoreError) {
            slivers.add(SliverFillRemaining(
                child: Center(
                    child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: ${state.message}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red)),
            ))));
          } else if (state is StoresLoaded) {
            var storeList = state.allStores.values.toList();
            if (storeList.isEmpty) {
              slivers.add(SliverFillRemaining(
                  child:
                      _buildNoResultsView('No stores available right now.')));
            } else {
              slivers
                  .add(_buildStoreGridSliver(storeList, state.currentPosition));
            }
          } else if (state is StoreSearchResultsLoaded) {
            // Add "View on Map" button if results exist
            if (state.searchedRestaurants.isNotEmpty) {
              slivers.add(SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 10.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.map_outlined),
                    label: Text(
                        "View ${state.searchedRestaurants.length} Result(s) on Map"),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontSize: 16)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MapScreen(
                            restaurants: state.searchedRestaurants,
                            userCurrentPosition: state.currentPosition,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ));
            }
            // Then add the grid of search results
            slivers.add(_buildStoreGridSliver(
                state.searchedRestaurants, state.currentPosition));
          } else if (state is StoreSearchEmpty) {
            slivers.add(SliverFillRemaining(
                child: _buildNoResultsView(
                    "No restaurants found for your search.")));
          } else {
            // Fallback for any other unhandled state
            slivers.add(const SliverFillRemaining(
                child: Center(
                    child: Text(
              'Welcome! Use the search bar to find products in restaurants.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ))));
          }

          return CustomScrollView(slivers: slivers);
        },
      ),
    );
  }

  Widget _buildNoResultsView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_outlined, size: 70, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(message,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                context
                    .read<StoreCubit>()
                    .fetchStoresFromApi(); // Go back to all stores
                FocusScope.of(context).unfocus();
              },
              child: const Text("Clear Search & View All Stores"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStoreGridSliver(
      List<Store> storeList, Position? currentPosition) {
    if (storeList.isEmpty) {
      return SliverFillRemaining(
        // If grid is empty, fill with a message
        child: _buildNoResultsView("No stores to display in this list."),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
          15.0, 5.0, 15.0, 15.0), // Reduced top padding
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 0.82, // Adjust for content
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            Store store = storeList[index];
            double distance = 0.0;
            if (currentPosition != null) {
              // Ensure calculateDistance is accessible or pass it down.
              // For simplicity, assuming it's on the cubit.
              distance = context
                  .read<StoreCubit>()
                  .calculateDistance(store.latitude, store.longitude);
            }

            return StoreCard(
              id: store.restaurantID,
              storeName: store.restaurantName,
              imageUrl: store.imageUrl,
              district: store.district,
              distance: distance,
            );
          },
          childCount: storeList.length,
        ),
      ),
    );
  }
}
