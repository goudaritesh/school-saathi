const Complaint = require('../models/Complaint');
const Notification = require('../models/Notification');

// @desc    Submit a new complaint
// @route   POST /api/complaints
// @access  Private (Parent)
const createComplaint = async (req, res) => {
    try {
        const { driverId, subject, description } = req.body;
        const attachmentUrl = req.file ? `/uploads/complaints/${req.file.filename}` : null;

        const complaint = new Complaint({
            parent: req.user._id,
            driver: driverId,
            subject,
            description,
            attachmentUrl
        });

        await complaint.save();

        // Notify Driver
        const notification = new Notification({
            recipient: driverId,
            title: 'New Complaint Received',
            body: `Subject: ${subject}`,
            type: 'COMPLAINT',
            data: { complaintId: complaint._id.toString() }
        });
        await notification.save();

        res.status(201).json(complaint);
    } catch (error) {
        console.error('Create complaint error:', error);
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Get complaints for logged-in user (Parent or Driver)
// @route   GET /api/complaints
// @access  Private
const getComplaints = async (req, res) => {
    try {
        const role = req.user.role;
        let query = {};
        
        if (role === 'Parent') {
            query.parent = req.user._id;
        } else if (role === 'Driver') {
            query.driver = req.user._id;
        } else {
            return res.status(403).json({ message: 'Not authorized' });
        }

        const complaints = await Complaint.find(query)
            .populate('parent', 'name phone')
            .populate('driver', 'name phone')
            .populate('responses.sender', 'name role')
            .sort({ createdAt: -1 });
            
        res.json(complaints);
    } catch (error) {
        console.error('Get complaints error:', error);
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Update complaint status
// @route   PUT /api/complaints/:id/status
// @access  Private
const updateComplaintStatus = async (req, res) => {
    try {
        const { status } = req.body; // 'open', 'in-progress', 'resolved'
        const complaintId = req.params.id;

        const complaint = await Complaint.findById(complaintId);
        if (!complaint) {
            return res.status(404).json({ message: 'Complaint not found' });
        }

        // Allow both parent and driver to update status, but usually parents mark it resolved
        complaint.status = status;
        await complaint.save();

        // Notify the other party
        const notifyTarget = req.user._id.toString() === complaint.parent.toString() 
            ? complaint.driver 
            : complaint.parent;

        const notification = new Notification({
            recipient: notifyTarget,
            title: 'Complaint Status Updated',
            body: `Complaint "${complaint.subject}" is now ${status}.`,
            type: 'COMPLAINT_STATUS',
            data: { complaintId: complaint._id.toString(), status }
        });
        await notification.save();

        res.json(complaint);
    } catch (error) {
        console.error('Update complaint status error:', error);
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Add a response to the complaint thread
// @route   POST /api/complaints/:id/respond
// @access  Private
const addComplaintResponse = async (req, res) => {
    try {
        const { message } = req.body;
        const complaintId = req.params.id;

        const complaint = await Complaint.findById(complaintId);
        if (!complaint) {
            return res.status(404).json({ message: 'Complaint not found' });
        }

        const responseData = {
            sender: req.user._id,
            message
        };

        complaint.responses.push(responseData);
        await complaint.save();

        // Re-fetch to populate sender for immediate return
        const updatedComplaint = await Complaint.findById(complaintId)
            .populate('parent', 'name phone')
            .populate('driver', 'name phone')
            .populate('responses.sender', 'name role');

        // Notify the other party
        const notifyTarget = req.user._id.toString() === complaint.parent.toString() 
            ? complaint.driver 
            : complaint.parent;

        const notification = new Notification({
            recipient: notifyTarget,
            title: 'New Response on Complaint',
            body: `${req.user.name} responded to "${complaint.subject}"`,
            type: 'COMPLAINT_REPLY',
            data: { complaintId: complaint._id.toString() }
        });
        await notification.save();

        res.json(updatedComplaint);
    } catch (error) {
        console.error('Add complaint response error:', error);
        res.status(500).json({ message: 'Server Error' });
    }
};

module.exports = {
    createComplaint,
    getComplaints,
    updateComplaintStatus,
    addComplaintResponse
};
