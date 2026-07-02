const ParentProfile = require('../models/ParentProfile');
const DriverProfile = require('../models/DriverProfile');
const Attendance = require('../models/Attendance');

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

        // Auto-generate QR code for legacy profiles that might be missing it
        if (!profile.qr_code_data) {
            profile.qr_code_data = `SVC-${parentId.toString()}`;
            await profile.save();
        }

        let liveStatus = {
            message: 'Waiting for updates',
            state: 'Inactive'
        };

        // Get latest attendance for today
        const startOfDay = new Date();
        startOfDay.setHours(0, 0, 0, 0);

        const latestAttendance = await Attendance.findOne({
            parent_profile: profile._id,
            date: { $gte: startOfDay }
        }).sort({ createdAt: -1 });

        if (latestAttendance) {
            if (latestAttendance.status === 'Picked Up') {
                liveStatus = { message: 'Van is on the way to school', state: 'Picked Up' };
            } else if (latestAttendance.status === 'Dropped Off') {
                liveStatus = { message: 'Dropped at destination', state: 'Dropped Off' };
            } else if (latestAttendance.status === 'Absent') {
                liveStatus = { message: 'Child is marked absent today', state: 'Absent' };
            }
        }

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
            classInfo: profile.class_info || '--',
            schoolName: profile.school_name || '--',
            rollNumber: profile.roll_number || '--',
            pickupTime: profile.pickup_time || '--',
            dropTime: profile.drop_time || '--',
            pickupAddress: profile.pickup_address || '--',
            dropAddress: profile.drop_address || '--',
            emergencyContact: profile.emergency_contact || '--'
        });

    } catch (error) {
        next(error);
    }
};

// @desc    Update child details
// @route   PUT /api/parent/child
// @access  Private/Parent
const updateChildDetails = async (req, res, next) => {
    try {
        const parentId = req.user._id;

        const profile = await ParentProfile.findOne({ user: parentId });
        if (!profile) {
            res.status(404);
            throw new Error('Parent profile not found');
        }

        const {
            child_name,
            class_info,
            school_name,
            roll_number,
            pickup_time,
            drop_time,
            pickup_address,
            drop_address,
            emergency_contact
        } = req.body;

        if (child_name) profile.child_name = child_name;
        if (class_info) profile.class_info = class_info;
        if (school_name) profile.school_name = school_name;
        if (roll_number) profile.roll_number = roll_number;
        if (pickup_time) profile.pickup_time = pickup_time;
        if (drop_time) profile.drop_time = drop_time;
        if (pickup_address) profile.pickup_address = pickup_address;
        if (drop_address) profile.drop_address = drop_address;
        if (emergency_contact) profile.emergency_contact = emergency_contact;

        await profile.save();

        res.json({ message: 'Child details updated successfully', profile });
    } catch (error) {
        next(error);
    }
};

module.exports = {
    getDashboardStats,
    updateChildDetails
};
