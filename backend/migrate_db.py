"""
Database migration script for TikBoost
Creates all tables and initializes database
"""
import sys
import os

# Add parent directory to path for imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy import create_engine
from app.core.config import settings
from app.models.models import Base
from app.models.ai_recommendations import AIRecommendation, UserProduct

def create_tables():
    """Create all database tables"""
    print("🔧 Creating database tables...")
    
    # Create engine
    engine = create_engine(settings.DATABASE_URL, echo=True)
    
    # Create all tables
    Base.metadata.create_all(bind=engine)
    
    print("✅ Database tables created successfully!")
    print(f"📍 Database URL: {settings.DATABASE_URL}")
    
    # List created tables
    print("\n📋 Created tables:")
    for table_name in Base.metadata.tables.keys():
        print(f"  - {table_name}")

def main():
    """Main migration function"""
    try:
        create_tables()
        print("\n🎉 Migration completed successfully!")
    except Exception as e:
        print(f"❌ Migration failed: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
