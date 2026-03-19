import { Server } from 'socket.io';
import jwt from 'jsonwebtoken';
import User from '../models/User.js';

let io;

// Map userId -> Set of socketIds
const onlineUsers = new Map();

const getSocketId = (targetUserId) => {
    const sockets = onlineUsers.get(targetUserId);
    return sockets ? [...sockets][0] : null;
};

export const initSocket = (httpServer) => {
    io = new Server(httpServer, {
        cors: { origin: true, credentials: true },
    });

    io.use(async (socket, next) => {
        try {
            const token = socket.handshake.auth?.token;
            if (!token) return next(new Error('Unauthorized'));
            const decoded = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
            const user = await User.findById(decoded.userId).select('-hashedPassword');
            if (!user) return next(new Error('User not found'));
            socket.user = user;
            next();
        } catch (err) {
            next(new Error('Unauthorized'));
        }
    });

    io.on('connection', (socket) => {
        const userId = socket.user._id.toString();
        console.log(`🔌 Socket connected: ${socket.id} (user: ${socket.user.username})`);

        if (!onlineUsers.has(userId)) onlineUsers.set(userId, new Set());
        onlineUsers.get(userId).add(socket.id);

        // Join personal room để nhận events cá nhân (new_conversation, v.v.)
        socket.join(`user_${userId}`);

        // --- Messaging ---
        socket.on('join_conversation', (conversationId) => {
            socket.join(conversationId);
            console.log(`📥 ${socket.user.username} joined room: ${conversationId}`);
        });

        socket.on('leave_conversation', (conversationId) => {
            socket.leave(conversationId);
        });

        // --- Call signaling ---
        socket.on('call_offer', ({ to, offer, callType }) => {
            const targetSocketId = getSocketId(to);
            if (targetSocketId) {
                io.to(targetSocketId).emit('call_offer', {
                    from: socket.user._id,
                    fromUsername: socket.user.username,
                    offer,
                    callType,
                });
            }
        });

        socket.on('call_answer', ({ to, answer }) => {
            const targetSocketId = getSocketId(to);
            if (targetSocketId) io.to(targetSocketId).emit('call_answer', { answer });
        });

        socket.on('ice_candidate', ({ to, candidate }) => {
            const targetSocketId = getSocketId(to);
            if (targetSocketId) io.to(targetSocketId).emit('ice_candidate', { candidate });
        });

        socket.on('call_end', ({ to }) => {
            const targetSocketId = getSocketId(to);
            if (targetSocketId) io.to(targetSocketId).emit('call_end');
        });

        socket.on('call_rejected', ({ to }) => {
            const targetSocketId = getSocketId(to);
            if (targetSocketId) io.to(targetSocketId).emit('call_rejected');
        });

        socket.on('disconnect', () => {
            console.log(`🔌 Socket disconnected: ${socket.id}`);
            onlineUsers.get(userId)?.delete(socket.id);
            if (onlineUsers.get(userId)?.size === 0) onlineUsers.delete(userId);
        });
    });

    return io;
};

export const getIO = () => {
    if (!io) throw new Error('Socket.io not initialized');
    return io;
};
