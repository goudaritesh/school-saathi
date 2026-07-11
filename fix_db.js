const mongoose = require('mongoose');
mongoose.connect('mongodb+srv://goudariteshkumar1_db_user:g2iChhQXdSonfPLW@cluster0.ib5tcmx.mongodb.net/?appName=Cluster0').then(async () => {
    await mongoose.connection.db.collection('connectionrequests').updateMany(
        { routeAddress: { $exists: false } },
        { $set: { routeAddress: 'Old Request - Route N/A', schoolTiming: 'Old Request - Timing N/A' } }
    );
    console.log('Updated old records');
    process.exit(0);
});
