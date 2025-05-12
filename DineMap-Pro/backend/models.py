from config import app, db

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    gender = db.Column(db.String(10), nullable=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    level = db.Column(db.Integer, nullable=True)
    password = db.Column(db.String(120), nullable=False)
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
    

class Restaurant(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    address = db.Column(db.String(300), nullable=False)
    district = db.Column(db.String(100), nullable=False)
    image_url = db.Column(db.String(500), nullable=True)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)

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


class Product(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    price = db.Column(db.Float, nullable=False)
    image_url = db.Column(db.String(500), nullable=True)
    restaurant_id = db.Column(db.Integer, db.ForeignKey('restaurant.id'), nullable=False)
    restaurant = db.relationship('Restaurant', backref=db.backref('products', lazy=True))

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