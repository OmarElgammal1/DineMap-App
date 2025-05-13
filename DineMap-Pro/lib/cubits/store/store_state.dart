abstract class StoreState {}

// Initial state
class StoreInitial extends StoreState {}

// Loaded state with stores data
class StoresLoaded extends StoreState {
  final Map<int, Map<String, dynamic>> allStores;
  final Map<int, Map<String, dynamic>> favoriteStores;
  final dynamic currentPosition;

  StoresLoaded({
    required this.allStores,
    required this.favoriteStores,
    this.currentPosition,
  });
}

// Error state
class StoreError extends StoreState {
  final String message;

  StoreError(this.message);
}