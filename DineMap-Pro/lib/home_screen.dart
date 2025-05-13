import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_finder/providers/user_provider.dart';
import 'custom_widgets/store_card.dart';
import 'providers/store_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    var allStores = storeProvider.allStores;
    var storeList = allStores.entries.toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(top: 10.0),
            sliver: SliverAppBar(
              title: Text(
                'Welcome, ${Provider.of<UserProvider>(context).username} 👋',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              floating: true,
              centerTitle: true,
              backgroundColor: Colors.transparent, // Optional: to make it blend
              elevation: 0, // Optional: remove shadow
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
}
