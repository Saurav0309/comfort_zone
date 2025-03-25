const User = require('../models/user'); // Import the User model

// Admin Dashboard
exports.getDashboard = (req, res) => {
  res.json({ message: 'Welcome to the Admin Dashboard' });
};

// Get All Users
exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.find(); // Fetch all users from the database
    res.json(users);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching users', error });
  }
};

// Delete a User
exports.deleteUser = async (req, res) => {
  try {
    const userId = req.params.id;
    await User.findByIdAndDelete(userId); // Delete the user by ID
    res.json({ message: 'User deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting user', error });
  }
};

// Promote a User to Admin
exports.promoteToAdmin = async (req, res) => {
  try {
    const userId = req.params.id;
    const user = await User.findByIdAndUpdate(
      userId,
      { isAdmin: true },
      { new: true }
    ); // Update the user's isAdmin field
    res.json({ message: 'User promoted to admin', user });
  } catch (error) {
    res.status(500).json({ message: 'Error promoting user', error });
  }
};