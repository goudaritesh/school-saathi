const Message = require('../models/Message');
const User = require('../models/User');

// @desc    Get chat history between current user and another user
// @route   GET /api/chat/:userId
// @access  Private
const getChatHistory = async (req, res) => {
    try {
        const { userId } = req.params;
        const currentUserId = req.user._id;

        // Ensure the other user exists
        const otherUser = await User.findById(userId);
        if (!otherUser) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Pagination
        const page = parseInt(req.query.page, 10) || 1;
        const limit = parseInt(req.query.limit, 10) || 50;
        const skip = (page - 1) * limit;

        const messages = await Message.find({
            $or: [
                { sender: currentUserId, receiver: userId },
                { sender: userId, receiver: currentUserId }
            ]
        })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit);

        res.json(messages.reverse()); // Reverse to get chronological order in frontend
    } catch (error) {
        console.error('Chat history error:', error);
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Upload an image for chat
// @route   POST /api/chat/upload-image
// @access  Private
const uploadChatImage = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ message: 'Please upload an image file' });
        }

        // Return the relative URL of the uploaded image
        // We will serve the uploads folder statically in app.js
        const imageUrl = `/uploads/chat/${req.file.filename}`;
        
        res.json({ imageUrl });
    } catch (error) {
        console.error('Upload image error:', error);
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Get list of users the current user has chatted with
// @route   GET /api/chat/conversations
// @access  Private
const getConversations = async (req, res) => {
    try {
        const currentUserId = req.user._id;

        // Find all distinct users the current user has exchanged messages with
        const messages = await Message.find({
            $or: [{ sender: currentUserId }, { receiver: currentUserId }]
        }).sort({ createdAt: -1 });

        const conversationMap = new Map();

        for (const msg of messages) {
            const otherUserId = msg.sender.toString() === currentUserId.toString() 
                ? msg.receiver.toString() 
                : msg.sender.toString();
            
            if (!conversationMap.has(otherUserId)) {
                conversationMap.set(otherUserId, msg);
            }
        }

        // Fetch user details for these conversations
        const userIds = Array.from(conversationMap.keys());
        const users = await User.find({ _id: { $in: userIds } }).select('name email role');

        const conversations = users.map(user => {
            const lastMessage = conversationMap.get(user._id.toString());
            return {
                user,
                lastMessage
            };
        });

        // Sort conversations by last message time
        conversations.sort((a, b) => new Date(b.lastMessage.createdAt) - new Date(a.lastMessage.createdAt));

        res.json(conversations);
    } catch (error) {
        console.error('Get conversations error:', error);
        res.status(500).json({ message: 'Server Error' });
    }
};

module.exports = {
    getChatHistory,
    uploadChatImage,
    getConversations
};
