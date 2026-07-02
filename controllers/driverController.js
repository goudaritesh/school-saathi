const ParentProfile = require('../models/ParentProfile');
const DriverProfile = require('../models/DriverProfile');
const Attendance = require('../models/Attendance');
const Payment = require('../models/Payment');

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

        // 2. Present Count: Count of unique parents who have 'Picked Up' or 'Dropped Off' status today
        const startOfDay = new Date();
        startOfDay.setHours(0, 0, 0, 0);
        
        const presentAttendances = await Attendance.find({
            driver: driverId,
            date: { $gte: startOfDay },
            status: { $in: ['Picked Up', 'Dropped Off'] }
        }).distinct('parent_profile');
        
        const presentCount = presentAttendances.length;

        // 3. Earnings & Fees: Calculate from Payment model
        const payments = await Payment.find({ driver: driverId });
        
        let todayEarnings = 0;
        let pendingFees = 0;
        
        payments.forEach(payment => {
            if (payment.status === 'Paid') {
                // If paid today, count in todayEarnings (or you can just make it total earnings for now)
                // We'll just sum all 'Paid' as earnings to give a number, or check if paidAt is today
                if (payment.paidAt && payment.paidAt >= startOfDay) {
                    todayEarnings += payment.amount;
                }
            } else if (payment.status === 'Pending') {
                pendingFees += payment.amount;
            }
        });

        const recentActivity = [
            {
                id: 1,
                type: 'system',
                title: 'Route Update',
                subtitle: 'Your route looks clear today.',
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
        const drivers = await DriverProfile.find().populate('user', 'name phone email');
        
        // Auto-generate reference codes for legacy drivers if missing
        let modified = false;
        for (let driver of drivers) {
            if (!driver.reference_code) {
                // Generate a random 6-digit code
                driver.reference_code = Math.floor(100000 + Math.random() * 900000).toString();
                await driver.save();
                modified = true;
            }
        }
        
        // If any were modified, return the updated list (or just return the modified objects in memory)
        res.json(drivers);
    } catch (error) {
        next(error);
    }
};

// @desc    Get students connected to the driver
// @route   GET /api/driver/students
// @access  Private/Driver
const getDriverStudents = async (req, res, next) => {
    try {
        const driverId = req.user._id;

        const students = await ParentProfile.find({ connected_driver: driverId })
            .populate('user', 'name phone');
            
        res.json(students);
    } catch (error) {
        next(error);
    }
};

module.exports = {
    getDashboardStats,
    getAllDrivers,
    getDriverStudents
};
