require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./models/User');
const bcrypt = require('bcryptjs');
const connectDB = require('./config/db');

async function checkAdmin() {
    await connectDB();
    const admin = await User.findOne({ email: 'admin@schoolvan.com' }).select('+password');
    if (!admin) {
        console.log("Admin user not found in DB.");
    } else {
        console.log("Admin found:", admin.email, admin.role);
        const isMatch = await bcrypt.compare('admin123', admin.password);
        console.log("Does 'admin123' match the hash? ", isMatch);
        const isMatch2 = await bcrypt.compare('Admin123', admin.password);
        console.log("Does 'Admin123' match the hash? ", isMatch2);
        
        console.log("Current hash:", admin.password);
    }
    process.exit(0);
}

checkAdmin();
