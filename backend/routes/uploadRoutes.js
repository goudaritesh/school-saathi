const express = require('express');
const router = express.Router();
const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const cloudinary = require('cloudinary').v2;
const fs = require('fs');
const path = require('path');
const { protect } = require('../middleware/authMiddleware');

// Configure Cloudinary from env variables, if they exist
let useCloudinary = false;
if (process.env.CLOUDINARY_CLOUD_NAME && process.env.CLOUDINARY_API_KEY && process.env.CLOUDINARY_API_SECRET) {
    cloudinary.config({
        cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
        api_key: process.env.CLOUDINARY_API_KEY,
        api_secret: process.env.CLOUDINARY_API_SECRET,
    });
    useCloudinary = true;
    console.log("Cloudinary is configured and active for file uploads.");
} else {
    console.log("Cloudinary not configured. Falling back to local storage for file uploads.");
}

let storage;

if (useCloudinary) {
    storage = new CloudinaryStorage({
        cloudinary: cloudinary,
        params: {
            folder: 'school_sathi',
            allowed_formats: ['jpg', 'png', 'jpeg', 'pdf'],
        },
    });
} else {
    // Fallback to local storage
    const uploadDir = path.join(__dirname, '../uploads');
    if (!fs.existsSync(uploadDir)) {
        fs.mkdirSync(uploadDir);
    }
    storage = multer.diskStorage({
        destination(req, file, cb) {
            cb(null, uploadDir);
        },
        filename(req, file, cb) {
            cb(null, `${req.user._id}-${Date.now()}${path.extname(file.originalname)}`);
        },
    });
}

const upload = multer({ storage });

router.use(protect);

// @desc    Upload generic file
// @route   POST /api/upload
router.post('/', upload.single('file'), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ message: 'No file uploaded' });
    }
    
    // If using Cloudinary, multer-storage-cloudinary provides req.file.path as the URL
    // If local, we return a relative path
    const fileUrl = useCloudinary ? req.file.path : `/uploads/${req.file.filename}`;
    
    res.json({ url: fileUrl });
});

module.exports = router;
