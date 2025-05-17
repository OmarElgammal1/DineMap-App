import os  # Add os import
from routes import app, db
from models import Product, Restaurant
import json

def initialize_database():
    with app.app_context():
        db.create_all()  # Create tables if they don't exist

        # Check if data needs to be seeded
        if not Restaurant.query.first():
            data_json_path = os.path.join(os.path.dirname(__file__), 'data.json')
            if os.path.exists(data_json_path):
                print(f"Database is empty or restaurants table is empty, loading data from {data_json_path}")
                with open(data_json_path, 'r', encoding='utf-8') as f:
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
                    db.session.flush()  # Ensure restaurant.id is available for products

                    for prod in entry['products']:
                        print(f"    Loading Product: {prod['productName']} for Restaurant {restaurant.name}")
                        db.session.add(Product(
                            name=prod['productName'],
                            price=prod['price'],
                            image_url=prod['imageUrl'],
                            restaurant_id=restaurant.id
                        ))
                db.session.commit()
                print("Data loading complete.")
            else:
                print(f"data.json not found at {data_json_path}, skipping data seeding.")
        else:
            print("Database already contains restaurant data, skipping data seeding.")

# Initialize the database when the app module is loaded
# This will be executed when Vercel loads app.py
initialize_database()

if __name__ == '__main__':
    # The app.app_context() and db.create_all() calls are now handled by initialize_database()
    # So, they are not strictly needed here again for local runs if initialize_database() is always called.
    # However, keeping app.run for local development is fine.
    app.run(host='0.0.0.0', port=5000, debug=True)

# curl -X POST http://localhost:5000/signup -H "Content-Type: application/json" -d "{\"name\":\"Omar\",\"gender\":\"male\",\"email\":\"omar@gmail.com\",\"level\":4,\"password\":\"securepassword123\", \"confirm_password\":\"securepassword123\"}"
# curl -X GET http://localhost:5000/users