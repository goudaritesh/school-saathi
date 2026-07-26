const mongoose = require('mongoose');
const Attendance = require('./models/Attendance');
const ParentProfile = require('./models/ParentProfile');
async function run() {
    await mongoose.connect('mongodb+srv://goudariteshkumar1_db_user:g2iChhQXdSonfPLW@cluster0.ib5tcmx.mongodb.net/?appName=Cluster0');
    
    // Hardcode the driver ID from the previous logs
    const driverId = '6a448c1718aec94953a0bb55';

    const startOfDay = new Date();
    startOfDay.setHours(0,0,0,0);
    
    const studentsData = await ParentProfile.find({ connected_driver: driverId }).lean();
    console.log("studentsData count:", studentsData.length);

    const attendances = await Attendance.find({
        driver: driverId,
        date: { $gte: startOfDay }
    }).sort({ createdAt: -1 });

    const students = studentsData.map(student => {
        const studentAttendance = attendances.find(a => a.parent_profile.toString() === student._id.toString());
        return {
            name: student.child_name,
            id: student._id.toString(),
            today_attendance: studentAttendance ? studentAttendance.status : 'Pending'
        };
    });

    console.log("mapped students:", JSON.stringify(students, null, 2));
    process.exit(0);
}
run();
