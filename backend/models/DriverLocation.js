const mongoose = require('mongoose');

const driverLocationSchema = new mongoose.Schema({
    driver: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    locations: [{
        latitude: { type: Number, required: true },
        longitude: { type: Number, required: true },
        timestamp: { type: Date, default: Date.now }
    }],
    date: {
        type: Date, // Track by day
        required: true
    }
}, { timestamps: true });

// Create unique index for driver and date so we can just push to 'locations' array daily
driverLocationSchema.index({ driver: 1, date: 1 }, { unique: true });

module.exports = mongoose.model('DriverLocation', driverLocationSchema);
