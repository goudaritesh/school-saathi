const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const { getChatHistory, uploadChatImage, getConversations, deleteMessage } = require('../controllers/chatController');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Ensure upload directory exists
const uploadDir = path.join(__dirname, '../uploads/chat');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

// Setup multer storage
const storage = multer.diskStorage({
    destination(req, file, cb) {
        cb(null, uploadDir);
    },
    filename(req, file, cb) {
        cb(null, `chat-${req.user._id}-${Date.now()}${path.extname(file.originalname)}`);
    }
});

const upload = multer({
    storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
    fileFilter(req, file, cb) {
        // Accept all files to prevent errors with some device cameras/pickers
        return cb(null, true);
    }
});

router.route('/conversations').get(protect, getConversations);
router.route('/upload-image').post(protect, upload.single('image'), uploadChatImage);
router.route('/:userId').get(protect, getChatHistory);
router.route('/:messageId').delete(protect, deleteMessage);

module.exports = router;
