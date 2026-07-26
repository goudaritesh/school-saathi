const mongoose = require('mongoose');
const Attendance = require('./models/Attendance');
const ParentProfile = require('./models/ParentProfile');
async function run() {
    await mongoose.connect('mongodb+srv://goudariteshkumar1_db_user:g2iChhQXdSonfPLW@cluster0.ib5tcmx.mongodb.net/?appName=Cluster0');
    const driverId = '6a448c1718aec94953a0bb55';
    const studentsData = await ParentProfile.find({ connected_driver: driverId }).populate('user', 'name phone').lean();
    
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);
    
    const attendances = await Attendance.find({
        driver: driverId,
        date: { $gte: startOfDay }
    }).sort({ createdAt: -1 });
    
    const students = studentsData.map(student => {
        const studentAttendance = attendances.find(a => {
            const aId = (a.parent_profile && a.parent_profile._id) ? a.parent_profile._id.toString() : a.parent_profile?.toString();
            return aId === student._id.toString();
        });
        return {
            ...student,
            today_attendance: studentAttendance ? studentAttendance.status : 'Pending'
        };
    });
    console.log(JSON.stringify(students, null, 2));
    process.exit(0);
}
run();
