const express = require('express');
const router = express.Router();
const { getDashboardStats, updateChildDetails } = require('../controllers/parentController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.get('/dashboard', protect, authorize('Parent'), getDashboardStats);
router.put('/child', protect, authorize('Parent'), updateChildDetails);

module.exports = router;
