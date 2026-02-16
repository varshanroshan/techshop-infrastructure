const express = require('express');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || 3000;

// URL internes Docker (nom des services = hostname)
const USER_SERVICE_URL = 'http://user-service:8001';
const PRODUCT_SERVICE_URL = 'http://product-service:8002';
const ORDER_SERVICE_URL = 'http://order-service:8003';

app.use(express.json());

// Route test
app.get('/', (req, res) => {
  res.send('TechShop API Gateway is running 🚀');
});

// 🔹 Users
app.get('/users', async (req, res) => {
  try {
    const response = await axios.get(`${USER_SERVICE_URL}/users`);
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: 'User service unavailable' });
  }
});

// 🔹 Products
app.get('/products', async (req, res) => {
  try {
    const response = await axios.get(`${PRODUCT_SERVICE_URL}/products`);
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: 'Product service unavailable' });
  }
});

// 🔹 Orders
app.get('/orders', async (req, res) => {
  try {
    const response = await axios.get(`${ORDER_SERVICE_URL}/orders`);
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: 'Order service unavailable' });
  }
});

app.listen(PORT, () => {
  console.log(`API Gateway running on port ${PORT}`);
});

