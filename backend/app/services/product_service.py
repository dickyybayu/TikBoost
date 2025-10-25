from typing import List, Optional, Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy import desc, func
from app.models.models import Product, ProductBundle, BundleProduct
from app.schemas.schemas import ProductCreate, ProductUpdate, ProductBundleCreate

class ProductService:
    def create(
        self, db: Session, *, obj_in: ProductCreate, owner_id: int
    ) -> Product:
        db_obj = Product(
            name=obj_in.name,
            description=obj_in.description,
            price=obj_in.price,
            currency=obj_in.currency,
            image_url=obj_in.image_url,
            category=obj_in.category,
            stock_quantity=obj_in.stock_quantity,
            owner_id=owner_id
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def get(self, db: Session, product_id: int) -> Optional[Product]:
        return db.query(Product).filter(Product.id == product_id).first()

    def get_by_owner(
        self, 
        db: Session, 
        owner_id: int, 
        skip: int = 0, 
        limit: int = 100,
        category: Optional[str] = None,
        active_only: bool = True
    ) -> List[Product]:
        query = db.query(Product).filter(Product.owner_id == owner_id)
        
        if active_only:
            query = query.filter(Product.is_active == True)
            
        if category:
            query = query.filter(Product.category == category)
        
        return query.order_by(desc(Product.created_at)).offset(skip).limit(limit).all()

    def get_top_products(
        self, db: Session, user_id: int, limit: int = 5
    ) -> List[Product]:
        return (
            db.query(Product)
            .filter(Product.owner_id == user_id)
            .order_by(desc(Product.total_sold))
            .limit(limit)
            .all()
        )

    def update(
        self, db: Session, *, db_obj: Product, obj_in: ProductUpdate
    ) -> Product:
        update_data = obj_in.dict(exclude_unset=True)
        for field in update_data:
            if hasattr(db_obj, field):
                setattr(db_obj, field, update_data[field])
        
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def update_stock(
        self, db: Session, *, product_id: int, quantity_sold: int
    ) -> Product:
        product = self.get(db, product_id)
        if product:
            product.stock_quantity = max(0, product.stock_quantity - quantity_sold)
            product.total_sold += quantity_sold
            product.revenue_generated += product.price * quantity_sold
            
            db.add(product)
            db.commit()
            db.refresh(product)
        return product

    def calculate_conversion_rate(
        self, db: Session, product_id: int, views: int
    ) -> float:
        product = self.get(db, product_id)
        if product and views > 0:
            conversion_rate = (product.total_sold / views) * 100
            product.conversion_rate = conversion_rate
            db.add(product)
            db.commit()
            return conversion_rate
        return 0.0

    # Bundle operations
    def create_bundle(
        self, db: Session, *, obj_in: ProductBundleCreate, owner_id: int
    ) -> ProductBundle:
        db_obj = ProductBundle(
            name=obj_in.name,
            description=obj_in.description,
            bundle_price=obj_in.bundle_price,
            discount_percentage=obj_in.discount_percentage,
            owner_id=owner_id
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        
        # Add products to bundle
        for i, product_id in enumerate(obj_in.product_ids):
            quantity = obj_in.quantities[i] if i < len(obj_in.quantities) else 1
            bundle_product = BundleProduct(
                bundle_id=db_obj.id,
                product_id=product_id,
                quantity=quantity
            )
            db.add(bundle_product)
        
        db.commit()
        return db_obj

    def get_bundles_by_owner(
        self, db: Session, owner_id: int, skip: int = 0, limit: int = 100
    ) -> List[ProductBundle]:
        return (
            db.query(ProductBundle)
            .filter(ProductBundle.owner_id == owner_id)
            .order_by(desc(ProductBundle.created_at))
            .offset(skip)
            .limit(limit)
            .all()
        )

    def get_product_categories(self, db: Session, owner_id: int) -> List[str]:
        result = (
            db.query(Product.category)
            .filter(Product.owner_id == owner_id, Product.category.isnot(None))
            .distinct()
            .all()
        )
        return [category[0] for category in result if category[0]]

product_service = ProductService()
