const User = require('../models/User');
const DriverProfile = require('../models/DriverProfile');
const ParentProfile = require('../models/ParentProfile');
const Payment = require('../models/Payment');
const Attendance = require('../models/Attendance');
const Notification = require('../models/Notification');
const Vehicle = require('../models/Vehicle');
const Route = require('../models/Route');
const Complaint = require('../models/Complaint');
const Leave = require('../models/Leave');

// @desc    Get system stats for Admin Dashboard
// @route   GET /api/admin/stats
// @access  Private/Admin
const getSystemStats = async (req, res, next) => {
    try {
        const totalUsers = await User.countDocuments();
        const totalDrivers = await User.countDocuments({ role: 'Driver' });
        const totalParents = await User.countDocuments({ role: 'Parent' });
        const parents = await ParentProfile.find();
        let totalStudents = parents.length; // Each ParentProfile represents 1 child in this schema

        const activeVans = await Vehicle.countDocuments({ status: 'Active' });

        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const todayAttendance = await Attendance.find({ date: { $gte: today } });
        const todayPickup = todayAttendance.filter(a => a.status === 'Present').length;
        const todayDrop = todayAttendance.filter(a => a.droppedOffTime).length;

        const payments = await Payment.find();
        const totalRevenue = payments.filter(p => p.status === 'Paid').reduce((sum, payment) => sum + payment.amount, 0);
        const pendingFees = payments.filter(p => p.status === 'Pending').reduce((sum, payment) => sum + payment.amount, 0);

        const complaints = await Complaint.countDocuments({ status: 'Pending' });
        const leaveRequests = await Leave.countDocuments({ status: 'Pending' });

        res.json({
            totalUsers,
            totalDrivers,
            totalParents,
            totalStudents,
            activeVans,
            todayPickup,
            todayDrop,
            pendingFees,
            totalRevenue,
            complaints,
            leaveRequests
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get all drivers
// @route   GET /api/admin/drivers
// @access  Private/Admin
const getAllDrivers = async (req, res, next) => {
    try {
        const drivers = await DriverProfile.find().populate('user', 'name email phone isActive');
        res.json(drivers);
    } catch (error) {
        next(error);
    }
};

// @desc    Get all parents
// @route   GET /api/admin/parents
// @access  Private/Admin
const getAllParents = async (req, res, next) => {
    try {
        const parents = await ParentProfile.find()
            .populate('user', 'name email phone isActive')
            .populate('connected_driver', 'name');
        res.json(parents);
    } catch (error) {
        next(error);
    }
};

// @desc    Update user status (Suspend/Activate)
// @route   PUT /api/admin/users/:id/status
// @access  Private/Admin
const updateUserStatus = async (req, res, next) => {
    try {
        const { isActive } = req.body;
        const user = await User.findById(req.params.id);
        
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        user.isActive = isActive;
        await user.save();

        res.json({ message: `User ${isActive ? 'activated' : 'suspended'} successfully`, user });
    } catch (error) {
        next(error);
    }
};

// @desc    Delete user and associated profile
// @route   DELETE /api/admin/users/:id
// @access  Private/Admin
const deleteUser = async (req, res, next) => {
    try {
        const user = await User.findById(req.params.id);
        
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        if (user.role === 'Driver') {
            await DriverProfile.findOneAndDelete({ user: user._id });
        } else if (user.role === 'Parent') {
            await ParentProfile.findOneAndDelete({ user: user._id });
        }

        await User.findByIdAndDelete(req.params.id);
        res.json({ message: 'User and profile deleted successfully' });
    } catch (error) {
        next(error);
    }
};

// @desc    Get all students (Aggregated from Parent profiles)
// @route   GET /api/admin/students
// @access  Private/Admin
const getAllStudents = async (req, res, next) => {
    try {
        const parents = await ParentProfile.find()
            .populate('user', 'name')
            .populate('connected_driver', 'name');
            
        let students = [];
        
        parents.forEach(parent => {
            students.push({
                studentId: parent._id,
                name: parent.child_name,
                class: parent.class_info,
                parentName: parent.user ? parent.user.name : 'Unknown',
                driverName: parent.connected_driver ? parent.connected_driver.name : 'Unassigned',
                address: parent.pickup_address || parent.drop_address || 'N/A'
            });
        });

        res.json(students);
    } catch (error) {
        next(error);
    }
};

// @desc    Get global fee reports
// @route   GET /api/admin/reports/fees
// @access  Private/Admin
const getFeeReports = async (req, res, next) => {
    try {
        const payments = await Payment.find()
            .populate({
                path: 'parent_profile',
                populate: { path: 'user', select: 'name' }
            })
            .populate('driver', 'name')
            .sort({ createdAt: -1 });
            
        res.json(payments);
    } catch (error) {
        next(error);
    }
};

// @desc    Get global attendance reports
// @route   GET /api/admin/reports/attendance
// @access  Private/Admin
const getAttendanceReports = async (req, res, next) => {
    try {
        const attendance = await Attendance.find()
            .populate('driver', 'name')
            .populate({
                path: 'parent_profile',
                populate: { path: 'user', select: 'name' }
            })
            .sort({ date: -1 });
            
        res.json(attendance);
    } catch (error) {
        next(error);
    }
};

// @desc    Broadcast a notification to users
// @route   POST /api/admin/notifications/broadcast
// @access  Private/Admin
const broadcastNotification = async (req, res, next) => {
    try {
        const { targetRole, title, body } = req.body; // targetRole: 'Parent', 'Driver', 'All'
        
        let query = {};
        if (targetRole === 'Parent' || targetRole === 'Driver') {
            query.role = targetRole;
        }

        const users = await User.find(query).select('_id');
        
        const notifications = users.map(user => ({
            recipient: user._id,
            title,
            body,
            type: 'SYSTEM_BROADCAST'
        }));

        await Notification.insertMany(notifications);

        res.json({ message: `Broadcast sent to ${users.length} users.` });
    } catch (error) {
        next(error);
    }
};
// @desc    Get all vehicles
// @route   GET /api/admin/vehicles
// @access  Private/Admin
const getAllVehicles = async (req, res, next) => {
    try {
        const vehicles = await Vehicle.find().populate('driver', 'name');
        res.json(vehicles);
    } catch (error) {
        next(error);
    }
};

// @desc    Get all routes
// @route   GET /api/admin/routes
// @access  Private/Admin
const getAllRoutes = async (req, res, next) => {
    try {
        const routes = await Route.find()
            .populate('assignedVehicle', 'vehicleNumber')
            .populate('assignedDriver', 'name');
        res.json(routes);
    } catch (error) {
        next(error);
    }
};

// @desc    Get all complaints
// @route   GET /api/admin/complaints
// @access  Private/Admin
const getAllComplaints = async (req, res, next) => {
    try {
        const complaints = await Complaint.find()
            .populate('parent', 'name email role')
            .populate('driver', 'name email role')
            .sort({ createdAt: -1 });
        res.json(complaints);
    } catch (error) {
        next(error);
    }
};

// @desc    Get all leave requests
// @route   GET /api/admin/leaves
// @access  Private/Admin
const getAllLeaves = async (req, res, next) => {
    try {
        const leaves = await Leave.find()
            .populate('parent', 'name email role')
            .populate('driver', 'name email role')
            .sort({ createdAt: -1 });
        res.json(leaves);
    } catch (error) {
        next(error);
    }
};

module.exports = {
    getSystemStats,
    getAllDrivers,
    getAllParents,
    updateUserStatus,
    deleteUser,
    getAllStudents,
    getFeeReports,
    getAttendanceReports,
    broadcastNotification,
    getAllVehicles,
    getAllRoutes,
    getAllComplaints,
    getAllLeaves
};
