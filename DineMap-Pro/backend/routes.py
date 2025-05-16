from flask import request, jsonify, Response
from models import User, Restaurant, Product, app, db
import requests
from math import radians, cos, sin, asin, sqrt
import re
from difflib import SequenceMatcher

# Registration routes

@app.route('/signup', methods=['POST'])
def signup():

    # Get data
    data = request.json
    name = data.get('name', None)
    gender = data.get('gender', None)
    email = data.get('email', None)
    level = data.get('level', None)
    password = data.get('password', None)
    confirm_password = data.get('confirm_password', None)
    email_regex = r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$'

    # Validate data
    if not name or not email or not password or not confirm_password:
        return jsonify({'message': 'All fields are required'}), 400
    
    if not re.match(email_regex, email):
        return jsonify({'message': 'Invalid email format'}), 400
    
    if User.query.filter_by(email=email).first():
        return jsonify({'message': 'Email already exists'}), 400
    
    if len(password) < 8:
        return jsonify({'message': 'Password must be at least 8 characters long'}), 400
    
    if gender and gender.lower() not in ['male', 'female']:
        return jsonify({'message': 'Invalid gender'}), 400
    
    if level and (level < 1 or level > 4):
        return jsonify({'message': 'Invalid level'}), 400

    if password != confirm_password:
        return jsonify({'message': 'Passwords do not match'}), 400
    

    # Create user
    new_user = User(
        name=name,
        gender=gender,
        email=email,
        level=level,
        password=password
    )
    db.session.add(new_user)
    db.session.commit()
    return jsonify({'message': 'User created successfully'}), 201


@app.route('/users', methods=['GET'])
def get_user():
    users = User.query.all()
    return jsonify([user.to_dict() for user in users]), 200
    

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email', None)
    password = data.get('password', None)

    if not email or not password:
        return jsonify({'message': 'Email and password are required'}), 400

    user = User.query.filter_by(email=email).first()
    if user and user.password == password:
        return jsonify({'message': 'Login successful', 'name': user.name}), 200
    else:
        return jsonify({'message': 'Invalid email or password'}), 401

# Restaurants related routes

@app.route('/restaurants', methods=['GET'])
def get_restaurants():
    restaurants = Restaurant.query.all()
    return jsonify([restaurant.to_dict() for restaurant in restaurants]), 200

@app.route('/restaurants/<int:restaurant_id>')
def get_restaurant(restaurant_id):
    restaurant = Restaurant.query.get(restaurant_id)
    if not restaurant:
        return jsonify({'message': 'Restaurant not found'}), 404
    return jsonify(restaurant.to_dict())

# Product related routes

@app.route('/products', methods=['GET'])
def get_products():
    products = Product.query.all()
    return jsonify([product.to_dict() for product in products]), 200

@app.route('/products/<int:product_id>/restaurants')
def get_restaurants_by_product(product_id):
    product = Product.query.get(product_id)
    if not product:
        return jsonify({'message': 'Product not found'}), 404
    restaurants = Restaurant.query.join(Product).filter(Product.id == product_id).all()
    return jsonify([restaurant.to_dict() for restaurant in restaurants])

# Search related routes

@app.route('/search/products', methods=['GET'])
def search_products():
    query = request.args.get('q', '').strip().lower()
    if not query:
        return jsonify({'message': 'Missing search query'}), 400

    products = Product.query.all()
    matched_products = []
    for product in products:
        name = product.name.lower()
        score = SequenceMatcher(None, query, name).ratio()
        print(query, name, score)
        if score > 0.5:
            matched_products.append({
                'product': product.to_dict(),
                'matchScore': round(score, 2)
            })

    matched_products.sort(key=lambda x: x['matchScore'], reverse=True)

    if len(matched_products) == 0:
        return Response(status=204)
    
    return jsonify(matched_products), 200

@app.route('/search/restaurants_by_product_name', methods=['GET'])
def search_restaurants_by_product_name():
    query = request.args.get('q', '').strip().lower()
    if not query:
        return jsonify({'message': 'Missing search query'}), 400

    all_products = Product.query.all()
    matched_restaurants = {} 

    for product in all_products:
        product_name = product.name.lower()
        if SequenceMatcher(None, query, product_name).ratio() > 0.5:
            restaurant = product.restaurant
            if restaurant and restaurant.id not in matched_restaurants:
                matched_restaurants[restaurant.id] = restaurant.to_dict()

    if not matched_restaurants:
        return jsonify({'message': 'No restaurants found offering a similar product'}), 404

    return jsonify(list(matched_restaurants.values())), 200


# Favorite related routes

@app.route('/users/<int:user_id>/favorites', methods=['GET'])
def get_user_favorites(user_id):
    user = User.query.get(user_id)
    if not user:
        return jsonify({'message': 'User not found'}), 404
    favorites = [fav.restaurant.to_dict() for fav in user.favorites]
    return jsonify(favorites), 200

@app.route('/users/<int:user_id>/favorites', methods=['POST'])
def add_favorite(user_id):
    data = request.json or {}
    restaurant_id = data.get('restaurant_id')
    user = User.query.get(user_id)
    restaurant = Restaurant.query.get(restaurant_id)
    if not user or not restaurant:
        return jsonify({'message': 'User or restaurant not found'}), 404
    if user.is_favorite(restaurant):
        return jsonify({'message': 'Already favorited'}), 400
    user.favorite_restaurant(restaurant)
    db.session.commit()
    return jsonify({'message': 'Added to favorites'}), 201

@app.route('/users/<int:user_id>/favorites/<int:restaurant_id>', methods=['DELETE'])
def remove_favorite(user_id, restaurant_id):
    user = User.query.get(user_id)
    restaurant = Restaurant.query.get(restaurant_id)
    if not user or not restaurant:
        return jsonify({'message': 'User or restaurant not found'}), 404
    if not user.is_favorite(restaurant):
        return jsonify({'message': 'Not in favorites'}), 400
    user.unfavorite_restaurant(restaurant)
    db.session.commit()
    return jsonify({'message': 'Removed from favorites'}), 200