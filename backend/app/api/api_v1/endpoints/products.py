from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app import schemas
from app.core.database import get_db
from app.services.user_service import user_service
from app.services.product_service import product_service

router = APIRouter()

@router.post("/", response_model=schemas.Product)
def create_product(
    *,
    db: Session = Depends(get_db),
    product_in: schemas.ProductCreate,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Create new product
    """
    product = product_service.create(
        db, obj_in=product_in, owner_id=current_user.id
    )
    return product

@router.get("/", response_model=List[schemas.Product])
def read_products(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    category: str = None,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Retrieve products for current user
    """
    products = product_service.get_by_owner(
        db, 
        owner_id=current_user.id, 
        skip=skip, 
        limit=limit,
        category=category
    )
    return products

@router.get("/top", response_model=List[schemas.Product])
def read_top_products(
    db: Session = Depends(get_db),
    limit: int = 10,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Get top performing products
    """
    products = product_service.get_top_products(
        db, user_id=current_user.id, limit=limit
    )
    return products

@router.get("/categories", response_model=List[str])
def read_product_categories(
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Get product categories for current user
    """
    categories = product_service.get_product_categories(
        db, owner_id=current_user.id
    )
    return categories

@router.get("/{product_id}", response_model=schemas.Product)
def read_product(
    *,
    db: Session = Depends(get_db),
    product_id: int,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Get product by ID
    """
    product = product_service.get(db, product_id=product_id)
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
    if product.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions"
        )
    return product

@router.put("/{product_id}", response_model=schemas.Product)
def update_product(
    *,
    db: Session = Depends(get_db),
    product_id: int,
    product_in: schemas.ProductUpdate,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Update product
    """
    product = product_service.get(db, product_id=product_id)
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
    if product.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions"
        )
    
    product = product_service.update(db, db_obj=product, obj_in=product_in)
    return product

@router.post("/bundles", response_model=schemas.ProductBundle)
def create_product_bundle(
    *,
    db: Session = Depends(get_db),
    bundle_in: schemas.ProductBundleCreate,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Create product bundle
    """
    bundle = product_service.create_bundle(
        db, obj_in=bundle_in, owner_id=current_user.id
    )
    return bundle

@router.get("/bundles/", response_model=List[schemas.ProductBundle])
def read_product_bundles(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: schemas.User = Depends(user_service.get_current_user),
) -> Any:
    """
    Retrieve product bundles for current user
    """
    bundles = product_service.get_bundles_by_owner(
        db, owner_id=current_user.id, skip=skip, limit=limit
    )
    return bundles
