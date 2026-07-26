const mongoose = require('mongoose');
const User = require('./models/User');
const ParentProfile = require('./models/ParentProfile');
const DriverProfile = require('./models/DriverProfile');
const Attendance = require('./models/Attendance');

async function checkAttendance() {
    await mongoose.connect('mongodb+srv://goudariteshkumar1_db_user:g2iChhQXdSonfPLW@cluster0.ib5tcmx.mongodb.net/?appName=Cluster0');
    console.log("Connected to DB");

    try {
        const startOfDay = new Date();
        startOfDay.setHours(0, 0, 0, 0);
        
        const attendances = await Attendance.find({ date: { $gte: startOfDay } })
            .populate('driver')
            .populate('parent_profile');
            
        console.log(`Attendances today: ${attendances.length}`);
        for (let a of attendances) {
            console.log(`- Driver ID in attendance: ${a.driver ? a.driver._id : 'Unknown'}`);
            console.log(`  Student: ${a.parent_profile ? a.parent_profile.child_name : 'Unknown'}, Status: ${a.status}`);
            if (a.parent_profile) {
                console.log(`  Student's Current Connected Driver: ${a.parent_profile.connected_driver}`);
            }
        }
    } catch (e) {
        console.error(e);
    } finally {
        await mongoose.disconnect();
    }
}
checkAttendance();
