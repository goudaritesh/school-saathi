const DriverLocation = require('../models/DriverLocation');

// Save or Update Location
const saveLocation = async (req, res) => {
    try {
        const { latitude, longitude } = req.body;

        if (!latitude || !longitude) {
            return res.status(400).json({ message: 'Latitude and longitude are required' });
        }

        // Use today's date rounded to midnight for grouping points by day
        const today = new Date();
        const date = new Date(today.getFullYear(), today.getMonth(), today.getDate());

        const newLocationPoint = {
            latitude,
            longitude,
            timestamp: today
        };

        const locationRecord = await DriverLocation.findOneAndUpdate(
            { driver: req.user._id, date: date },
            { $push: { locations: newLocationPoint } },
            { new: true, upsert: true }
        );

        res.status(200).json({ message: 'Location saved successfully' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get Location History for a specific date
const getLocationHistory = async (req, res) => {
    try {
        const driverId = req.params.driverId || req.user._id;
        const queryDate = req.query.date ? new Date(req.query.date) : new Date();
        const date = new Date(queryDate.getFullYear(), queryDate.getMonth(), queryDate.getDate());

        const locationRecord = await DriverLocation.findOne({ driver: driverId, date });

        if (!locationRecord) {
            return res.status(404).json({ message: 'No location history found for this date' });
        }

        res.status(200).json(locationRecord);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    saveLocation,
    getLocationHistory
};
