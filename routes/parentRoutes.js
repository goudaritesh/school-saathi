const express = require('express');
const router = express.Router();
const { getDashboardStats } = require('../controllers/parentController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.get('/dashboard', protect, authorize('Parent'), getDashboardStats);

module.exports = router;
