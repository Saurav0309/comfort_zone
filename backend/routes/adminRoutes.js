const express = require("express");
const router = express.Router();
const { isAdmin } = require("../middleware/authMiddleware");
const verifyToken = require("../middleware/verifyToken"); // Import the JWT verification middleware
const User = require("../models/user");

// Admin Dashboard
router.get("/dashboard", verifyToken, isAdmin, (req, res) => {
  res.render("admin/dashboard");
});

// List all users
router.get("/users", verifyToken, isAdmin, async (req, res) => {
  try {
    const users = await User.find();
    res.render("admin/users", { users });
  } catch (error) {
    res.status(500).send("Error fetching users");
  }
});

// Delete a user
router.post("/users/delete/:id", verifyToken, isAdmin, async (req, res) => {
  try {
    await User.findByIdAndDelete(req.params.id);
    res.redirect("/admin/users");
  } catch (error) {
    res.status(500).send("Error deleting user");
  }
});

module.exports = router;
