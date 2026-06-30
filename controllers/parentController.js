const ParentProfile = require('../models/ParentProfile');
const DriverProfile = require('../models/DriverProfile');

// @desc    Get parent dashboard stats
// @route   GET /api/parent/dashboard
// @access  Private/Parent
const getDashboardStats = async (req, res, next) => {
    try {
        const parentId = req.user._id;

        // Ensure user has a parent profile and populate connected_driver (User)
        const profile = await ParentProfile.findOne({ user: parentId }).populate('connected_driver', 'name phone');
        if (!profile) {
            res.status(404);
            throw new Error('Parent profile not found');
        }

        // Dummy data for now (until we build attendance/tracking)
        const liveStatus = {
            message: 'Van is 5 mins away',
            state: 'On the way to Pickup'
        };

        const upcomingEvents = [
            {
                id: 1,
                title: 'Exam on Friday',
                subtitle: 'Mathematics Mid-term @ 08:30',
                type: 'exam'
            },
            {
                id: 2,
                title: 'Holiday on Monday',
                subtitle: 'Independence Day celebration',
                type: 'holiday'
            }
        ];

        res.json({
            parentName: req.user.name,
            childName: profile.child_name,
            qrCodeData: profile.qr_code_data,
            driverId: profile.connected_driver ? profile.connected_driver._id : null,
            driverName: profile.connected_driver ? profile.connected_driver.name : 'Not Assigned',
            driverPhone: profile.connected_driver ? profile.connected_driver.phone : '',
            liveStatus,
            upcomingEvents,
            classInfo: 'Class 4B', // Dummy data
            pickupTime: '7:30 AM'  // Dummy data
        });

    } catch (error) {
        next(error);
    }
};

module.exports = {
    getDashboardStats,
};
