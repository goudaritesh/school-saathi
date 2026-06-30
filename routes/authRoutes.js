const express = require('express');
const router = express.Router();
const { check, validationResult } = require('express-validator');
const rateLimit = require('express-rate-limit');
const { 
    registerUser, 
    loginUser, 
    refreshTokenHandler,
    getUserProfile, 
    updateUserProfile,
    saveFCMToken 
} = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

const loginLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 10, // Allowing 10 attempts to account for simple typos before IP lock
    message: { message: 'Too many login attempts from this IP, please try again after 15 minutes' },
    standardHeaders: true,
    legacyHeaders: false,
});

// Middleware to handle validation results
const validate = (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }
    next();
};

router.post('/register', [
    check('name', 'Name is required').not().isEmpty().trim().escape(),
    check('phone', 'Phone is required').not().isEmpty().trim().escape(),
    check('password', 'Password must be 6 or more characters').isLength({ min: 6 }),
], validate, registerUser);

router.post('/login', loginLimiter, [
    check('password', 'Password is required').exists(),
], validate, loginUser);

router.post('/refresh', refreshTokenHandler);

router.get('/profile', protect, getUserProfile);
router.put('/profile', protect, updateUserProfile);
router.post('/fcm-token', protect, saveFCMToken);

module.exports = router;
