const express = require('express');
const router = express.Router();
const { getInvoices, createOrder, verifyPayment, getDriverEarnings, sendReminder } = require('../controllers/paymentController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.get('/invoices', protect, authorize('Parent'), getInvoices);
router.post('/create-order', protect, authorize('Parent'), createOrder);
router.post('/verify', protect, authorize('Parent'), verifyPayment);
router.get('/earnings', protect, authorize('Driver'), getDriverEarnings);
router.post('/remind/:id', protect, authorize('Driver'), sendReminder);

module.exports = router;
