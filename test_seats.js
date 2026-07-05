const mongoose = require('mongoose');
const User = require('./models/User');
const DriverProfile = require('./models/DriverProfile');
const ConnectionRequest = require('./models/ConnectionRequest');
const ParentProfile = require('./models/ParentProfile');
const { updateDriverProfile } = require('./controllers/driverController');
const { acceptRequest } = require('./controllers/connectionController');

async function test() {
    await mongoose.connect('mongodb+srv://goudariteshkumar1_db_user:g2iChhQXdSonfPLW@cluster0.ib5tcmx.mongodb.net/?appName=Cluster0');
    console.log("Connected to DB");

    try {
        // 1. Find a driver
        const driverProfile = await DriverProfile.findOne().populate('user');
        if (!driverProfile) return console.log("No driver found");
        
        console.log(`Original total_seats: ${driverProfile.total_seats}, available_seats: ${driverProfile.available_seats}`);
        
        // 2. Test updateDriverProfile
        let resData = null;
        const req = {
            user: driverProfile.user,
            body: {
                total_seats: 10,
                vehicle_no: "TEST 1234"
            }
        };
        const res = {
            json: (data) => { resData = data; },
            status: () => res
        };
        const next = (err) => { console.error(err); };

        await updateDriverProfile(req, res, next);
        console.log("Update Driver Result:", resData.profile);
        
        // 3. Create mock Parent & ConnectionRequest to test decrement
        const parentUser = await User.findOne({ role: 'Parent' });
        if (!parentUser) return console.log("No parent found");

        let request = await ConnectionRequest.create({
            parentId: parentUser._id,
            driverId: driverProfile.user._id
        });
        
        let req2 = { params: { requestId: request._id } };
        let resData2 = null;
        let res2 = {
            json: (data) => { resData2 = data; },
            status: () => res2
        };
        
        await acceptRequest(req2, res2, next);
        console.log("Accept Request Result:", resData2);

        // Fetch driver profile again
        const updatedDriver = await DriverProfile.findById(driverProfile._id);
        console.log(`After accept, total_seats: ${updatedDriver.total_seats}, available_seats: ${updatedDriver.available_seats}`);
        
    } catch (e) {
        console.error(e);
    } finally {
        await mongoose.disconnect();
    }
}

test();
