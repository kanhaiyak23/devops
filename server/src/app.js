const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Serve built frontend in production (Docker)
const clientDist = path.join(__dirname, '../../client/dist');
app.use(express.static(clientDist));

// Product data
const products = [
  { id: 1, name: 'Classic White Sneakers', price: 89.99, category: 'Footwear', description: 'Minimalist white sneakers crafted with premium leather.' },
  { id: 2, name: 'Denim Jacket', price: 129.99, category: 'Outerwear', description: 'Vintage-wash denim jacket with a modern slim fit.' },
  { id: 3, name: 'Running Performance Tee', price: 45.00, category: 'Activewear', description: 'Moisture-wicking performance tee for runners.' },
  { id: 4, name: 'Leather Crossbody Bag', price: 199.99, category: 'Accessories', description: 'Handcrafted genuine leather crossbody bag.' },
  { id: 5, name: 'Slim Fit Chinos', price: 65.00, category: 'Bottoms', description: 'Tailored slim-fit chinos in versatile khaki.' },
  { id: 6, name: 'Oversized Hoodie', price: 79.99, category: 'Outerwear', description: 'Ultra-soft fleece hoodie with relaxed fit.' },
  { id: 7, name: 'Polarized Aviator Sunglasses', price: 149.99, category: 'Accessories', description: 'Classic aviator sunglasses with polarized UV400 lenses.' },
  { id: 8, name: 'Canvas High-Top Sneakers', price: 69.99, category: 'Footwear', description: 'Retro-inspired canvas high-tops.' }
];

// Health Check Route
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'ShopSmart Backend is running',
    timestamp: new Date().toISOString()
  });
});

// Get all products
app.get('/api/products', (req, res) => {
  res.json(products);
});

// Search products
app.get('/api/products/search', (req, res) => {
  const query = (req.query.q || '').toLowerCase();
  if (!query) {
    return res.json(products);
  }
  const filtered = products.filter(p =>
    p.name.toLowerCase().includes(query) ||
    p.category.toLowerCase().includes(query)
  );
  res.json(filtered);
});

// Catch-all: serve React app for client-side routing (must be AFTER API routes)
// app.get('*', (req, res) => {
//   res.sendFile(path.join(clientDist, 'index.html'));
// });




module.exports = app;
