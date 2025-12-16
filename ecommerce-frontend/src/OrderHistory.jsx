import { useState, useEffect } from "react";

export default function OrderHistory() {
  const [orders, setOrders] = useState([]);
  const [products, setProducts] = useState([]);

  useEffect(() => {
    // Load orders
    fetch(`${import.meta.env.VITE_API_URL}/orders`)
      .then(res => res.json())
      .then(data => setOrders(data));

    // Load products
    fetch(`${import.meta.env.VITE_API_URL}/products`)
      .then(res => res.json())
      .then(data => setProducts(data));
  }, []);

  function getProductName(productId) {
    const p = products.find(p => p.id === productId);
    return p ? p.name : "Unknown product";
  }

  return (
    <div style={{ padding: "20px" }}>
      <h1>Order History</h1>

      {orders.map(order => (
        <div key={order.id} style={{ marginBottom: "20px" }}>
          <strong>Order #{order.id}</strong><br />

          {order.order_date && (
            <div>
              Date: {new Date(order.order_date).toLocaleDateString()}
            </div>
          )}

          Status: {order.status}<br />
          Total: ${order.total_price}<br />

          <ul>
            {order.items.map(item => (
              <li key={item.product_id}>
                {getProductName(item.product_id)} × {item.quantity}
                (at ${item.price_at_purchase})
              </li>
            ))}
          </ul>
        </div>
      ))}
    </div>
  );
}
