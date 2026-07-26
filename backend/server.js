const http = require('http');
require('dotenv').config();
const connectDB = require('./config/db');
const app = require('./app');
const User = require('./models/User');
const bcrypt = require('bcryptjs');

// Connect to Database
connectDB();

// Start Cron Jobs
require('./cron/paymentReminderCron');

// Seed Admin User
const seedAdmin = async () => {
    try {
        const adminExists = await User.findOne({ email: 'admin@schoolvan.com' });
        if (!adminExists) {
            await User.create({
                name: 'Super Admin',
                email: 'admin@schoolvan.com',
                password: 'admin123',
                phone: '1234567890',
                role: 'Admin'
            });
            console.log('Seed: Default Admin created (admin@schoolvan.com / admin123)');
        }
    } catch (e) {
        console.error('Seed Admin error:', e);
    }
};
seedAdmin();

const server = http.createServer(app);
const { initializeSocket } = require('./socket/socketServer');

// Initialize Socket.io
initializeSocket(server);

const PORT = process.env.PORT || 5000;

server.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`);
});
