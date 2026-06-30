const Payment = require('../models/Payment');
const ParentProfile = require('../models/ParentProfile');
const DriverProfile = require('../models/DriverProfile');
const razorpay = require('../config/razorpay');
const crypto = require('crypto');
const { sendPushNotification } = require('../utils/firebase');
const User = require('../models/User');

// @desc    Get all invoices for a parent
// @route   GET /api/payment/invoices
// @access  Private/Parent
const getInvoices = async (req, res, next) => {
    try {
        const parentId = req.user._id;

        const profile = await ParentProfile.findOne({ user: parentId });
        if (!profile) {
            res.status(404);
            throw new Error('Parent profile not found');
        }

        // Fetch payments for this parent
        let payments = await Payment.find({ parent_profile: profile._id }).sort({ createdAt: -1 });

        // If no payments exist, let's create a dummy pending invoice for demonstration
        if (payments.length === 0 && profile.connected_driver) {
            const currentMonth = new Date().toLocaleString('default', { month: 'long', year: 'numeric' });
            const dummyPayment = await Payment.create({
                parent_profile: profile._id,
                driver: profile.connected_driver,
                amount: 1500.00, // Updated to 1500 INR
                month: currentMonth,
                status: 'Pending'
            });
            payments.push(dummyPayment);
        }

        res.json(payments);
    } catch (error) {
        next(error);
    }
};

// @desc    Create Razorpay Order
// @route   POST /api/payment/create-order
// @access  Private/Parent
const createOrder = async (req, res, next) => {
    try {
        const { payment_id } = req.body;
        const payment = await Payment.findById(payment_id);
        
        if (!payment) {
            res.status(404);
            throw new Error('Invoice not found');
        }

        if (payment.status === 'Paid') {
            res.status(400);
            throw new Error('Invoice is already paid');
        }

        const options = {
            amount: Math.round(payment.amount * 100), // amount in the smallest currency unit (paise)
            currency: "INR",
            receipt: `receipt_${payment._id}`
        };

        const order = await razorpay.orders.create(options);
        
        res.json({
            orderId: order.id,
            amount: options.amount,
            currency: options.currency,
            payment_id: payment._id
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Verify Razorpay Payment
// @route   POST /api/payment/verify
// @access  Private/Parent
const verifyPayment = async (req, res, next) => {
    try {
        const { razorpay_order_id, razorpay_payment_id, razorpay_signature, payment_id } = req.body;

        const sign = razorpay_order_id + "|" + razorpay_payment_id;
        const expectedSign = crypto
            .createHmac("sha256", process.env.KEY_SECRET)
            .update(sign.toString())
            .digest("hex");

        if (razorpay_signature !== expectedSign) {
            res.status(400);
            throw new Error('Invalid payment signature');
        }

        const payment = await Payment.findById(payment_id);
        if (!payment) {
            res.status(404);
            throw new Error('Invoice not found');
        }

        payment.status = 'Paid';
        payment.transaction_id = razorpay_payment_id;
        await payment.save();

        // Send push notification to parent
        const parentUser = await User.findById(req.user._id);
        if (parentUser && parentUser.fcm_token) {
            await sendPushNotification(
                parentUser.fcm_token, 
                'Payment Successful', 
                `Your payment of ₹${payment.amount} for ${payment.month} was successful.`
            );
        }

        // Send push notification to driver
        const driverUser = await User.findById(payment.driver);
        if (driverUser && driverUser.fcm_token) {
            await sendPushNotification(
                driverUser.fcm_token, 
                'Fee Received', 
                `You received a payment of ₹${payment.amount} for ${payment.month}.`
            );
        }

        res.json({
            message: 'Payment verified successfully',
            payment
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get earnings for a driver
// @route   GET /api/payment/earnings
// @access  Private/Driver
const getDriverEarnings = async (req, res, next) => {
    try {
        const driverId = req.user._id;

        // Populate parent profile to get child name
        const payments = await Payment.find({ driver: driverId })
            .populate('parent_profile', 'child_name')
            .sort({ createdAt: -1 });

        let totalCollected = 0;
        let totalPending = 0;

        payments.forEach(payment => {
            if (payment.status === 'Paid') {
                totalCollected += payment.amount;
            } else {
                totalPending += payment.amount;
            }
        });

        res.json({
            totalCollected,
            totalPending,
            transactions: payments
        });
    } catch (error) {
        next(error);
    }
};

module.exports = {
    getInvoices,
    createOrder,
    verifyPayment,
    getDriverEarnings
};
