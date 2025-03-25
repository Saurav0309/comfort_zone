const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const session = require('express-session');
const helmet = require('helmet');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const mysql = require('mysql2/promise');
const axios = require('axios');
require('dotenv').config();


console.log('Env vars:', {
  host: process.env.MYSQL_HOST,
  user: process.env.MYSQL_USER,
  password: process.env.MYSQL_PASSWORD ? '[hidden]' : 'none',
  database: process.env.MYSQL_DATABASE
});

const app = express();

const port = process.env.PORT || 3000;

// Database connection
const db = mysql.createPool({
  host: process.env.MYSQL_HOST || 'localhost',
  user: process.env.MYSQL_USER || 'root',
  password: process.env.MYSQL_PASSWORD || '106554',
  database: process.env.MYSQL_DATABASE || 'comfort_zone',
});

// Middleware
const corsOptions = {
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  maxAge: 3600,
};

app.use(cors(corsOptions));
app.use(bodyParser.json());
app.use(helmet());
app.use(session({
  secret: process.env.SESSION_SECRET || 'your-secret-key',
  resave: false,
  saveUninitialized: false,
  cookie: { secure: process.env.NODE_ENV === 'production' } // Set to false for HTTP
}));

// Cart functionality
let cart = [];
const khaltiSecretKey = process.env.KHALTI_SECRET_KEY || 'your_khalti_secret_key_here';
app.post('/verify-payment', async (req, res) => {
  const { idx, amount, mobile, productIdentity, token } = req.body;

  if (!token || !idx) {
    return res.status(400).json({ message: 'Token and idx are required' });
  }

  try {
    const response = await axios.post(
      'https://khalti.com/api/v2/payment/verify/',
      { token, amount },
      {
        headers: {
          'Authorization': `Key ${khaltiSecretKey}`,
          'Content-Type': 'application/json',
        },
      }
    );
    if (response.data.idx === idx) {
      // Payment verified successfully
      await db.query(
        'INSERT INTO payments (transaction_id, amount, mobile, product_identity, status) VALUES (?, ?, ?, ?, ?)',
        [idx, amount / 100, mobile, productIdentity, 'SUCCESS'] // Store amount in NPR
      );
      cart = []; // Clear cart after successful payment
      res.status(200).json({ message: 'Payment verified successfully', data: response.data });
    } else {
      throw new Error('Payment verification failed');
    }
  } catch (error) {
    console.error('Payment verification error:', error.response?.data || error.message);
    await db.query(
      'INSERT INTO payments (transaction_id, amount, mobile, product_identity, status) VALUES (?, ?, ?, ?, ?)',
      [idx, amount / 100, mobile, productIdentity, 'FAILED']
    );
    res.status(500).json({ message: 'Payment verification failed', error: error.message });
  }
});

app.post('/add-to-cart', (req, res) => {
  const item = req.body.item;
  if (!item) return res.status(400).json({ message: 'Item is required' });

  console.log("Adding item to cart:", item); // ✅ Debugging log
  cart.push(item);

  console.log("Updated cart:", cart); // ✅ Debugging log
  res.status(200).json({ message: 'Item added to cart', cart });
});
app.post('/add-to-cart', (req, res) => {
  const item = req.body.item;
  if (!item) return res.status(400).json({ message: 'Item is required' });
  cart.push(item);
  res.status(200).json({ message: 'Item added to cart', cart });
});
app.get('/cart', (req, res) => {
  console.log('Fetching cart:', cart); // ✅ Log cart data before sending response
  res.status(200).json({ cart: cart || [] });
});


app.post('/checkout', (req, res) => {
  const { paymentInfo } = req.body;
  if (!paymentInfo) return res.status(400).json({ message: 'Payment information missing' });
  cart = [];
  res.status(200).json({ message: 'Checkout successful', cart });
});

app.delete('/remove-from-cart', (req, res) => {
  const itemToRemove = req.body.item;
  if (!itemToRemove) return res.status(400).json({ message: 'Item is required' });
  
  const index = cart.findIndex(cartItem => 
    JSON.stringify(cartItem) === JSON.stringify(itemToRemove)
  );
  
  if (index === -1) return res.status(404).json({ message: 'Item not found in cart' });
  
  cart.splice(index, 1);
  res.status(200).json({ message: 'Item removed', cart });
});

// Admin middleware
const isAdmin = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(403).json({ message: 'No token provided' });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your_jwt_secret');
    if (decoded.isAdmin) {
      req.user = decoded;
      next();
    } else {
      res.status(403).json({ message: 'Admin access denied' });
    }
  } catch (error) {
    res.status(401).json({ message: 'Invalid token' });
  }
};

// Admin routes
app.post('/admin/login', async (req, res) => {
  const { email, password } = req.body;
  console.log('Admin login attempt:', email); // ✅ Log admin email

  if (!email || !password) {
    console.log('Error: Missing credentials');
    return res.status(400).json({ message: 'Email and password required' });
  }

  try {
    const [users] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
    const user = users[0];

    if (!user) {
      console.log('Error: User not found');
      return res.status(401).json({ message: 'User not found' });
    }

    const isPasswordValid = bcrypt.compareSync(password, user.password);
    console.log('Password valid:', isPasswordValid); // ✅ Log if password is valid

    if (isPasswordValid) {
      const token = jwt.sign(
        {
          id: user.id,
          email: user.email,
          isAdmin: user.isAdmin === 1,
        },
        process.env.JWT_SECRET || 'your_jwt_secret',
        { expiresIn: '1h' }
      );

      console.log('Admin login successful:', { id: user.id, email: user.email, isAdmin: user.isAdmin });

      res.json({ message: 'Login successful', token });
    } else {
      console.log('Error: Invalid credentials');
      res.status(401).json({ message: 'Invalid credentials' });
    }
  } catch (error) {
    console.error('Server error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});
app.post('/verify-payment', async (req, res) => {
  const { transaction_id, amount, mobile, productIdentity } = req.body;
  const khaltiSecretKey = process.env.KHALTI_SECRET_KEY || 'your_khalti_secret_key_here';

  try {
    const response = await axios.post(
      'https://web.khalti.com/#//',
      { token: transaction_id, amount }, // Khalti expects a token, use transaction_id here
      {
        headers: {
          'Authorization': `Key ${khaltiSecretKey}`,
          'Content-Type': 'application/json',
        },
      }
    );

    if (response.data.idx === transaction_id) {
      await db.query(
        'INSERT INTO payments (user_id, transaction_id, amount, mobile, product_identity, status) VALUES (?, ?, ?, ?, ?, ?)',
        [req.user?.id || null, transaction_id, amount / 100, mobile, productIdentity, 'SUCCESS']
      );
      cart = [];
      res.status(200).json({ message: 'Payment verified successfully', data: response.data });
    } else {
      throw new Error('Payment verification failed');
    }
  } catch (error) {
    console.error('Payment verification error:', error.response?.data || error.message);
    await db.query(
      'INSERT INTO payments (user_id, transaction_id, amount, mobile, product_identity, status) VALUES (?, ?, ?, ?, ?, ?)',
      [req.user?.id || null, transaction_id, amount / 100, mobile, productIdentity, 'FAILED']
    );
    res.status(500).json({ message: 'Payment verification failed', error: error.message });
  }
});

app.get('/admin/dashboard', isAdmin, async (req, res) => {
  try {
    const [admins] = await db.query('SELECT id, email, isAdmin FROM users WHERE id = ?', [req.user.id]);

    if (!admins.length) {
      return res.status(404).json({ message: 'Admin not found' });
    }

    res.json({ 
      message: 'Welcome to the Admin Dashboard', 
      admin: admins[0] // Send full admin details
    });
  } catch (error) {
    console.error('Error fetching admin data:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});
app.post('/register', async (req, res) => {
  const { name, email, password } = req.body;
  
  if (!name || !email || !password) {
      return res.status(400).json({ message: "All fields are required" });
  }

  try {
      const hashedPassword = await bcrypt.hash(password, 10); // Hash password

      await db.execute("INSERT INTO users (name, email, password, isAdmin) VALUES (?, ?, ?, 0)", 
                 [name, email, hashedPassword]);


      res.status(201).json({ message: "User registered successfully" });

  } catch (error) {
      res.status(500).json({ message: "Registration failed", error });
  }
});
app.get('/api/users', async (req, res) => {
  try {
      const [users] = await db.execute("SELECT id, name, email, isAdmin FROM users");
      res.json(users);
  } catch (error) {
      res.status(500).json({ message: "Error fetching users", error });
  }
});
app.get('/admin/users', isAdmin, async (req, res) => {
  try {
    const [users] = await db.query('SELECT id, name, email, isAdmin FROM users'); // Add 'name'
    res.json(users);
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ message: 'Server error' });
  }
});


app.delete('/admin/users/:id', isAdmin, async (req, res) => {
  try {
    const userId = req.params.id;
    await db.query('DELETE FROM users WHERE id = ?', [userId]);
    res.json({ message: 'User deleted successfully' });
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({ message: 'Error deleting user', error: error.message });
  }
});

app.put('/admin/users/:id/promote', isAdmin, async (req, res) => {
  try {
    const userId = req.params.id;
    await db.query('UPDATE users SET isAdmin = 1 WHERE id = ?', [userId]); // ✅ 1 for admin
    const [updatedUsers] = await db.query('SELECT * FROM users WHERE id = ?', [userId]);
    res.json({ message: 'User promoted to admin', user: updatedUsers[0] });
  } catch (error) {
    console.error('Error promoting user:', error);
    res.status(500).json({ message: 'Error promoting user', error: error.message });
  }
});

app.listen(port, async () => {
  try {
    await db.query('SELECT 1'); // Test connection
    console.log('Connected to MySQL');
    console.log(`Server running at http://localhost:${port}`);
  } catch (err) {
    console.error('MySQL connection error:', err);
  }
});
