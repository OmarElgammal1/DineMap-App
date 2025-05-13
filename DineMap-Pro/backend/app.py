from routes import app, db
from models import Product, Restaurant


if __name__ == '__main__':
    with app.app_context():
        db.create_all()
        if not Restaurant.query.first():
            restaurant1 = Restaurant(
                name='El Dabbagh',
                address='Mohyee Al Din Abd Al Al Hamid, Al Manteqah Ath Thamenah, Nasr City, Cairo Governorate 4441506',
                district='Cairo, Nasr City',
                image_url='https://blogger.googleusercontent.com/img/a/AVvXsEjmBLPSq4_UCcHv-PFH7iLnIIkyUXr_MZXHXX76oLl1-feCytWcKeYAdEdV1jX5EEVq4w9fnb38kL5kbUpYAYZRFissDmenxUx5DL8qaMNMT9DoLoq77DqE3rVu3dgPPzMvK5jzrJoSDFzh67GfHHwRC2y9-qYXnZjrpL1fBAWblIyvzVHhv_j7dWfl=w640-h358-rw',
                latitude=30.047983666181203,
                longitude=31.346979372173706
            )
            restaurant2 = Restaurant(
                name='Cafe LiverFool',
                address='Al Maadi, Cairo, Egypt',
                district='Cairo, Maadi',
                image_url='https://example.com/cafe_b_image.jpg',
                latitude=30.0399,
                longitude=31.2350
            )
            db.session.add(restaurant1)
            db.session.add(restaurant2)
        if not Product.query.first():
            product1 = Product(
                name='Chicken Shawerma',
                price=80.0,
                image_url='https://m.media-amazon.com/images/I/61TEazg2PxL._AC_UF894,1000_QL80_.jpg',
                restaurant_id=1
            )
            product2 = Product(
                name='V7 Cola',
                price=15.0,
                image_url='https://m.media-amazon.com/images/I/61TEazg2PxL._AC_UF894,1000_QL80_.jpg',
                restaurant_id=1
            )
            product3 = Product(
                name='Coffee',
                price=20.0,
                image_url='https://example.com/coffee_image.jpg',
                restaurant_id=2
            )
            product4 = Product(
                name='Pizza',
                price=50.0,
                image_url='https://example.com/pizza_image.jpg',
                restaurant_id=2
            )
            db.session.add(product1)
            db.session.add(product2)
            db.session.add(product3)
            db.session.add(product4)
        db.session.commit()
    app.run(host='0.0.0.0', port=5000, debug=True)


# curl -X POST http://localhost:5000/signup -H "Content-Type: application/json" -d "{\"name\":\"Omar\",\"gender\":\"male\",\"email\":\"omar@gmail.com\",\"level\":5,\"password\":\"securepassword123\", \"confirm_password\":\"securepassword123\"}"
# curl -X GET http://localhost:5000/users