const mongoose = require('mongoose');
const User = require('./models/User');
const DriverProfile = require('./models/DriverProfile');
const ParentProfile = require('./models/ParentProfile');
const Vehicle = require('./models/Vehicle');
const Route = require('./models/Route');
const Attendance = require('./models/Attendance');
const Payment = require('./models/Payment');
const connectDB = require('./config/db');

require('dotenv').config();

const seedDB = async () => {
    try {
        await connectDB();
        
        console.log('Clearing DB...');
        await User.deleteMany({ role: { $ne: 'Admin' } });
        await DriverProfile.deleteMany({});
        await ParentProfile.deleteMany({});
        await Vehicle.deleteMany({});
        await Route.deleteMany({});
        await Attendance.deleteMany({});
        await Payment.deleteMany({});
        console.log('Seeding Users...');
        
        const driver1 = await User.create({ name: 'Rahul Sharma', email: 'rahul@schoolvan.com', password: 'password', phone: '9876543210', role: 'Driver' });
        const driver2 = await User.create({ name: 'Vikram Singh', email: 'vikram@schoolvan.com', password: 'password', phone: '9876543211', role: 'Driver' });
        
        const parent1 = await User.create({ name: 'Krishna Gupta', email: 'krishna@mail.com', password: 'password', phone: '9998887776', role: 'Parent' });
        const parent2 = await User.create({ name: 'Ramesh Patel', email: 'ramesh@mail.com', password: 'password', phone: '9998887777', role: 'Parent' });

        console.log('Seeding Profiles...');
        
        const driverProfile1 = await DriverProfile.create({ user: driver1._id, license_no: 'DL12345', vehicle_no: 'DL-1C-AA-1111', reference_code: 'REF001', status: 'Active' });
        const driverProfile2 = await DriverProfile.create({ user: driver2._id, license_no: 'DL67890', vehicle_no: 'DL-1C-BB-2222', reference_code: 'REF002', status: 'Active' });

        const parentProfile1 = await ParentProfile.create({
            user: parent1._id,
            child_name: 'Aman',
            child_class: '5th Grade',
            address: '123 Main St, Sector 4',
            connected_driver: driver1._id
        });
        const parentProfile2 = await ParentProfile.create({
            user: parent2._id,
            child_name: 'Rohan',
            child_class: '7th Grade',
            address: '456 Elm St, Sector 9',
            connected_driver: driver2._id
        });

        console.log('Seeding Vehicles and Routes...');
        
        const vehicle1 = await Vehicle.create({ vehicleNumber: 'DL-1C-AA-1111', capacity: 15, rcNumber: 'RC1111', driver: driver1._id, status: 'Active' });
        const vehicle2 = await Vehicle.create({ vehicleNumber: 'DL-1C-BB-2222', capacity: 12, rcNumber: 'RC2222', driver: driver2._id, status: 'Maintenance' });

        await Route.create({ routeName: 'Sector 4 to DPS', assignedVehicle: vehicle1._id, assignedDriver: driver1._id, stops: [{ locationName: 'Sector 4', time: '07:00 AM' }, { locationName: 'Sector 5', time: '07:15 AM' }, { locationName: 'DPS', time: '07:45 AM' }], status: 'Active' });
        await Route.create({ routeName: 'Sector 9 to DPS', assignedVehicle: vehicle2._id, assignedDriver: driver2._id, stops: [{ locationName: 'Sector 9', time: '07:00 AM' }, { locationName: 'Sector 10', time: '07:20 AM' }, { locationName: 'DPS', time: '07:50 AM' }], status: 'Active' });

        console.log('Seeding Attendance and Payments...');
        
        await Attendance.create({ parent_profile: parentProfile1._id, driver: driver1._id, status: 'Picked Up' });
        await Attendance.create({ parent_profile: parentProfile2._id, driver: driver2._id, status: 'Dropped Off' });
        
        await Payment.create({ parent_profile: parentProfile1._id, driver: driver1._id, amount: 1500, month: 'July 2026', status: 'Pending' });
        await Payment.create({ parent_profile: parentProfile2._id, driver: driver2._id, amount: 1500, month: 'July 2026', status: 'Paid', transaction_id: 'TXN123456' });

        console.log('Database seeded successfully!');
        process.exit();
    } catch (error) {
        console.error('Error seeding DB:', error);
        process.exit(1);
    }
};

seedDB();
