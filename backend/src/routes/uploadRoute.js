import express from "express";
import { uploadFile, upload } from "../controllers/uploadController.js";
import { protectedRoute } from "../middlewares/authMiddleware.js";

const router = express.Router();

// Logging middleware
router.use((req, res, next) => {
    console.log('🔵 Upload route hit:', req.method, req.path);
    console.log('Headers:', req.headers);
    next();
});

// Route upload file - yêu cầu authentication
router.post("/", protectedRoute, upload.single('file'), uploadFile);

export default router;
