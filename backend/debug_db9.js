const mongoose = require('mongoose');
const ParentProfile = require('./models/ParentProfile');
const DriverProfile = require('./models/DriverProfile');

async function fixGita() {
    await mongoose.connect('mongodb+srv://goudariteshkumar1_db_user:g2iChhQXdSonfPLW@cluster0.ib5tcmx.mongodb.net/?appName=Cluster0');
    console.log("Connected to DB");

    try {
        // The driver they want is Ram #2: user ID 6a448c1718aec94953a0bb55
        const targetDriverUserId = '6a448c1718aec94953a0bb55';
        const wrongDriverUserId = '6a44891e18aec94953a0bb4d';

        // Find Gita
        const gitaProfile = await ParentProfile.findOne({ child_name: 'Gita' });
        
        if (gitaProfile) {
            gitaProfile.connected_driver = targetDriverUserId;
            await gitaProfile.save();
            console.log("Gita successfully moved back to the correct driver.");
            
            // Adjust available seats for wrong driver (increment)
            await DriverProfile.findOneAndUpdate(
                { user: wrongDriverUserId },
                { $inc: { available_seats: 1 } }
            );
            
            // Adjust available seats for right driver (decrement)
            await DriverProfile.findOneAndUpdate(
                { user: targetDriverUserId },
                { $inc: { available_seats: -1 } }
            );
            
            console.log("Seats adjusted as well.");
        } else {
            console.log("Gita not found.");
        }

    } catch (e) {
        console.error(e);
    } finally {
        await mongoose.disconnect();
    }
}
fixGita();
