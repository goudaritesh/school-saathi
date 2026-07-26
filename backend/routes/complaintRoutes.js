const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const { 
    createComplaint, 
    getComplaints, 
    updateComplaintStatus, 
    addComplaintResponse 
} = require('../controllers/complaintController');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Ensure upload directory exists
const uploadDir = path.join(__dirname, '../uploads/complaints');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

// Setup multer storage
const storage = multer.diskStorage({
    destination(req, file, cb) {
        cb(null, uploadDir);
    },
    filename(req, file, cb) {
        cb(null, `complaint-${req.user._id}-${Date.now()}${path.extname(file.originalname)}`);
    }
});

const upload = multer({
    storage,
    limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
    fileFilter(req, file, cb) {
        const filetypes = /jpg|jpeg|png|webp|pdf/;
        const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
        const mimetype = filetypes.test(file.mimetype);

        if (extname && mimetype) {
            return cb(null, true);
        } else {
            cb(new Error('Images or PDFs only!'));
        }
    }
});

router.route('/')
    .post(protect, upload.single('attachment'), createComplaint)
    .get(protect, getComplaints);

router.put('/:id/status', protect, updateComplaintStatus);
router.post('/:id/respond', protect, addComplaintResponse);

module.exports = router;
