const { Server } = require('socket.io');
const Message = require('../models/Message');
const User = require('../models/User');
const admin = require('../config/firebase');

let io;

// Store Online Users
const onlineDrivers = new Map();
const onlineParents = new Map();

const initializeSocket = (server) => {
    io = new Server(server, {
        cors: {
            origin: "*",
            methods: ["GET", "POST"]
        }
    });

    io.on("connection", (socket) => {
        console.log("User Connected:", socket.id);

        // ==========================
        // Driver Online
        // ==========================
        socket.on("driverOnline", (driverId) => {
            if (!driverId) return;
            onlineDrivers.set(driverId, socket.id);
            console.log(`Driver Online: ${driverId}`);
            
            io.emit("driverStatus", {
                driverId,
                status: "online"
            });
        });

        // ==========================
        // Driver Location
        // ==========================
        socket.on("updateLocation", (data) => {
            // data should contain { driverId, lat, lng }
            if (data && data.driverId) {
                // Broadcast to any parent listening for this specific driver
                socket.broadcast.emit(`driverLocationUpdate_${data.driverId}`, {
                    lat: data.lat,
                    lng: data.lng,
                    timestamp: Date.now()
                });
            }
        });

        // ==========================
        // Parent Online
        // ==========================
        socket.on("parentOnline", (parentId) => {
            if (!parentId) return;
            onlineParents.set(parentId, socket.id);
            console.log(`Parent Online: ${parentId}`);

            io.emit("parentStatus", {
                parentId,
                status: "online"
            });
        });

        // ==========================
        // Chat Handlers
        // ==========================
        socket.on("sendMessage", async (data) => {
            try {
                const msg = new Message({
                    sender: data.senderId,
                    receiver: data.receiverId,
                    text: data.text || '',
                    messageType: data.messageType || 'text',
                    imageUrl: data.imageUrl || null
                });
                
                const receiverSocketId = onlineDrivers.get(data.receiverId) || onlineParents.get(data.receiverId);
                
                if (receiverSocketId) {
                    msg.delivered = true;
                    await msg.save();
                    io.to(receiverSocketId).emit("receiveMessage", msg);
                } else {
                    await msg.save();
                }

                // Send Push Notification
                const receiverUser = await User.findById(data.receiverId);
                if (receiverUser && receiverUser.fcm_token) {
                    const senderUser = await User.findById(data.senderId);
                    const senderName = senderUser ? senderUser.name : 'New Message';
                    const payload = {
                        notification: {
                            title: senderName,
                            body: data.text || '📸 Image',
                        },
                        data: {
                            type: 'chat',
                            senderId: data.senderId,
                            messageId: msg._id.toString()
                        },
                        token: receiverUser.fcm_token,
                    };
                    try {
                        await admin.messaging().send(payload);
                    } catch(err) {
                        console.error('FCM Send Error:', err);
                    }
                }
                
                // Confirm sent to sender
                socket.emit("messageSent", msg);
            } catch(err) {
                console.error("SendMessage Error:", err);
            }
        });

        socket.on("typing", (data) => {
            const receiverSocketId = onlineDrivers.get(data.receiverId) || onlineParents.get(data.receiverId);
            if (receiverSocketId) {
                io.to(receiverSocketId).emit("userTyping", { senderId: data.senderId });
            }
        });

        socket.on("stopTyping", (data) => {
            const receiverSocketId = onlineDrivers.get(data.receiverId) || onlineParents.get(data.receiverId);
            if (receiverSocketId) {
                io.to(receiverSocketId).emit("userStopTyping", { senderId: data.senderId });
            }
        });

        socket.on("messageDelivered", async (data) => {
            try {
                await Message.findByIdAndUpdate(data.messageId, { delivered: true });
                const senderSocketId = onlineDrivers.get(data.senderId) || onlineParents.get(data.senderId);
                if (senderSocketId) {
                    io.to(senderSocketId).emit("messageDeliveredConfirm", { messageId: data.messageId, deliveredAt: new Date() });
                }
            } catch(err) {
                console.error("MessageDelivered Error:", err);
            }
        });

        socket.on("messageSeen", async (data) => {
            try {
                await Message.findByIdAndUpdate(data.messageId, { seen: true, isRead: true });
                const senderSocketId = onlineDrivers.get(data.senderId) || onlineParents.get(data.senderId);
                if (senderSocketId) {
                    io.to(senderSocketId).emit("messageSeenConfirm", { messageId: data.messageId, seenAt: new Date() });
                }
            } catch(err) {
                console.error("MessageSeen Error:", err);
            }
        });

        // ==========================
        // Disconnect
        // ==========================
        socket.on("disconnect", () => {
            console.log("User Disconnected:", socket.id);

            // Check if it was a parent
            let disconnectedParent = null;
            onlineParents.forEach((socketId, parentId) => {
                if (socketId === socket.id) {
                    disconnectedParent = parentId;
                }
            });

            if (disconnectedParent) {
                onlineParents.delete(disconnectedParent);
                console.log(`Parent Offline: ${disconnectedParent}`);
                io.emit("parentStatus", {
                    parentId: disconnectedParent,
                    status: "offline"
                });
            }

            // Check if it was a driver
            let disconnectedDriver = null;
            onlineDrivers.forEach((socketId, driverId) => {
                if (socketId === socket.id) {
                    disconnectedDriver = driverId;
                }
            });

            if (disconnectedDriver) {
                onlineDrivers.delete(disconnectedDriver);
                console.log(`Driver Offline: ${disconnectedDriver}`);
                io.emit("driverStatus", {
                    driverId: disconnectedDriver,
                    status: "offline"
                });
            }
        });
    });
};

const getIO = () => io;

module.exports = {
    initializeSocket,
    getIO
};
