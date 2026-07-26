const Razorpay = require("razorpay");

let razorpay = null;

try {
    if (process.env.KEY_ID && process.env.KEY_SECRET) {
        razorpay = new Razorpay({
            key_id: process.env.KEY_ID,
            key_secret: process.env.KEY_SECRET
        });
    } else {
        console.warn("⚠️ Razorpay KEY_ID or KEY_SECRET is missing. Payment features will be disabled.");
    }
} catch (error) {
    console.error("⚠️ Failed to initialize Razorpay:", error.message);
}

module.exports = razorpay;
