import express from 'express';
import { signUp, signIn, signOut, resetPassword, sendResetPasswordOtp, refreshToken, googleSignIn } from '../controllers/authController.js';
import { protectedRoute } from '../middlewares/authMiddleware.js';

const router = express.Router();

router.post("/signup", signUp);
router.post("/signin", signIn);
router.post("/google", googleSignIn);
router.post("/reset-password", resetPassword);
router.post("/send-otp", sendResetPasswordOtp);
router.post("/signout", protectedRoute, signOut);
router.post("/refresh", refreshToken);

export default router;