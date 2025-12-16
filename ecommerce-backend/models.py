from sqlalchemy.orm import declarative_base, relationship
from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey

Base = declarative_base()


class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True)
    name = Column(String)
    description = Column(String)
    price = Column(Float)
    stock_quantity = Column(Integer)

    order_items = relationship("OrderItem", back_populates="product")


class Order(Base):
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True)
    customer_name = Column(String)
    order_date = Column(DateTime)
    total_price = Column(Float)
    status = Column(String)

    items = relationship("OrderItem", back_populates="order")


class OrderItem(Base):
    __tablename__ = "order_items"

    order_id = Column(Integer, ForeignKey("orders.id"), primary_key=True)
    product_id = Column(Integer, ForeignKey("products.id"), primary_key=True)
    quantity = Column(Integer)
    price_at_purchase = Column(Float)

    product = relationship("Product", back_populates="order_items")
    order = relationship("Order", back_populates="items")
