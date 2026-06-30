const ParentProfile = require('../models/ParentProfile');
const DriverProfile = require('../models/DriverProfile');

// @desc    Get driver dashboard stats
// @route   GET /api/driver/dashboard
// @access  Private/Driver
const getDashboardStats = async (req, res, next) => {
    try {
        const driverId = req.user._id;

        // Ensure user has a driver profile
        const profile = await DriverProfile.findOne({ user: driverId });
        if (!profile) {
            res.status(404);
            throw new Error('Driver profile not found');
        }

        // 1. Total Students: Count of ParentProfiles connected to this driver
        const totalStudents = await ParentProfile.countDocuments({ connected_driver: driverId });

        // Dummy data for now for the other stats (until we build attendance/payments)
        const presentCount = Math.max(0, totalStudents - 2); // Just for demo
        const todayEarnings = 80;
        const pendingFees = 150;

        const recentActivity = [
            {
                id: 1,
                type: 'attendance',
                title: 'Attendance marked for John Doe',
                subtitle: 'Picked up at Maple Street • 07:42 AM',
            },
            {
                id: 2,
                type: 'payment',
                title: 'Fee collected from Sarah Smith',
                subtitle: 'Monthly subscription • $150.00',
            },
            {
                id: 3,
                type: 'system',
                title: 'Route Update',
                subtitle: 'Road closure on 5th Ave, route optimized.',
            }
        ];

        res.json({
            driverName: req.user.name,
            totalStudents,
            presentCount,
            todayEarnings,
            pendingFees,
            recentActivity,
            referenceCode: profile.reference_code,
        });

    } catch (error) {
        next(error);
    }
};

// @desc    Get all drivers
// @route   GET /api/driver/all
// @access  Private (Parent)
const getAllDrivers = async (req, res, next) => {
    try {
        const drivers = await DriverProfile.find().populate('user', 'name phone email driverCode');
        res.json(drivers);
    } catch (error) {
        next(error);
    }
};

module.exports = {
    getDashboardStats,
    getAllDrivers,
};
