# Hướng dẫn cài đặt Upload File

## 1. Cài đặt Multer

```bash
npm install multer
```

## 2. Tạo thư mục uploads

```bash
mkdir uploads
```

## 3. Cập nhật uploadController.js

Uncomment phần code multer configuration trong `src/controllers/uploadController.js`

## 4. Cập nhật uploadRoute.js

Thay đổi từ:
```javascript
router.post("/", authMiddleware, uploadFile);
```

Thành:
```javascript
import { upload } from "../controllers/uploadController.js";
router.post("/", authMiddleware, upload.single('file'), uploadFile);
```

## 5. Cấu hình Static Files trong server.js

Thêm vào `src/server.js`:
```javascript
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Serve static files
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));
```

## 6. Sử dụng Cloud Storage (Optional)

Để upload lên cloud (AWS S3, Cloudinary, etc.), cài đặt package tương ứng:

### Cloudinary:
```bash
npm install cloudinary multer-storage-cloudinary
```

### AWS S3:
```bash
npm install @aws-sdk/client-s3 multer-s3
```

## 7. Giới hạn file size và type

Đã được cấu hình trong multer:
- Max file size: 10MB
- Allowed types: jpeg, jpg, png, gif, mp3, wav, mp4, pdf

## 8. Test Upload

Sử dụng Postman hoặc curl:
```bash
curl -X POST http://localhost:5001/api/upload \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "file=@/path/to/file.jpg" \
  -F "type=image"
```
