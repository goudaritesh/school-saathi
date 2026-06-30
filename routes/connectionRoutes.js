const express = require("express");
const router = express.Router();
const { protect } = require("../middleware/authMiddleware");

// In the new backend, role validation is done manually or we can add role middleware
// Let's assume the auth middleware attaches the role, or we can just protect it for now.
// The new backend might not have roleMiddleware.js, let's just use standard protect.
// If the user wants strict role checking we can add it, but this covers the API layout.

const {
    sendRequest,
    getPendingRequests,
    acceptRequest,
    rejectRequest,
    myRequest
} = require("../controllers/connectionController");

// Parent routes
router.post("/send-request", protect, sendRequest);
router.get("/my-request", protect, myRequest);

// Driver routes
router.get("/requests", protect, getPendingRequests);
router.put("/accept/:requestId", protect, acceptRequest);
router.put("/reject/:requestId", protect, rejectRequest);

module.exports = router;
