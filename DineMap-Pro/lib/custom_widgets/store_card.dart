import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../store_screen.dart'; // Assuming this path is correct
import '../../cubits/store/store_cubit.dart';
import '../../cubits/store/store_state.dart';

class StoreCard extends StatelessWidget {
  final int id;
  final String storeName;
  final String imageUrl;
  final String district;
  final double distance;

  const StoreCard({
    super.key,
    required this.id,
    required this.storeName,
    required this.imageUrl,
    required this.district,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    // Use BlocSelector for more targeted rebuilds if your StoreState is complex.
    // For simple favorite toggling, BlocBuilder is often fine.
    // We'll stick with BlocBuilder as per your original code, assuming StoreCubit
    // correctly emits a new state when favorites change.
    return BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) {
        // It's generally good practice to get isFav directly from the state
        // if possible, or ensure StoreCubit.isFavorite() is efficient.
        // context.read() is fine here because BlocBuilder handles the rebuild.
        final isFav = context.read<StoreCubit>().isFavorite(id);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StoreScreen(storeID: id)),
            );
          },
          child: Card(
            margin: const EdgeInsets.all(8.0), // Increased margin slightly for better spacing
            clipBehavior: Clip.antiAlias,
            elevation: 5,
            shape: RoundedRectangleBorder( // Added rounded corners for a softer look
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Important for Column in constrained environments
              children: [
                Stack(
                  children: [
                    // Image handling
                    AspectRatio( // Ensures the image maintains an aspect ratio
                      aspectRatio: 16 / 9, // Common aspect ratio for images, adjust as needed
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        // width: double.infinity, // AspectRatio handles width relative to height
                        // height: 120, // Controlled by AspectRatio now
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                            ),
                          );
                        },
                      ),
                    ),
                    // Favorite button in top-right corner
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Material( // Added Material for InkWell ripple effect to be visible
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            context.read<StoreCubit>().toggleFavorite(id);
                          },
                          child: Container( // Added a background for better visibility if icon is white on light image
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.redAccent : Colors.white,
                              size: 24, // Slightly smaller for better padding
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0), // Increased padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16, // Slightly larger font
                        ),
                        maxLines: 2, // Allow store name to wrap up to 2 lines
                        overflow: TextOverflow.ellipsis, // Ellipsis if it's still too long
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          // Flexible allows the district text to take available space
                          // and shrink if necessary, preventing overflow.
                          Flexible(
                            child: Text(
                              district,
                              overflow: TextOverflow.ellipsis, // Ellipsis if it's too long
                              maxLines: 1, // Ensure it stays on one line
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                          // Spacer will take up any remaining space BETWEEN flexible district and fixed-size distance

                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}