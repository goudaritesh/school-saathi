const Attendance = require('../models/Attendance');
const ParentProfile = require('../models/ParentProfile');
const User = require('../models/User');
const { sendPushNotification } = require('../utils/firebase');

// @desc    Mark attendance via QR scan
// @route   POST /api/attendance/mark
// @access  Private/Driver
const markAttendance = async (req, res, next) => {
    try {
        const { qr_code_data, status } = req.body;
        const driverId = req.user._id;

        if (!qr_code_data || !status) {
            res.status(400);
            throw new Error('Please provide qr_code_data and status');
        }

        // Find the student by QR code
        const studentProfile = await ParentProfile.findOne({ qr_code_data }).populate('user');
        
        if (!studentProfile) {
            res.status(404);
            throw new Error('Invalid QR Code. Student not found.');
        }

        // Create attendance record
        const attendance = await Attendance.create({
            parent_profile: studentProfile._id,
            driver: driverId,
            status,
        });

        // Send Push Notification to Parent
        if (studentProfile.user && studentProfile.user.fcm_token) {
            const title = `Attendance Update: ${studentProfile.child_name}`;
            const body = `Your child has been marked as ${status} by the driver.`;
            await sendPushNotification(studentProfile.user.fcm_token, title, body);
        }

        res.status(201).json({
            message: `Attendance marked as ${status} for ${studentProfile.child_name}`,
            attendance
        });
    } catch (error) {
        next(error);
    }
};

module.exports = {
    markAttendance,
};
