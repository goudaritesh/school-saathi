const mongoose = require('mongoose');
const User = require('./models/User');
const DriverProfile = require('./models/DriverProfile');
const ParentProfile = require('./models/ParentProfile');
const Attendance = require('./models/Attendance');

async function check() {
    await mongoose.connect('mongodb+srv://goudariteshkumar1_db_user:g2iChhQXdSonfPLW@cluster0.ib5tcmx.mongodb.net/?appName=Cluster0');
    console.log("Connected to DB");

    try {
        const drivers = await DriverProfile.find().populate('user');
        console.log("Drivers:");
        for (let d of drivers) {
            console.log(`- ${d.user.name} (${d._id})`);
            
            // find parent profiles for this driver
            const parents = await ParentProfile.find({ connected_driver: d.user._id }).populate('user');
            for (let p of parents) {
                console.log(`  -> Student: ${p.child_name}, Parent: ${p.user.name}`);
            }
        }
        
        console.log("\nUnconnected Parents:");
        const unconnected = await ParentProfile.find({ connected_driver: { $exists: false } }).populate('user');
        for (let p of unconnected) {
            console.log(`- Student: ${p.child_name}, Parent: ${p.user ? p.user.name : 'Unknown'}`);
        }
        
        console.log("\nAll Parents:");
        const allParents = await ParentProfile.find().populate('user');
        for (let p of allParents) {
            console.log(`- Student: ${p.child_name}, Parent: ${p.user ? p.user.name : 'Unknown'}, Connected To: ${p.connected_driver}`);
        }
        
    } catch (e) {
        console.error(e);
    } finally {
        await mongoose.disconnect();
    }
}
check();
