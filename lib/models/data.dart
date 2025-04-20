// Sample store data to replace product data
final Map<int, Map<String, dynamic>> stores = {
  1: {
    'storeName': 'Downtown Coffee',
    'category': 'Coffee Shop',
    'address': '123 Main St, New York, NY 10001',
    'latitude': 40.7128,
    'longitude': -74.0060,
    'imageUrl': 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
    'distance': 1.2,
    'travelTime': 15,
    'isFavorite': false,
    'hours': '7:00 AM - 9:00 PM',
    'phone': '(212) 555-1234',
    'description': 'A cozy downtown coffee shop offering artisanal coffees, pastries, and a quiet atmosphere for work or meetings.',
    'reviews': [
      {
        'name': 'Jane Smith',
        'date': 'March 12, 2025',
        'rating': 4.5,
        'comment': 'Great coffee and atmosphere! The staff was very friendly and the pastries were delicious.'
      }
    ]
  },
  2: {
    'storeName': 'Tech Haven',
    'category': 'Electronics Store',
    'address': '456 Broadway, New York, NY 10013',
    'latitude': 40.7193,
    'longitude': -74.0017,
    'imageUrl': 'https://images.unsplash.com/photo-1518997554305-5eea2f04e384?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
    'distance': 2.5,
    'travelTime': 20,
    'isFavorite': true,
    'hours': '10:00 AM - 8:00 PM',
    'phone': '(212) 555-5678',
    'description': 'Your one-stop shop for all things tech. We carry the latest gadgets, accessories, and offer repair services.',
    'reviews': [
      {
        'name': 'Michael Johnson',
        'date': 'April 2, 2025',
        'rating': 5.0,
        'comment': 'Amazing selection of products and very knowledgeable staff. They helped me find exactly what I needed.'
      }
    ]
  },
  3: {
    'storeName': 'Green Grocery',
    'category': 'Grocery Store',
    'address': '789 Park Ave, New York, NY 10021',
    'latitude': 40.7705,
    'longitude': -73.9653,
    'imageUrl': 'https://images.unsplash.com/photo-1542838132-92c53300491e?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
    'distance': 0.8,
    'travelTime': 10,
    'isFavorite': false,
    'hours': '8:00 AM - 10:00 PM',
    'phone': '(212) 555-9012',
    'description': 'Fresh, organic produce and locally sourced goods. We prioritize sustainable practices and offer a wide variety of health foods.',
    'reviews': [
      {
        'name': 'Emily Davis',
        'date': 'March 28, 2025',
        'rating': 4.0,
        'comment': 'Great selection of organic produce. Prices are a bit high but the quality is worth it.'
      }
    ]
  },
  4: {
    'storeName': 'Fashion Forward',
    'category': 'Clothing Store',
    'address': '321 5th Ave, New York, NY 10016',
    'latitude': 40.7448,
    'longitude': -73.9853,
    'imageUrl': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
    'distance': 1.5,
    'travelTime': 18,
    'isFavorite': true,
    'hours': '11:00 AM - 9:00 PM',
    'phone': '(212) 555-3456',
    'description': 'Trendy clothing and accessories for the fashion-conscious. We feature new collections every season from both established and emerging designers.',
    'reviews': [
      {
        'name': 'Sarah Williams',
        'date': 'April 10, 2025',
        'rating': 4.2,
        'comment': 'Love their selection! Staff is helpful and they often have good sales.'
      }
    ]
  },
  5: {
    'storeName': 'Book Nook',
    'category': 'Bookstore',
    'address': '567 Lexington Ave, New York, NY 10022',
    'latitude': 40.7573,
    'longitude': -73.9712,
    'imageUrl': 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
    'distance': 3.0,
    'travelTime': 25,
    'isFavorite': false,
    'hours': '9:00 AM - 8:00 PM',
    'phone': '(212) 555-7890',
    'description': 'A charming independent bookstore with a carefully curated selection of books across all genres. We also host regular author events and book clubs.',
    'reviews': [
      {
        'name': 'David Brown',
        'date': 'March 15, 2025',
        'rating': 4.8,
        'comment': 'My favorite bookstore in the city! Great ambiance and they always have excellent recommendations.'
      }
    ]
  },
  6: {
    'storeName': 'Sports Central',
    'category': 'Sporting Goods',
    'address': '890 7th Ave, New York, NY 10019',
    'latitude': 40.7645,
    'longitude': -73.9801,
    'imageUrl': 'https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
    'distance': 2.2,
    'travelTime': 22,
    'isFavorite': false,
    'hours': '10:00 AM - 7:00 PM',
    'phone': '(212) 555-2345',
    'description': 'Everything you need for sports and fitness. We carry equipment and apparel for all major sports and outdoor activities.',
    'reviews': [
      {
        'name': 'Robert Wilson',
        'date': 'April 5, 2025',
        'rating': 3.9,
        'comment': 'Good selection of equipment but some items are overpriced. Staff is knowledgeable though.'
      }
    ]
  },
};

// Keep this as a fallback if needed for other parts of the app
final Map<int, Map<String, dynamic>> products = {
  // Empty or with minimal data if needed
};