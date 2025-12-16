# app.py

from flask import Flask, request, jsonify, Response
from flask_sqlalchemy import SQLAlchemy
from dotenv import load_dotenv
from flask_cors import CORS
from datetime import datetime
import os

# Load .env
load_dotenv()

# Flask app
app = Flask(__name__)
CORS(app)

# DB config
app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv("DATABASE_URL")
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db = SQLAlchemy(app)

# --------------------------
# MODELS
# --------------------------

class Product(db.Model):
    __tablename__ = "products"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String)
    description = db.Column(db.String)
    price = db.Column(db.Float)
    stock_quantity = db.Column(db.Integer)

    order_items = db.relationship("OrderItem", back_populates="product")


class Order(db.Model):
    __tablename__ = "orders"

    id = db.Column(db.Integer, primary_key=True)
    customer_name = db.Column(db.String)
    order_date = db.Column(db.DateTime)
    total_price = db.Column(db.Float)
    status = db.Column(db.String)

    items = db.relationship("OrderItem", back_populates="order")


class OrderItem(db.Model):
    __tablename__ = "order_items"

    order_id = db.Column(db.Integer, db.ForeignKey("orders.id"), primary_key=True)
    product_id = db.Column(db.Integer, db.ForeignKey("products.id"), primary_key=True)
    quantity = db.Column(db.Integer)
    price_at_purchase = db.Column(db.Float)

    product = db.relationship("Product", back_populates="order_items")
    order = db.relationship("Order", back_populates="items")

# Create tables (PostgreSQL)
with app.app_context():
    db.create_all()


# --------------------------
# PRODUCT ENDPOINTS
# --------------------------

@app.get("/products")
def list_products():
    products = Product.query.all()
    results = []
    for p in products:
        results.append({
            "id": p.id,
            "name": p.name,
            "description": p.description,
            "price": p.price,
            "stock_quantity": p.stock_quantity
        })
    return jsonify(results)


@app.get("/products/<int:id>")
def get_product(id):
    product = Product.query.get_or_404(id)
    return {
        "id": product.id,
        "name": product.name,
        "description": product.description,
        "price": product.price,
        "stock_quantity": product.stock_quantity
    }


@app.post("/products")
def create_product():
    data = request.json
    product = Product(
        name=data.get("name"),
        description=data.get("description"),
        price=data.get("price"),
        stock_quantity=data.get("stock_quantity")
    )
    db.session.add(product)
    db.session.commit()
    return {"message": "Product created", "id": product.id}, 201


@app.put("/products/<int:id>")
def update_product(id):
    product = Product.query.get_or_404(id)
    data = request.json

    product.name = data.get("name", product.name)
    product.description = data.get("description", product.description)
    product.price = data.get("price", product.price)
    product.stock_quantity = data.get("stock_quantity", product.stock_quantity)

    db.session.commit()
    return {"message": "Product updated"}


@app.delete("/products/<int:id>")
def delete_product(id):
    product = Product.query.get_or_404(id)
    db.session.delete(product)
    db.session.commit()
    return {"message": "Product deleted"}


# --------------------------
# ORDER ENDPOINTS
# --------------------------

@app.post("/orders")
def create_order():
    data = request.json
    items = data.get("items", [])

    order = Order(
        customer_name=data.get("customer_name"),
        status="Pending",
        total_price=0,
        order_date=datetime.utcnow()
    )
    db.session.add(order)
    db.session.commit()

    for item in items:
        product_id = item["product_id"]
        quantity = item["quantity"]

        product = Product.query.get_or_404(product_id)
        product.stock_quantity -= quantity

        order_item = OrderItem(
            order_id=order.id,
            product_id=product_id,
            quantity=quantity,
            price_at_purchase=product.price
        )

        db.session.add(order_item)

    db.session.commit()

    # calculate total
    total = 0
    for item in order.items:
        total += item.quantity * item.price_at_purchase

    order.total_price = total
    db.session.commit()

    return {
        "message": "Order created",
        "id": order.id,
        "total_price": total
    }, 201


@app.get("/orders")
def list_orders():
    orders = Order.query.all()
    results = []
    for o in orders:
        results.append({
            "id": o.id,
            "customer_name": o.customer_name,
            "status": o.status,
            "total_price": o.total_price,
            "order_date": o.order_date,
            "items": [
                {
                    "product_id": item.product_id,
                    "quantity": item.quantity,
                    "price_at_purchase": item.price_at_purchase
                }
                for item in o.items
            ]
        })
    return jsonify(results)


@app.get("/orders/<int:id>")
def get_order(id):
    o = Order.query.get_or_404(id)
    return {
        "id": o.id,
        "customer_name": o.customer_name,
        "status": o.status,
        "total_price": o.total_price,
        "items": [
            {
                "product_id": item.product_id,
                "quantity": item.quantity,
                "price_at_purchase": item.price_at_purchase
            }
            for item in o.items
        ]
    }


@app.put("/orders/<int:id>/status")
def update_order_status(id):
    data = request.json
    new_status = data.get("status")

    order = Order.query.get_or_404(id)
    order.status = new_status
    db.session.commit()

    return {"message": f"Order status updated to {new_status}"}


# --------------------------
# RUN SERVER
# --------------------------
if __name__ == "__main__":
    app.run(debug=True)
