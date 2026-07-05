const User = require('../models/User');
const ConnectionRequest = require('../models/ConnectionRequest');
const ParentProfile = require('../models/ParentProfile');
const DriverProfile = require('../models/DriverProfile');

// Parent sends request to a driver using driver code
const sendRequest = async (req, res) => {
    try {
        const { driverCode, routeAddress, schoolTiming } = req.body;
        const parentId = req.user._id;

        if (!driverCode || !routeAddress || !schoolTiming) {
            return res.status(400).json({ message: "Driver Code, Route Address, and School Timing Required" });
        }

        const driverProfile = await DriverProfile.findOne({ reference_code: driverCode });

        if (!driverProfile) {
            return res.status(404).json({ message: "Driver Not Found" });
        }

        const existingRequest = await ConnectionRequest.findOne({
            parentId,
            driverId: driverProfile.user,
            status: "pending"
        });

        if (existingRequest) {
            return res.status(400).json({ message: "Request Already Sent" });
        }

        await ConnectionRequest.create({
            parentId,
            driverId: driverProfile.user,
            routeAddress,
            schoolTiming
        });

        res.status(201).json({ message: "Connection Request Sent" });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Driver gets pending requests
const getPendingRequests = async (req, res) => {
    try {
        const requests = await ConnectionRequest.find({
            driverId: req.user._id,
            status: "pending"
        }).populate("parentId", "name phone");

        res.status(200).json(requests);

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Driver accepts request
const acceptRequest = async (req, res) => {
    try {
        const request = await ConnectionRequest.findById(req.params.requestId);

        if (!request) {
            return res.status(404).json({ message: "Request Not Found" });
        }

        const { fees } = req.body;

        request.status = "accepted";
        request.fees = fees || '';
        await request.save();

        // Update the connected_driver field in ParentProfile instead of User
        const updatedParent = await ParentProfile.findOneAndUpdate(
            { user: request.parentId },
            { connected_driver: request.driverId },
            { new: true }
        );

        if (!updatedParent) {
            console.log("Warning: Parent Profile not found for this parent ID.");
        } else {
            console.log("Updated Parent Profile:", updatedParent);
        }

        // Decrement available seats for the driver
        await DriverProfile.findOneAndUpdate(
            { user: request.driverId },
            { $inc: { available_seats: -1 } }
        );

        res.status(200).json({ message: "Request Accepted" });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: error.message });
    }
};

// Driver rejects request
const rejectRequest = async (req, res) => {
    try {
        const request = await ConnectionRequest.findById(req.params.requestId);

        if (!request) {
            return res.status(404).json({ message: "Request Not Found" });
        }

        const { reason } = req.body;

        if (!reason) {
            return res.status(400).json({ message: "Rejection reason is required" });
        }

        request.status = "rejected";
        request.rejectionReason = reason;

        await request.save();

        res.status(200).json({
            message: "Request Rejected Successfully",
            rejectionReason: reason
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Parent views their connection request status
const myRequest = async (req, res) => {
    try {
        const request = await ConnectionRequest.findOne({
            parentId: req.user._id
        }).populate("driverId", "name phone driverCode");

        if (!request) {
            return res.status(404).json({ message: "No Request Found" });
        }
        res.status(200).json(request);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Disconnect user (Parent or Driver)
const disconnectUser = async (req, res) => {
    try {
        const { targetUserId } = req.body;
        
        let query = {
            $or: [{ parentId: req.user._id }, { driverId: req.user._id }],
            status: "accepted"
        };

        if (targetUserId) {
            query = {
                $or: [
                    { parentId: req.user._id, driverId: targetUserId },
                    { driverId: req.user._id, parentId: targetUserId }
                ],
                status: "accepted"
            };
        }

        // Find an accepted request involving this user (and optionally targetUserId)
        const request = await ConnectionRequest.findOne(query);

        if (!request) {
            return res.status(404).json({ message: "No active connection found" });
        }

        request.status = "disconnected";
        await request.save();

        // Clear connected_driver in ParentProfile
        await ParentProfile.findOneAndUpdate(
            { user: request.parentId },
            { connected_driver: null }
        );

        // Increment available seats for Driver
        await DriverProfile.findOneAndUpdate(
            { user: request.driverId },
            { $inc: { available_seats: 1 } }
        );

        res.status(200).json({ message: "Disconnected successfully" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    sendRequest,
    getPendingRequests,
    acceptRequest,
    rejectRequest,
    myRequest,
    disconnectUser
};
