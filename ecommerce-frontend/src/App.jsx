import { useState, useEffect } from "react";
import { Routes, Route, Link } from "react-router-dom";
import OrderHistory from "./OrderHistory";

export default function App() {
  const [products, setProducts] = useState([]);

  useEffect(() => {
    fetch(`${import.meta.env.VITE_API_URL}/products`)
      .then(res => res.json())
      .then(data => setProducts(data));
  }, []);

  function handleOrder(productId) {
    const qtyInput = document.getElementById(`qty-${productId}`);
    const quantity = Number(qtyInput.value);
    const order = {
    customer_name: "Frontend User",
    items: [
      {
        product_id: productId,
        quantity: quantity
      }
    ]
  };

  // send order to backend
  fetch(`${import.meta.env.VITE_API_URL}/orders`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(order)
  })
  .then(res => res.json())
  .then(result => {
    alert("Order placed! Order ID: " + result.id);
  });
}

  return (
    <div style={{ padding: "20px" }}>
    <nav>
      <Link to="/">Products</Link> |{" "}
      <Link to="/orders">Orders</Link>
    </nav>

    <Routes>
      <Route
        path="/"
        element={
          <div>
            <h1>Product Catalog</h1>

            <ul>
              {products.map(product => (
                <li key={product.id} style={{ marginBottom: "16px" }}>
                  {product.name} - ${product.price} (Stock: {product.stock_quantity})
                  <br />

                  <input
                    type="number"
                    min="1"
                    defaultValue="1"
                    id={`qty-${product.id}`}
                    style={{ width: "60px", marginRight: "8px" }}
                  />

                  <button onClick={() => handleOrder(product.id)}>
                    Order
                  </button>
                </li>
              ))}
            </ul>
          </div>
        }
      />

      <Route path="/orders" element={<OrderHistory />} />
    </Routes>
  </div>
);  
}
