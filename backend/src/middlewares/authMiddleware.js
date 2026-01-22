import jwt from 'jsonwebtoken';
import User from '../models/User.js';

export const protectedRoute = async (req, res, next) => {
    try {
        //lấy token từ header
        const authHeader = req.headers["authorization"];
        const token = authHeader && authHeader.split(' ')[1];
        if (!token) {
            return res.status(401).json({ message: 'Không có token, vui lòng đăng nhập' });
        }
        //xác minh token
        jwt.verify(token, process.env.ACCESS_TOKEN_SECRET, async (err, decoded) => {
            if (err) {
                return res.status(403).json({ message: 'Token không hợp lệ hoặc đã hết hạn' });
            }

            const user = await User.findById(decoded.userId).select('-hashedPassword');
            if (!user) {
                return res.status(401).json({ message: 'Người dùng không tồn tại' });
            }
            //trả usreqvề trong req
            req.user = user;
            next();
        });


    } catch (error) {
        console.error('Lỗi xác thực người dùng ở jwt trong authMiddleware:', error);
        res.status(500).json({ message: 'Lỗi máy chủ' });
    }
};
