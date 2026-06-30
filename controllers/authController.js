const User = require('../models/User');
const DriverProfile = require('../models/DriverProfile');
const ParentProfile = require('../models/ParentProfile');
const jwt = require('jsonwebtoken');

// Generate Access Token (15 mins)
const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET, {
        expiresIn: '15m',
    });
};

// Generate Refresh Token (7 days)
const generateRefreshToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET, {
        expiresIn: '7d',
    });
};

// Generate 6-digit reference code
const generateRefCode = () => {
    return Math.floor(100000 + Math.random() * 900000).toString();
};

// @desc    Register new user
// @route   POST /api/auth/register
// @access  Public
const registerUser = async (req, res, next) => {
    try {
        const { name, email, password, role, phone, vehicle_no, license_no, child_name, refcode } = req.body;

        // Check if user exists (using phone as primary ID from UI or email)
        const userExists = await User.findOne({ $or: [{ email: email || `${phone}@schoolvan.com` }, { phone }] });

        if (userExists) {
            res.status(400);
            throw new Error('User with this phone number already exists');
        }

        // Validate Role specifics before creating User
        let driverRef = null;
        if (role === 'Parent') {
            if (!child_name) {
                res.status(400);
                throw new Error('Child name is required for parents');
            }
            if (refcode) {
                driverRef = await DriverProfile.findOne({ reference_code: refcode });
                if (!driverRef) {
                    res.status(404);
                    throw new Error('Invalid driver reference code');
                }
            }
        }

        if (role === 'Driver') {
            if (!vehicle_no || !license_no) {
                res.status(400);
                throw new Error('Vehicle number and license number are required for drivers');
            }
        }

        // Create user
        const user = await User.create({
            name,
            email: email || `${phone}@schoolvan.com`,
            password,
            role,
            phone,
        });

        // Create Profile based on role
        if (role === 'Driver') {
            let uniqueCode = generateRefCode();
            while (await DriverProfile.findOne({ reference_code: uniqueCode })) {
                uniqueCode = generateRefCode();
            }

            await DriverProfile.create({
                user: user._id,
                vehicle_no,
                license_no,
                reference_code: uniqueCode,
            });
        } else if (role === 'Parent') {
            await ParentProfile.create({
                user: user._id,
                child_name,
                connected_driver: driverRef ? driverRef.user : null,
                qr_code_data: `SVC-${user._id.toString()}`,
            });
        }

        if (user) {
            const refreshToken = generateRefreshToken(user._id);
            user.refreshToken = refreshToken;
            await user.save();

            res.status(201).json({
                _id: user._id,
                name: user.name,
                role: user.role,
                phone: user.phone,
                token: generateToken(user._id),
                refreshToken,
            });
        } else {
            res.status(400);
            throw new Error('Invalid user data');
        }
    } catch (error) {
        next(error);
    }
};

// @desc    Authenticate a user
// @route   POST /api/auth/login
// @access  Public
const loginUser = async (req, res, next) => {
    try {
        let { email, phone, password } = req.body;
        
        if (email) email = email.trim().toLowerCase();
        if (password) password = password.trim();
        
        const identifier = email || phone;
        const user = await User.findOne({ 
            $or: [{ email: identifier }, { phone: identifier }] 
        }).select('+password');

        if (!user) {
            res.status(401);
            throw new Error('Invalid credentials');
        }

        // Check if account is locked
        if (user.lockUntil && user.lockUntil > Date.now()) {
            res.status(403);
            throw new Error('Account locked due to too many failed login attempts. Try again later.');
        }

        const isMatch = await user.matchPassword(password);

        if (isMatch) {
            // Reset lockout
            user.loginAttempts = 0;
            user.lockUntil = undefined;
            const refreshToken = generateRefreshToken(user._id);
            user.refreshToken = refreshToken;
            await user.save();

            res.json({
                _id: user._id,
                name: user.name,
                email: user.email,
                role: user.role,
                phone: user.phone,
                token: generateToken(user._id),
                refreshToken,
            });
        } else {
            // Increment lockout
            user.loginAttempts = (user.loginAttempts || 0) + 1;
            if (user.loginAttempts >= 5) {
                user.lockUntil = Date.now() + 15 * 60 * 1000; // 15 mins lock
            }
            await user.save();
            
            res.status(401);
            throw new Error('Invalid credentials');
        }
    } catch (error) {
        next(error);
    }
};

// @desc    Refresh Token
// @route   POST /api/auth/refresh
// @access  Public
const refreshTokenHandler = async (req, res, next) => {
    try {
        const { refreshToken } = req.body;
        if (!refreshToken) {
            res.status(401);
            throw new Error('Refresh token required');
        }

        // Verify token
        const decoded = jwt.verify(refreshToken, process.env.JWT_SECRET);
        const user = await User.findById(decoded.id);

        if (!user || user.refreshToken !== refreshToken) {
            res.status(403);
            throw new Error('Invalid refresh token');
        }

        // Issue new access token
        const newAccessToken = generateToken(user._id);
        res.json({ token: newAccessToken });
    } catch (error) {
        res.status(403);
        next(new Error('Invalid or expired refresh token'));
    }
};

// @desc    Get current user profile
// @route   GET /api/auth/profile
// @access  Private
const getUserProfile = async (req, res, next) => {
    try {
        const user = await User.findById(req.user._id);

        if (user) {
            res.json({
                _id: user._id,
                name: user.name,
                email: user.email,
                role: user.role,
                phone: user.phone,
                profile_photo_url: user.profile_photo_url,
            });
        } else {
            res.status(404);
            throw new Error('User not found');
        }
    } catch (error) {
        next(error);
    }
};

// @desc    Update user profile
// @route   PUT /api/auth/profile
// @access  Private
const updateUserProfile = async (req, res, next) => {
    try {
        const user = await User.findById(req.user._id);
        if (user) {
            user.profile_photo_url = req.body.profile_photo_url || user.profile_photo_url;
            await user.save();
            res.json({
                _id: user._id,
                name: user.name,
                email: user.email,
                role: user.role,
                phone: user.phone,
                profile_photo_url: user.profile_photo_url,
            });
        } else {
            res.status(404);
            throw new Error('User not found');
        }
    } catch (error) {
        next(error);
    }
};

// @desc    Save FCM Token
// @route   POST /api/auth/fcm-token
// @access  Private
const saveFCMToken = async (req, res, next) => {
    try {
        const { fcm_token } = req.body;
        
        if (!fcm_token) {
            res.status(400);
            throw new Error('FCM token is required');
        }

        const user = await User.findById(req.user._id);
        
        if (user) {
            user.fcm_token = fcm_token;
            await user.save();
            res.json({ message: 'FCM token saved successfully' });
        } else {
            res.status(404);
            throw new Error('User not found');
        }
    } catch (error) {
        next(error);
    }
};

module.exports = {
    registerUser,
    loginUser,
    refreshTokenHandler,
    getUserProfile,
    updateUserProfile,
    saveFCMToken
};
