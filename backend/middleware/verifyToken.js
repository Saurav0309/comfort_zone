// Middleware to verify JWT token (e.g., in verifyToken.js)
const jwt = require('jsonwebtoken');

function verifyToken(req, res, next) {
  const token = req.header("Authorization")?.split(" ")[1];
  if (!token) return res.status(403).json({ message: "Access denied" });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; // Decoded payload is available here
    next();
  } catch (err) {
    res.status(401).json({ message: "Invalid Token" });
  }
}

module.exports = verifyToken;