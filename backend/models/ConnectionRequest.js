const mongoose = require('mongoose');
const { Schema } = mongoose;

const connectionRequestSchema = new Schema({
    parentId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    driverId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    status: { type: String, enum: ['pending', 'accepted', 'rejected', 'disconnected'], default: 'pending' },
    routeAddress: { type: String, required: true },
    schoolTiming: { type: String, required: true },
    fees: { type: String, default: '' },
    rejectionReason: {
        type: String,
        default: ""
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('ConnectionRequest', connectionRequestSchema);
