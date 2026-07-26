const express = require('express');
const router = express.Router();
const { protect, authorize } = require('../middleware/authMiddleware');
const { 
    getAttendanceReports,
    getFinancialReports,
    getPerformanceReports
} = require('../controllers/reportController');

router.use(protect);
router.use(authorize('Driver'));

router.get('/attendance', getAttendanceReports);
router.get('/financials', getFinancialReports);
router.get('/performance', getPerformanceReports);

module.exports = router;
