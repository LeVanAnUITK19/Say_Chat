import express from 'express';
import { signUp } from '../controllers/authController.js';
import { signIn } from '../controllers/authController.js';
import { signOut } from '../controllers/authController.js';
import { resetPassword } from '../controllers/authController.js';
import { sendResetPasswordOtp } from '../controllers/authController.js';
import { protectedRoute } from '../middlewares/authMiddleware.js';
import { refreshToken } from '../controllers/authController.js';

const router = express.Router();

// PUBLIC ROUTES (không cần token)
router.post("/signup", signUp);
router.post("/signin", signIn);
router.post("/reset-password", resetPassword);
router.post("/send-otp", sendResetPasswordOtp);

// PROTECTED ROUTES (cần token)
router.post("/signout", protectedRoute, signOut);

router.post("/refresh", refreshToken);

export default router;