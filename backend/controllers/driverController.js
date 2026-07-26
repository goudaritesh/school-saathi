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
        const driversData = await DriverProfile.find().populate({
            path: 'user',
            select: 'name phone email isActive',
            match: { isActive: true }
        });
        
        // Filter out profiles where user is null (i.e., not active or deleted) or driver is not verified
        const drivers = driversData.filter(driver => driver.user != null && driver.is_verified === true);
        
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

        const studentsData = await ParentProfile.find({ connected_driver: driverId })
            .populate('user', 'name phone').lean();
            
        // Fetch today's attendance for these students
        const startOfDay = new Date();
        startOfDay.setHours(0, 0, 0, 0);
        
        const attendances = await Attendance.find({
            driver: driverId,
            date: { $gte: startOfDay }
        }).sort({ createdAt: -1 }); // Get latest first
        
        // Map attendance to students
        const students = studentsData.map(student => {
            const studentAttendance = attendances.find(a => {
                const aId = (a.parent_profile && a.parent_profile._id) ? a.parent_profile._id.toString() : a.parent_profile?.toString();
                return aId === student._id.toString();
            });
            return {
                ...student,
                today_attendance: studentAttendance ? studentAttendance.status : 'Pending'
            };
        });

        res.json(students);
    } catch (error) {
        next(error);
    }
};

// @desc    Get attendance history for a specific student
// @route   GET /api/driver/student/:id/attendance
// @access  Private/Driver
const getStudentAttendanceHistory = async (req, res, next) => {
    try {
        const driverId = req.user._id;
        const studentId = req.params.id; // parent_profile_id

        const history = await Attendance.find({
            driver: driverId,
            parent_profile: studentId
        })
        .sort({ date: -1, createdAt: -1 })
        .limit(30)
        .lean();

        res.json(history);
    } catch (error) {
        next(error);
    }
};

// @desc    Update Driver Profile (Personal and Van details)
// @route   PUT /api/driver/profile
// @access  Private/Driver
const updateDriverProfile = async (req, res, next) => {
    try {
        const userId = req.user._id;
        const { name, phone, vehicle_no, route_name, total_seats, vehicle_model, vehicle_color } = req.body;

        // Update User Model (name, phone)
        const user = await req.user.constructor.findById(userId);
        if (user) {
            user.name = name || user.name;
            user.phone = phone || user.phone;
            await user.save();
        }

        // Update DriverProfile Model
        const profile = await DriverProfile.findOne({ user: userId });
        if (!profile) {
            res.status(404);
            throw new Error('Driver profile not found');
        }

        profile.vehicle_no = vehicle_no || profile.vehicle_no;
        profile.route_name = route_name || profile.route_name;
        profile.vehicle_model = vehicle_model || profile.vehicle_model;
        profile.vehicle_color = vehicle_color || profile.vehicle_color;
        
        if (total_seats !== undefined) {
            const oldTotal = profile.total_seats || 0;
            const difference = Number(total_seats) - oldTotal;
            profile.total_seats = Number(total_seats);
            profile.available_seats = (profile.available_seats || 0) + difference;
            
            // Ensure available_seats doesn't go below 0 if they decrease total seats too much
            if (profile.available_seats < 0) profile.available_seats = 0;
        }

        await profile.save();

        res.json({
            message: 'Profile updated successfully',
            user: {
                name: user.name,
                phone: user.phone,
            },
            profile: {
                vehicle_no: profile.vehicle_no,
                route_name: profile.route_name,
                vehicle_model: profile.vehicle_model,
                vehicle_color: profile.vehicle_color,
                total_seats: profile.total_seats,
                available_seats: profile.available_seats
            }
        });
    } catch (error) {
        next(error);
    }
};

module.exports = {
    getDashboardStats,
    getAllDrivers,
    getDriverStudents,
    getStudentAttendanceHistory,
    updateDriverProfile
};
