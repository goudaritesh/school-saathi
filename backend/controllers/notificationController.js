const Notification = require('../models/Notification');
const User = require('../models/User');
const ParentProfile = require('../models/ParentProfile');
const admin = require('../config/firebase');

// Send Notification Helper
const sendPushNotification = async (fcmToken, title, body, data) => {
    if (!fcmToken) return;
    try {
        const payload = {
            notification: {
                title,
                body,
            },
            data: data || {},
            token: fcmToken,
        };
        await admin.messaging().send(payload);
    } catch (error) {
        console.error('FCM Error:', error);
    }
};

// Send Notification
const sendNotification = async (req, res) => {
    try {
        const { receiverId, type, title, message, priority, data } = req.body;

        if (!receiverId || !type || !title || !message) {
            return res.status(400).json({ message: 'All required fields must be provided.' });
        }

        const receiver = await User.findById(receiverId);
        if (!receiver) {
            return res.status(404).json({ message: 'Receiver not found.' });
        }

        const notification = await Notification.create({
            senderId: req.user._id,
            receiverId,
            type,
            title,
            message,
            priority: priority || 'Medium',
            data: data || {}
        });

        // Send Push Notification if FCM token exists
        if (receiver.fcm_token) {
            await sendPushNotification(receiver.fcm_token, title, message, data);
        }

        res.status(201).json({ message: 'Notification sent successfully.', notification });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get Notifications
const getNotifications = async (req, res) => {
    try {
        const page = Number(req.query.page) || 1;
        const limit = Number(req.query.limit) || 10;
        const skip = (page - 1) * limit;
        const { type, priority, unread } = req.query;

        let query = { receiverId: req.user._id };

        if (type) query.type = type;
        if (priority) query.priority = priority;
        if (unread === 'true') query.isRead = false;

        const notifications = await Notification.find(query)
            .populate('senderId', 'name phone')
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit);

        const totalNotifications = await Notification.countDocuments(query);
        const unreadCount = await Notification.countDocuments({ receiverId: req.user._id, isRead: false });

        res.status(200).json({
            currentPage: page,
            totalPages: Math.ceil(totalNotifications / limit),
            totalNotifications,
            unreadCount,
            notifications
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Mark Notification as Read
const markAsRead = async (req, res) => {
    try {
        const notification = await Notification.findOne({
            _id: req.params.notificationId,
            receiverId: req.user._id
        });

        if (!notification) {
            return res.status(404).json({ message: 'Notification not found' });
        }

        if (notification.isRead) {
            return res.status(200).json({ message: 'Notification already marked as read', notification });
        }

        notification.isRead = true;
        notification.readAt = new Date();
        await notification.save();
        res.status(200).json({ message: 'Notification marked as read', notification });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Broadcast Notification (For Driver to broadcast to all connected parents)
const broadcastNotification = async (req, res) => {
    try {
        const { type, title, message, priority, data } = req.body;

        if (!type || !title || !message) {
            return res.status(400).json({ message: 'Type, title and message are required.' });
        }

        // Get all parents connected to this driver
        const parents = await ParentProfile.find({ connected_driver: req.user._id }).populate('user');

        if (parents.length === 0) {
            return res.status(404).json({ message: 'No parents found.' });
        }

        const notifications = [];
        const fcmTokens = [];

        parents.forEach(parent => {
            if (parent.user) {
                notifications.push({
                    senderId: req.user._id,
                    receiverId: parent.user._id,
                    type,
                    title,
                    message,
                    priority: priority || 'Medium',
                    data: data || {}
                });
                
                if (parent.user.fcm_token) {
                    fcmTokens.push(parent.user.fcm_token);
                }
            }
        });

        if (notifications.length > 0) {
            await Notification.insertMany(notifications);
        }

        // Send multicast FCM push notification
        if (fcmTokens.length > 0) {
            const payload = {
                notification: { title, body: message },
                data: data || {},
                tokens: fcmTokens,
            };
            try {
                await admin.messaging().sendEachForMulticast(payload);
            } catch (error) {
                console.error('Multicast FCM Error:', error);
            }
        }

        res.status(201).json({
            message: 'Broadcast notification sent successfully.',
            totalParents: notifications.length
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    sendNotification,
    getNotifications,
    markAsRead,
    broadcastNotification
};
