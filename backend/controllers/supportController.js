const SupportTicket = require('../models/SupportTicket');

// @desc    Create a new support ticket
// @route   POST /api/support
// @access  Private (Parent/Driver)
const createTicket = async (req, res, next) => {
    try {
        const { subject, message } = req.body;
        
        const ticket = await SupportTicket.create({
            user: req.user._id,
            subject,
            message
        });

        res.status(201).json({ message: 'Support ticket created successfully', ticket });
    } catch (error) {
        next(error);
    }
};

// @desc    Get all support tickets
// @route   GET /api/support
// @access  Private/Admin
const getAllTickets = async (req, res, next) => {
    try {
        const tickets = await SupportTicket.find()
            .populate('user', 'name email role')
            .sort({ createdAt: -1 });
            
        res.json(tickets);
    } catch (error) {
        next(error);
    }
};

// @desc    Resolve a support ticket
// @route   PUT /api/support/:id/resolve
// @access  Private/Admin
const resolveTicket = async (req, res, next) => {
    try {
        const { adminResponse } = req.body;
        
        const ticket = await SupportTicket.findById(req.params.id);
        
        if (!ticket) {
            return res.status(404).json({ message: 'Ticket not found' });
        }

        ticket.status = 'Resolved';
        if (adminResponse) {
            ticket.adminResponse = adminResponse;
        }
        
        await ticket.save();

        res.json({ message: 'Ticket resolved successfully', ticket });
    } catch (error) {
        next(error);
    }
};

module.exports = {
    createTicket,
    getAllTickets,
    resolveTicket
};
