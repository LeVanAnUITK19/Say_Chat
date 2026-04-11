import multer from 'multer';
import path from 'path';
import { fileURLToPath } from 'url';
import fs from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Tạo thư mục uploads nếu chưa có
const uploadDir = path.join(__dirname, '../../uploads');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

// Cấu hình storage cho multer
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniqueSuffix + path.extname(file.originalname));
    }
});

// Cấu hình multer
export const upload = multer({ 
    storage: storage,
    limits: { fileSize: 50 * 1024 * 1024 }, // 50MB
    fileFilter: (req, file, cb) => {
        const allowedTypes = /jpeg|jpg|png|gif|mp3|wav|m4a|aac|mp4|avi|mov|pdf|doc|docx/;
        const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
        const mimetype = allowedTypes.test(file.mimetype) || file.mimetype.includes('audio') || file.mimetype.includes('video');
        
        if (mimetype || extname) {
            return cb(null, true);
        } else {
            cb(new Error('File type not allowed'));
        }
    }
});

// Controller xử lý upload file
export const uploadFile = async (req, res) => {
    try {
        console.log('📤 Upload request received');
        console.log('req.file:', req.file);
        console.log('req.files:', req.files);
        console.log('req.body:', req.body);
        console.log('req.headers:', req.headers);
        
        if (!req.file && !req.files) {
            console.log('❌ No file in request');
            return res.status(400).json({ message: "Không có file được upload" });
        }

        const file = req.file || (req.files && req.files[0]);
        
        console.log('✅ File received:', file.filename);
        
        // Tạo URL cho file - ưu tiên relative path để tránh hardcode IP
        const baseUrl = process.env.BASE_URL;
        const fileUrl = baseUrl
            ? `${baseUrl}/uploads/${file.filename}`
            : `/uploads/${file.filename}`;  // relative path khi không có BASE_URL
        
        return res.status(200).json({
            url: fileUrl,
            type: req.body.type || 'file',
            filename: file.filename,
            originalname: file.originalname,
            size: file.size,
            message: 'Upload thành công'
        });
    } catch (error) {
        console.error("❌ Lỗi khi upload file:", error);
        return res.status(500).json({ message: "Lỗi hệ thống", error: error.message });
    }
};
