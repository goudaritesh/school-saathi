const mongoose = require('mongoose');
const Attendance = require('./models/Attendance');
async function run() {
    await mongoose.connect('mongodb+srv://goudariteshkumar1_db_user:g2iChhQXdSonfPLW@cluster0.ib5tcmx.mongodb.net/?appName=Cluster0');
    const att = await Attendance.findOne();
    console.log("typeof parent_profile:", typeof att.parent_profile);
    console.log("constructor name:", att.parent_profile.constructor.name);
    console.log("toString:", att.parent_profile.toString());
    process.exit(0);
}
run();
