import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy

# Attempt to import psycopg2 to check if it's available
try:
    import psycopg2
    print("Successfully imported psycopg2")
except ImportError as e:
    print(f"Error importing psycopg2: {e}")
    # Re-raise the error to make it clear in Vercel logs if this is the point of failure
    raise

app = Flask(__name__)

# PostgreSQL configuration
DATABASE_URL = os.environ.get('POSTGRES_URL')
print(f"Original POSTGRES_URL from env: {DATABASE_URL}") # For debugging

if DATABASE_URL:
    # Ensure the URL uses the 'postgresql+psycopg2' scheme for SQLAlchemy
    if DATABASE_URL.startswith("postgres://"):
        DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql+psycopg2://", 1)
        print(f"Modified DATABASE_URL for SQLAlchemy: {DATABASE_URL}")
    elif DATABASE_URL.startswith("postgresql://") and "+psycopg2" not in DATABASE_URL:
        # If it's already postgresql:// but doesn't specify psycopg2, we can add it
        DATABASE_URL = DATABASE_URL.replace("postgresql://", "postgresql+psycopg2://", 1)
        print(f"Modified DATABASE_URL (added +psycopg2) for SQLAlchemy: {DATABASE_URL}")
    elif not DATABASE_URL.startswith("postgresql+psycopg2://"):
        # Log if the URL is not in an expected format, though Vercel should provide a standard one.
        print(f"Warning: POSTGRES_URL is not in the expected 'postgres://' or 'postgresql://' format. URL: {DATABASE_URL}")
else:
    # Fallback for local development if POSTGRES_URL is not set
    print("Warning: POSTGRES_URL environment variable not found. Falling back to a default local SQLite DB (not recommended for production).")
    print("For Vercel deployment, ensure a Vercel Postgres database is linked and the POSTGRES_URL is available.")
    basedir = os.path.abspath(os.path.dirname(__file__))
    DATABASE_URL = 'sqlite:///' + os.path.join(basedir, 'food_delivery.db') # Fallback for local

app.config['SQLALCHEMY_DATABASE_URI'] = DATABASE_URL
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)