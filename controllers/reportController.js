const Attendance = require('../models/Attendance');
const Payment = require('../models/Payment');
const Complaint = require('../models/Complaint');
const Leave = require('../models/Leave');

// @desc    Get attendance reports for the logged in Driver
// @route   GET /api/reports/attendance
// @access  Private (Driver)
const getAttendanceReports = async (req, res) => {
    try {
        const driverId = req.user._id;

        const attendances = await Attendance.find({ driver: driverId })
            .populate('parent', 'name');
            
        // Calculate basic stats
        let totalPresent = 0;
        let totalAbsent = 0;

        attendances.forEach(a => {
            if (a.status === 'Present') totalPresent++;
            if (a.status === 'Absent') totalAbsent++;
        });

        res.json({
            totalRecords: attendances.length,
            totalPresent,
            totalAbsent,
            attendanceRate: attendances.length > 0 ? ((totalPresent / attendances.length) * 100).toFixed(2) : 0,
            recentLogs: attendances.slice(0, 50) // Last 50 records
        });
    } catch (error) {
        console.error('Get attendance reports error:', error);
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Get financial reports for the logged in Driver
// @route   GET /api/reports/financials
// @access  Private (Driver)
const getFinancialReports = async (req, res) => {
    try {
        const driverId = req.user._id;

        const payments = await Payment.find({ driver: driverId });
        
        let totalCollected = 0;
        let totalPending = 0;
        let totalOverdue = 0;

        const now = new Date();

        payments.forEach(p => {
            if (p.status === 'Paid') {
                totalCollected += p.amount;
            } else if (p.status === 'Pending') {
                totalPending += p.amount;
                if (new Date(p.dueDate) < now) {
                    totalOverdue += p.amount;
                }
            }
        });

        res.json({
            totalCollected,
            totalPending,
            totalOverdue,
            totalInvoices: payments.length
        });
    } catch (error) {
        console.error('Get financial reports error:', error);
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Get performance reports for the logged in Driver
// @route   GET /api/reports/performance
// @access  Private (Driver)
const getPerformanceReports = async (req, res) => {
    try {
        const driverId = req.user._id;

        const complaints = await Complaint.find({ driver: driverId });
        const leaves = await Leave.find({ driver: driverId });

        let resolvedComplaints = 0;
        complaints.forEach(c => {
            if (c.status === 'resolved') resolvedComplaints++;
        });

        let approvedLeaves = 0;
        leaves.forEach(l => {
            if (l.status === 'approved') approvedLeaves++;
        });

        res.json({
            totalComplaints: complaints.length,
            resolvedComplaints,
            complaintResolutionRate: complaints.length > 0 ? ((resolvedComplaints / complaints.length) * 100).toFixed(2) : 100,
            totalLeavesProcessed: leaves.length,
            approvedLeaves
        });
    } catch (error) {
        console.error('Get performance reports error:', error);
        res.status(500).json({ message: 'Server Error' });
    }
};

module.exports = {
    getAttendanceReports,
    getFinancialReports,
    getPerformanceReports
};
