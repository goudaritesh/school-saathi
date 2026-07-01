const mongoose = require('mongoose');

const parentProfileSchema = mongoose.Schema(
    {
        user: {
            type: mongoose.Schema.Types.ObjectId,
            required: true,
            ref: 'User',
        },
        child_name: {
            type: String,
            required: [true, 'Please add your child\'s name'],
        },
        child_photo_url: {
            type: String,
        },
        class_info: {
            type: String,
        },
        school_name: {
            type: String,
        },
        roll_number: {
            type: String,
        },
        pickup_time: {
            type: String,
        },
        drop_time: {
            type: String,
        },
        pickup_address: {
            type: String,
        },
        drop_address: {
            type: String,
        },
        emergency_contact: {
            type: String,
        },
        connected_driver: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User', // Reference to the driver's User object
        },
        qr_code_data: {
            type: String,
            unique: true,
            sparse: true,
        }
    },
    {
        timestamps: true,
    }
);

module.exports = mongoose.model('ParentProfile', parentProfileSchema);
