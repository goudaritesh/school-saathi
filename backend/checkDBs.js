const mongoose = require('mongoose');
require('dotenv').config();

const run = async () => {
    try {
        const uri = 'mongodb+srv://goudariteshkumar1_db_user:g2iChhQXdSonfPLW@cluster0.ib5tcmx.mongodb.net/?appName=Cluster0';
        const connection = await mongoose.createConnection(uri).asPromise();
        const Admin = connection.db.admin();
        const dbs = await Admin.listDatabases();
        
        console.log('Databases:', dbs.databases.map(d => d.name));
        for (const dbInfo of dbs.databases) {
            const dbName = dbInfo.name;
            const db = connection.useDb(dbName);
            const collections = await db.db.listCollections().toArray();
            console.log(`DB: ${dbName}, Collections: ${collections.map(c => c.name).join(', ')}`);
            
            if (collections.some(c => c.name === 'users')) {
                const users = await db.collection('users').find({}).toArray();
                console.log(`Users in ${dbName}:`, users.map(u => ({ email: u.email, role: u.role })));
            }
        }
        process.exit();
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
}
run();
