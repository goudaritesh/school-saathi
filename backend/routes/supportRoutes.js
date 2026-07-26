const express = require('express');
const router = express.Router();
const { 
    createTicket, 
    getAllTickets, 
    resolveTicket 
} = require('../controllers/supportController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.use(protect);

// Users can create tickets
router.post('/', createTicket);

// Admin routes
router.get('/', authorize('Admin'), getAllTickets);
router.put('/:id/resolve', authorize('Admin'), resolveTicket);

module.exports = router;
