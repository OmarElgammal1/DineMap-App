import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'cubits/store/store_cubit.dart';
import 'cubits/store/store_state.dart';
import 'models/store.dart';
import 'custom_widgets/store_card.dart';
import 'map_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _predefinedSearchValues = [
    "Cola",
    "Shawerma",
    "Hawawshi",
    "Fried Chicken"
  ];

  @override
  void initState() {
    super.initState();
    // Optionally, fetch all stores initially if no search has been performed yet
    // context.read<StoreCubit>().fetchStoresFromApi();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.read<StoreCubit>().searchRestaurantsByProduct(query);
    } else {
      context.read<StoreCubit>().fetchStoresFromApi();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Products'),
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search Products in Restaurants...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
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
              onSubmitted: _performSearch,
              onChanged: (String query) {
                setState(() {}); // Rebuild to show/hide clear button
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _predefinedSearchValues.map((value) {
                return ActionChip(
                  label: Text(value),
                  backgroundColor: Colors.orange[100],
                  onPressed: () {
                    _searchController.text = value;
                    _performSearch(value);
                  },
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: BlocBuilder<StoreCubit, StoreState>(
              builder: (context, state) {
                if (state is StoreInitial ||
                    (state is StoresLoaded &&
                        _searchController.text.isEmpty &&
                        state.allStores.isEmpty)) {
                  // Show suggestions or initial message if nothing is searched yet and allStores is empty (or not loaded)
                  return const Center(
                    child: Text(
                      'Try searching for a product or select a category.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                } else if (state is StoreLoading &&
                    _searchController.text.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is StoreSearchLoading) {
                  return const Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Searching for restaurants...",
                          style: TextStyle(fontSize: 16)),
                    ],
                  ));
                } else if (state is StoreError) {
                  return Center(
                      child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error: ${state.message}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red)),
                  ));
                } else if (state is StoreSearchResultsLoaded) {
                  if (state.searchedRestaurants.isEmpty) {
                    return _buildNoResultsView(
                        "No restaurants found for your search.");
                  }
                  return Column(
                    children: [
                      if (state.searchedRestaurants.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 10.0),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.map_outlined),
                            label: Text(
                                "View ${state.searchedRestaurants.length} Result(s) on Map"),
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
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
                      Expanded(
                        child: _buildStoreGrid(
                            state.searchedRestaurants, state.currentPosition),
                      ),
                    ],
                  );
                } else if (state is StoreSearchEmpty) {
                  return _buildNoResultsView(
                      "No restaurants found for your search.");
                } else {
                  // Fallback for any other unhandled state or when search is empty
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text(
                        'Search for products or select a category to see results.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
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
                // Instead of fetching all stores, clear the search results in the cubit
                // or simply let the state revert to an initial/empty search state.
                context
                    .read<StoreCubit>()
                    .fetchStoresFromApi(); // Or a new method like clearSearchResults()
                setState(() {});
                FocusScope.of(context).unfocus();
              },
              child: const Text("Clear Search"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStoreGrid(List<Store> storeList, Position? currentPosition) {
    if (storeList.isEmpty) {
      return _buildNoResultsView("No stores to display in this list.");
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 15.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 0.85,
        ),
        itemCount: storeList.length,
        itemBuilder: (context, index) {
          Store store = storeList[index];
          double distance = 0.0;
          if (currentPosition != null) {
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
      ),
    );
  }
}
