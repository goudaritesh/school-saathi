const Leave = require('../models/Leave');
const User = require('../models/User');
const Notification = require('../models/Notification');
const { getIO } = require('../socket/socketServer');

// @desc    Parent applies for leave
// @route   POST /api/leave/apply
// @access  Private (Parent)
const applyLeave = async (req, res) => {
    try {
        const { driverId, studentName, startDate, endDate, reason } = req.body;
        const parentId = req.user._id;

        const leave = new Leave({
            parent: parentId,
            driver: driverId,
            studentName,
            startDate,
            endDate,
            reason
        });

        await leave.save();

        // Notify Driver
        const notification = new Notification({
            recipient: driverId,
            title: 'New Leave Request',
            body: `Leave request for ${studentName} from ${new Date(startDate).toLocaleDateString()} to ${new Date(endDate).toLocaleDateString()}`,
            type: 'LEAVE',
            data: { leaveId: leave._id.toString() }
        });
        await notification.save();

        res.status(201).json(leave);
    } catch (error) {
        console.error('Apply leave error:', error);
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Driver updates leave status (approve/reject)
// @route   PUT /api/leave/:id/status
// @access  Private (Driver)
const updateLeaveStatus = async (req, res) => {
    try {
        const { status } = req.body; // 'approved' or 'rejected'
        const leaveId = req.params.id;

        const leave = await Leave.findById(leaveId).populate('parent');
        if (!leave) {
            return res.status(404).json({ message: 'Leave request not found' });
        }

        // Ensure driver owns this request
        if (leave.driver.toString() !== req.user._id.toString()) {
            return res.status(403).json({ message: 'Not authorized' });
        }

        leave.status = status;
        await leave.save();

        // Notify Parent
        const notification = new Notification({
            recipient: leave.parent._id,
            title: `Leave ${status.charAt(0).toUpperCase() + status.slice(1)}`,
            body: `Your leave request for ${leave.studentName} has been ${status}.`,
            type: 'LEAVE_STATUS',
            data: { leaveId: leave._id.toString(), status }
        });
        await notification.save();

        res.json(leave);
    } catch (error) {
        console.error('Update leave status error:', error);
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Get all leave requests for logged in Parent
// @route   GET /api/leave/parent
// @access  Private (Parent)
const getParentLeaves = async (req, res) => {
    try {
        const leaves = await Leave.find({ parent: req.user._id })
            .populate('driver', 'name phone')
            .sort({ createdAt: -1 });
        res.json(leaves);
    } catch (error) {
        console.error('Get parent leaves error:', error);
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Get all incoming leave requests for logged in Driver
// @route   GET /api/leave/driver
// @access  Private (Driver)
const getDriverLeaves = async (req, res) => {
    try {
        const leaves = await Leave.find({ driver: req.user._id })
            .populate('parent', 'name phone')
            .sort({ createdAt: -1 });
        res.json(leaves);
    } catch (error) {
        console.error('Get driver leaves error:', error);
        res.status(500).json({ message: 'Server Error' });
    }
};

module.exports = {
    applyLeave,
    updateLeaveStatus,
    getParentLeaves,
    getDriverLeaves
};
