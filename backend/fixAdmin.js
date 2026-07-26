const mongoose = require('mongoose');
const User = require('./models/User');
const connectDB = require('./config/db');
require('dotenv').config();

const fixAdmin = async () => {
    try {
        await connectDB();
        await User.deleteOne({ email: 'admin@schoolvan.com' });
        console.log('Admin user deleted. The server.js will recreate it on startup.');
        process.exit();
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
}

fixAdmin();
