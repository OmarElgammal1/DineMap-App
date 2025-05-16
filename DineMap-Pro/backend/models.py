from config import app, db
from datetime import datetime


class User(db.Model):
    __tablename__ = 'user'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    gender = db.Column(db.String(10), nullable=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    level = db.Column(db.Integer, nullable=True)
    password = db.Column(db.String(120), nullable=False)

    favorites = db.relationship(
        'Favorite', back_populates='user',
        cascade='all, delete-orphan', lazy='dynamic'
    )

    def __init__(self, name, gender, email, level, password):
        self.name = name
        self.gender = gender
        self.email = email
        self.level = level
        self.password = password

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'gender': self.gender,
            'email': self.email,
            'level': self.level
        }

    def favorite_restaurant(self, restaurant):
        if not self.is_favorite(restaurant):
            fav = Favorite(user=self, restaurant=restaurant)
            db.session.add(fav)

    def unfavorite_restaurant(self, restaurant):
        fav = self.favorites.filter_by(restaurant_id=restaurant.id).first()
        if fav:
            db.session.delete(fav)

    def is_favorite(self, restaurant):
        return self.favorites.filter_by(restaurant_id=restaurant.id).count() > 0

class Restaurant(db.Model):
    __tablename__ = 'restaurant'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    address = db.Column(db.String(300), nullable=False)
    district = db.Column(db.String(100), nullable=False)
    image_url = db.Column(db.String(500), nullable=True)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)

    products = db.relationship('Product', back_populates='restaurant', lazy=True)
    favorited_by = db.relationship(
        'Favorite', back_populates='restaurant',
        cascade='all, delete-orphan', lazy='dynamic'
    )

    def __init__(self, name, address, district, image_url, latitude, longitude):
        self.name = name
        self.address = address
        self.district = district
        self.image_url = image_url
        self.latitude = latitude
        self.longitude = longitude

    def to_dict(self):
        return {
            'restaurantID': self.id,
            'restaurantName': self.name,
            'address': self.address,
            'district': self.district,
            'imageUrl': self.image_url,
            'latitude': self.latitude,
            'longitude': self.longitude,
            'products': [product.to_dict() for product in self.products]
        }

    def num_favorites(self):
        return self.favorited_by.count()

class Product(db.Model):
    __tablename__ = 'product'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    price = db.Column(db.Float, nullable=False)
    image_url = db.Column(db.String(500), nullable=True)
    restaurant_id = db.Column(db.Integer, db.ForeignKey('restaurant.id'), nullable=False)

    restaurant = db.relationship('Restaurant', back_populates='products')

    def __init__(self, name, price, image_url, restaurant_id):
        self.name = name
        self.price = price
        self.image_url = image_url
        self.restaurant_id = restaurant_id

    def to_dict(self):
        return {
            'productID': self.id,
            'productName': self.name,
            'price': self.price,
            'imageUrl': self.image_url,
            'restaurantID': self.restaurant_id
        }

class Favorite(db.Model):
    __tablename__ = 'favorite'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    restaurant_id = db.Column(db.Integer, db.ForeignKey('restaurant.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    user = db.relationship('User', back_populates='favorites')
    restaurant = db.relationship('Restaurant', back_populates='favorited_by')

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'restaurant_id': self.restaurant_id,
            'created_at': self.created_at.isoformat()
        }
