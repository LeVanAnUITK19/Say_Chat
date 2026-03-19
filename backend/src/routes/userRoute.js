import express from 'express';
import { authMe, heartbeat, findUser, findUserByQrCode, getUserById, updateAvatar } from '../controllers/userController.js';
import { protectedRoute } from '../middlewares/authMiddleware.js';

const router = express.Router();

router.get('/me', authMe);
router.post('/heartbeat', heartbeat);
router.put('/avatar', protectedRoute, updateAvatar);
router.get('/qr/:qrCode', findUserByQrCode);
router.get('/:email/search', findUser);
router.get('/:userId/profile', getUserById);

export default router;