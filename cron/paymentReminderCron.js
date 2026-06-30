const cron = require('node-cron');
const Payment = require('../models/Payment');
const Notification = require('../models/Notification');
const ParentProfile = require('../models/ParentProfile');
const admin = require('../config/firebase');

// Push Notification Helper
const sendPushNotification = async (fcmToken, title, body, data) => {
    if (!fcmToken) return;
    try {
        const payload = {
            notification: { title, body },
            data: data || {},
            token: fcmToken,
        };
        await admin.messaging().send(payload);
    } catch (error) {
        console.error('FCM Error in Cron:', error);
    }
};

// Automatic Payment Reminder Cron Job
// Runs every day at 9:00 AM in Production
cron.schedule('0 9 * * *', async () => {
    console.log('======================================');
    console.log('Running Payment Reminder Cron...');
    console.log('======================================');

    try {
        const today = new Date();

        // Find all unpaid payments
        const pendingPayments = await Payment.find({ status: 'Pending' })
            .populate({
                path: 'parent_profile',
                populate: { path: 'user' }
            });

        if (pendingPayments.length === 0) {
            console.log('No pending payments found.');
            return;
        }

        let reminderCount = 0;

        for (const payment of pendingPayments) {
            if (!payment.parent_profile || !payment.parent_profile.user) {
                continue;
            }
            
            const parentUser = payment.parent_profile.user;

            // Check if today's reminder already exists to avoid spamming
            const existingReminder = await Notification.findOne({
                receiverId: parentUser._id,
                type: 'Fee Reminder',
                'data.paymentId': payment._id.toString(),
                createdAt: {
                    $gte: new Date(today.getFullYear(), today.getMonth(), today.getDate())
                }
            });

            if (existingReminder) {
                continue; // Skip duplicate reminder for today
            }

            // Create notification record
            const title = 'Payment Reminder';
            const message = `Your payment of ₹${payment.amount} for ${payment.month} is pending. Please pay at your earliest convenience.`;
            const data = {
                paymentId: payment._id.toString(),
                amount: payment.amount.toString(),
                month: payment.month
            };

            await Notification.create({
                senderId: payment.driver,
                receiverId: parentUser._id,
                type: 'Fee Reminder',
                title,
                message,
                priority: 'High',
                data
            });

            // Send push notification
            if (parentUser.fcm_token) {
                await sendPushNotification(parentUser.fcm_token, title, message, data);
            }

            reminderCount++;
        }

        console.log(`${reminderCount} payment reminder(s) sent successfully.`);
    } catch (error) {
        console.error('Payment Reminder Cron Error:', error.message);
    }
});
