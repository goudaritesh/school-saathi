const express = require('express');
const router = express.Router();
const { 
    getSystemStats, 
    getAllDrivers, 
    getAllParents,
    updateUserStatus,
    deleteUser,
    getAllStudents,
    getFeeReports,
    getAttendanceReports,
    broadcastNotification,
    getAllVehicles,
    getAllRoutes
} = require('../controllers/adminController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.use(protect);
router.use(authorize('Admin'));

// Dashboards & Lists
router.get('/stats', getSystemStats);
router.get('/drivers', getAllDrivers);
router.get('/parents', getAllParents);
router.get('/students', getAllStudents);
router.get('/vehicles', getAllVehicles);
router.get('/routes', getAllRoutes);

// User Management
router.put('/users/:id/status', updateUserStatus);
router.delete('/users/:id', deleteUser);

// Reports
router.get('/reports/fees', getFeeReports);
router.get('/reports/attendance', getAttendanceReports);

// Notifications
router.post('/notifications/broadcast', broadcastNotification);

module.exports = router;
