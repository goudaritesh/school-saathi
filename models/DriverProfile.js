const mongoose = require('mongoose');

const driverProfileSchema = mongoose.Schema(
    {
        user: {
            type: mongoose.Schema.Types.ObjectId,
            required: true,
            ref: 'User',
        },
        vehicle_no: {
            type: String,
            required: [true, 'Please add a vehicle plate number'],
            uppercase: true,
        },
        license_no: {
            type: String,
            required: [true, 'Please add a driving license number'],
        },
        vehicle_photo_url: {
            type: String,
        },
        license_document_url: {
            type: String,
        },
        reference_code: {
            type: String,
            unique: true,
        },
        is_verified: {
            type: Boolean,
            default: false,
        }
    },
    {
        timestamps: true,
    }
);

module.exports = mongoose.model('DriverProfile', driverProfileSchema);
