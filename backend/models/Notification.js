const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
    senderId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    receiverId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    type: {
        type: String,
        enum: [
            'Attendance',
            'Pickup',
            'Drop',
            'Fee Reminder',
            'Payment',
            'Announcement',
            'Emergency',
            'Route Change',
            'Delay',
            'Broadcast',
            'COMPLAINT',
            'COMPLAINT_STATUS',
            'COMPLAINT_REPLY',
            'LEAVE',
            'LEAVE_STATUS'
        ],
        required: true
    },
    title: {
        type: String,
        required: true
    },
    message: {
        type: String,
        required: true
    },
    isRead: {
        type: Boolean,
        default: false
    },
    readAt: {
        type: Date,
        default: null
    },
    priority: {
        type: String,
        enum: ['Low', 'Medium', 'High'],
        default: 'Medium'
    },
    data: {
        type: Object,
        default: {}
    }
}, { timestamps: true });

notificationSchema.index({ receiverId: 1, createdAt: -1 });
notificationSchema.index({ receiverId: 1, isRead: 1 });

module.exports = mongoose.model('Notification', notificationSchema);
