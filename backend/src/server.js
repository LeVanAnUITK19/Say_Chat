import express from 'express';
import { createServer } from 'http';
import dotenv from 'dotenv';
import { connectDB } from './libs/db.js';
import authRoute from './routes/authRoute.js';
import cookieParser from 'cookie-parser';
import userRoute from './routes/userRoute.js';
import { protectedRoute } from './middlewares/authMiddleware.js';
import cors from 'cors';
import friendRoute from './routes/friendRoute.js';
import messageRoute from './routes/messageRoute.js';
import conversationRoute from './routes/conversationRoute.js';
import uploadRoute from './routes/uploadRoute.js';
import reactionRoute from './routes/reactionRoute.js';
import testRoute from './routes/testRoute.js';
import { startStatusCleanup } from './utils/statusCleanup.js';
import { initSocket } from './libs/socket.js';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config();

const app = express();
const httpServer = createServer(app);
const PORT = process.env.PORT || 5001;

app.use('/api', testRoute);

// CORS middleware - PHẢI ĐẶT TRƯỚC CÁC MIDDLEWARE KHÁC
app.use(cors({
  origin: true, // Allow all origins in development
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

//middleware
app.use(express.json());
app.use(cookieParser());

// Serve static files từ thư mục uploads
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

//PUBLIC ROUTES

app.use('/api/auth', authRoute);

//PRIVATE ROUTES
app.use(protectedRoute);

app.use('/api/user', userRoute);

app.use('/api/friends', friendRoute);

app.use('/api/messages', messageRoute);

app.use('/api/conversations', conversationRoute);

app.use('/api/upload', uploadRoute);

app.use('/api/reactions', reactionRoute);




connectDB().then(() => {
    initSocket(httpServer);
    httpServer.listen(PORT, () => {
        console.log(`Server bắt đầu trên cổng ${PORT}`);
        startStatusCleanup();
    });
});