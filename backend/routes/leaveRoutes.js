const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const { 
    applyLeave, 
    updateLeaveStatus, 
    getParentLeaves, 
    getDriverLeaves 
} = require('../controllers/leaveController');

router.post('/apply', protect, applyLeave);
router.put('/:id/status', protect, updateLeaveStatus);
router.get('/parent', protect, getParentLeaves);
router.get('/driver', protect, getDriverLeaves);

module.exports = router;
