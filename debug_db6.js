const mongoose = require('mongoose');
const Attendance = require('./models/Attendance');

async function test() {
    await mongoose.connect('mongodb+srv://goudariteshkumar1_db_user:g2iChhQXdSonfPLW@cluster0.ib5tcmx.mongodb.net/?appName=Cluster0');
    
    // Test with one driver and student
    const driverId = '6a448c1718aec94953a0bb55';
    const studentId = '6a48ea203b5638de0f789b7e'; // Sampurna

    const history = await Attendance.find({
        driver: driverId,
        parent_profile: studentId
    })
    .sort({ date: -1, createdAt: -1 })
    .limit(30)
    .lean();

    console.log("Found history length:", history.length);
    if (history.length > 0) {
        console.log("First history record:", history[0]);
    }
    
    process.exit(0);
}

test();
