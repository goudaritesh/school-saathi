const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const {
    sendNotification,
    getNotifications,
    markAsRead,
    broadcastNotification
} = require('../controllers/notificationController');

const router = express.Router();

router.route('/')
    .post(protect, sendNotification)
    .get(protect, getNotifications);

router.route('/broadcast')
    .post(protect, broadcastNotification);

router.route('/:notificationId/read')
    .put(protect, markAsRead);

module.exports = router;
