const mongoose = require('mongoose');

const paymentSchema = new mongoose.Schema({
    parent_profile: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'ParentProfile',
        required: true
    },
    driver: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    amount: {
        type: Number,
        required: true
    },
    month: {
        type: String, // e.g., 'October 2026'
        required: true
    },
    status: {
        type: String,
        enum: ['Pending', 'Paid'],
        default: 'Pending'
    },
    transaction_id: {
        type: String,
        sparse: true
    }
}, { timestamps: true });

module.exports = mongoose.model('Payment', paymentSchema);
