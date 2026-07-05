const mongoose = require('mongoose');
const Attendance = require('./models/Attendance');
const ParentProfile = require('./models/ParentProfile');
async function run() {
    await mongoose.connect('mongodb+srv://goudariteshkumar1_db_user:g2iChhQXdSonfPLW@cluster0.ib5tcmx.mongodb.net/?appName=Cluster0');
    const startOfDay = new Date();
    startOfDay.setHours(0,0,0,0);
    const attendances = await Attendance.find({ date: { $gte: startOfDay } });
    console.log("attendances:", JSON.stringify(attendances, null, 2));
    process.exit(0);
}
run();
