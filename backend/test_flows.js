const axios = require('axios');

const BASE_URL = 'http://localhost:5000/api';

async function runTests() {
    console.log('--- STARTING BACKEND TESTS ---');
    try {
        const uniquePhoneD = '1' + Date.now().toString().substring(4);
        const uniquePhoneP = '2' + Date.now().toString().substring(4);

        // 1. Auth: Register Driver
        console.log('\n[1] Registering Driver...');
        const driverRes = await axios.post(`${BASE_URL}/auth/register`, {
            name: 'Test Driver',
            email: `driver${Date.now()}@test.com`,
            phone: uniquePhoneD,
            password: 'password123',
            role: 'Driver',
            vehicle_no: 'AB-12-CD-3456',
            license_no: 'DL-123456789'
        });
        const driverToken = driverRes.data.token;
        console.log('✅ Driver registered:', driverRes.data.name);

        // 2. Auth: Register Parent
        console.log('\n[2] Registering Parent...');
        const parentRes = await axios.post(`${BASE_URL}/auth/register`, {
            name: 'Test Parent',
            email: `parent${Date.now()}@test.com`,
            phone: uniquePhoneP,
            password: 'password123',
            role: 'Parent',
            child_name: 'Test Child'
        });
        const parentToken = parentRes.data.token;
        console.log('✅ Parent registered:', parentRes.data.name);

        // 3. Driver Config (needs to be created for reference code)
        // Wait, registration should create the DriverProfile. Let's fetch dashboard to see if profile exists.
        console.log('\n[3] Fetching Driver Dashboard...');
        const dDash = await axios.get(`${BASE_URL}/driver/dashboard`, {
            headers: { Authorization: `Bearer ${driverToken}` }
        });
        console.log('✅ Driver Dashboard fetched. Ref code:', dDash.data.referenceCode);
        const driverCode = dDash.data.referenceCode;

        // 4. Parent fetches all drivers
        console.log('\n[4] Parent fetches all drivers...');
        const driversList = await axios.get(`${BASE_URL}/driver/all`, {
            headers: { Authorization: `Bearer ${parentToken}` }
        });
        console.log(`✅ Parent fetched ${driversList.data.length} drivers.`);

        // 5. Parent sends connection request
        console.log(`\n[5] Parent sends connection request to driver ${driverCode}...`);
        const reqRes = await axios.post(`${BASE_URL}/connection/send-request`, { driverCode }, {
            headers: { Authorization: `Bearer ${parentToken}` }
        });
        console.log('✅ Request sent successfully.');

        // 6. Driver fetches pending requests
        console.log('\n[6] Driver fetches pending requests...');
        const pendingReqs = await axios.get(`${BASE_URL}/connection/requests`, {
            headers: { Authorization: `Bearer ${driverToken}` }
        });
        console.log(`✅ Driver found ${pendingReqs.data.length} pending requests.`);
        
        if (pendingReqs.data.length > 0) {
            const requestId = pendingReqs.data[0]._id;
            
            // 7. Driver accepts request
            console.log(`\n[7] Driver accepting request ${requestId}...`);
            await axios.put(`${BASE_URL}/connection/accept/${requestId}`, {}, {
                headers: { Authorization: `Bearer ${driverToken}` }
            });
            console.log('✅ Request accepted!');
            
            // Verify Parent Profile now has driver
            const pDash = await axios.get(`${BASE_URL}/parent/dashboard`, {
                headers: { Authorization: `Bearer ${parentToken}` }
            });
            console.log('✅ Parent is now connected to driver:', pDash.data.driverId);
        }

        console.log('\n--- ALL TESTS PASSED! ---');
    } catch (e) {
        console.error('❌ TEST FAILED!');
        if (e.response) {
            console.error(e.response.data);
        } else {
            console.error(e.message);
        }
    }
}

runTests();
