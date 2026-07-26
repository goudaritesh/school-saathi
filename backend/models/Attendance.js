const mongoose = require('mongoose');

const attendanceSchema = new mongoose.Schema({
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
    date: {
        type: Date,
        default: Date.now,
        required: true
    },
    status: {
        type: String,
        enum: ['Picked Up', 'Dropped Off', 'Absent'],
        required: true
    },
}, { timestamps: true });

module.exports = mongoose.model('Attendance', attendanceSchema);
