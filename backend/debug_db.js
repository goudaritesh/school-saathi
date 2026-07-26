const mongoose = require('mongoose');
const Attendance = require('./models/Attendance');
const ParentProfile = require('./models/ParentProfile');
const DriverProfile = require('./models/DriverProfile');

async function run() {
    await mongoose.connect('mongodb://localhost:27017/school_sathi', {
        useNewUrlParser: true,
        useUnifiedTopology: true
    });
    console.log("Connected to DB");

    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const attendances = await Attendance.find({ date: { $gte: startOfDay } });
    console.log("Today's Attendances:", attendances);

    const profiles = await ParentProfile.find({});
    console.log("All Parent Profiles:", profiles);

    process.exit(0);
}
run().catch(console.error);
