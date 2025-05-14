from routes import app, db
from models import Product, Restaurant
import json

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
        if not Restaurant.query.first():
            with open('data.json', 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            for entry in data:
                print(f"Loading Restaurant: {entry['restaurantName']}")

                restaurant = Restaurant(
                    name=entry['restaurantName'],
                    address=entry['address'],
                    district=entry['district'],
                    image_url=entry['imageUrl'],
                    latitude=entry['latitude'],
                    longitude=entry['longitude']
                )

                db.session.add(restaurant)

                db.session.flush()

                for prod in entry['products']:
                    print(f"    Loading Product:{prod['productName']} for Restaurant")
                    db.session.add(Product(
                        name=prod['productName'],
                        price=prod['price'],
                        image_url=prod['imageUrl'],
                        restaurant_id=restaurant.id
                    ))
        db.session.commit()
    app.run(host='0.0.0.0', port=5000, debug=True)


# curl -X POST http://localhost:5000/signup -H "Content-Type: application/json" -d "{\"name\":\"Omar\",\"gender\":\"male\",\"email\":\"omar@gmail.com\",\"level\":4,\"password\":\"securepassword123\", \"confirm_password\":\"securepassword123\"}"
# curl -X GET http://localhost:5000/users