const express = require('express');
const router = express.Router();
const { getDashboardStats, getAllDrivers } = require('../controllers/driverController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.get('/dashboard', protect, authorize('Driver'), getDashboardStats);
router.get('/all', protect, authorize('Parent'), getAllDrivers);

module.exports = router;
