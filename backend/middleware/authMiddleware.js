const isAdmin = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(403).json({ message: 'No token provided' });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your_jwt_secret');
    console.log('Decoded token in middleware:', decoded); // Log decoded token

    if (decoded.isAdmin) {
      req.user = decoded;
      next();
    } else {
      res.status(403).json({ message: 'Admin access denied' });
    }
  } catch (error) {
    console.error('Token verification error:', error);
    res.status(401).json({ message: 'Invalid token' });
  }
};