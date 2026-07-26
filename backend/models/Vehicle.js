const mongoose = require('mongoose');

const vehicleSchema = new mongoose.Schema({
    vehicleNumber: { type: String, required: true, unique: true },
    capacity: { type: Number, required: true },
    insuranceValidUntil: { type: Date },
    pollutionValidUntil: { type: Date },
    rcNumber: { type: String },
    driver: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    status: { type: String, enum: ['Active', 'Maintenance', 'Inactive'], default: 'Active' }
}, { timestamps: true });

module.exports = mongoose.model('Vehicle', vehicleSchema);
