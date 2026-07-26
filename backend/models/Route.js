const mongoose = require('mongoose');

const routeSchema = new mongoose.Schema({
    routeName: { type: String, required: true },
    stops: [{
        locationName: { type: String },
        time: { type: String }
    }],
    assignedVehicle: { type: mongoose.Schema.Types.ObjectId, ref: 'Vehicle' },
    assignedDriver: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    status: { type: String, enum: ['Active', 'Inactive'], default: 'Active' }
}, { timestamps: true });

module.exports = mongoose.model('Route', routeSchema);
