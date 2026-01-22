import bcrypt from 'bcrypt';
import User from '../models/User.js';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import Session from '../models/Session.js';
import dotenv from 'dotenv';
import nodemailer from 'nodemailer';

dotenv.config();

const ACCESS_TOKEN_TTL = '30m';
const REFRESH_TOKEN_TTL = 14 * 24 * 60 * 60 * 1000;
const OTP_TTL = 5 * 60 * 1000; // 5 phút

export const signUp = async (req, res) => {
    try {
        console.log('📝 SignUp request received:', req.body);

        const { username, password, email } = req.body;
        if (!username || !password || !email) {
            console.log('❌ Missing required fields');
            return res.status(400).json({ message: 'Vui lòng điền đầy đủ thông tin' });
        }

        console.log('🔍 Checking if user exists...');
        //Kiểm tra username hoặc email đã tồn tại chưa
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            console.log('❌ User already exists');
            return res.status(400).json({ message: 'Email đã được sử dụng' });
        }

        console.log('🔐 Hashing password...');
        //Mã hóa mật khẩu
        const hashedPassword = await bcrypt.hash(password, 10); //salt = 10

        console.log('💾 Creating user in database...');
        //Tạo người dùng mới
        const newUser = await User.create({
            username,
            hashedPassword,
            email
        });

        console.log('✅ User created successfully:', {
            id: newUser._id,
            username: newUser.username,
            email: newUser.email
        });

        // return
        return res.sendStatus(204);
    } catch (error) {
        console.error('❌ Lỗi đăng ký người dùng:', error);
        res.status(500).json({ message: 'Lỗi máy chủ' });
    }
}

export const signIn = async (req, res) => {
    try {
        //lấy inputs
        const { email, password } = req.body;
        if (!email || !password) {
            return res.status(400).json({ message: 'Vui lòng điền đầy đủ thông tin' });
        }

        //lấy hashpassword trong db để so sánh với ps input
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(401).json({ message: 'Email hoặc mật khẩu không đúng' });
        }
        const isPasswordValid = await bcrypt.compare(password, user.hashedPassword);
        if (!isPasswordValid) {
            return res.status(401).json({ message: 'Email hoặc mật khẩu không đúng' });
        }

        //nếu khớp, tạo accessToken với JWT
        const accessToken = jwt.sign(
            { userId: user._id },
            process.env.ACCESS_TOKEN_SECRET,
            { expiresIn: ACCESS_TOKEN_TTL }
        );

        //tạo refresh token

        const refreshToken = crypto.randomBytes(64).toString('hex');

        //tạo session mới để lưu refresh token
        await Session.create({
            userId: user._id,
            refreshToken: refreshToken,
            expiresAt: new Date(Date.now() + REFRESH_TOKEN_TTL) //14 ngày
        });

        //trả refresh token về tỏng cookie
        res.cookie('refreshToken', refreshToken, {
            httpOnly: true,
            secure: true, // Chỉ gửi cookie qua HTTPS
            sameSite: 'Strict', // Ngăn chặn CSRF
            maxAge: REFRESH_TOKEN_TTL
        });

        //trả access token về cho res
        return res.status(200).json({ message: `Đăng nhập thành công ${user.username}`, accessToken });

    } catch (error) {
        console.error('Lỗi đăng nhập người dùng:', error);
        res.status(500).json({ message: 'Lỗi máy chủ' });
    }
}

export const signOut = async (req, res) => {
    try {
        //lấy refresh token từ cookie
        const refreshToken = req.cookies?.refreshToken;
        if (!refreshToken) {
            return res.sendStatus(204); // No content
        }
        // Xóa session khỏi cơ sở dữ liệu
        await Session.deleteOne({ refreshToken });
        // Xóa cookie trên trình duyệt
        res.clearCookie('refreshToken', {
            httpOnly: true,
            secure: true,
            sameSite: 'Strict'
        });
        return res.sendStatus(204); // No content
    } catch (error) {
        console.error('Lỗi đăng xuất người dùng:', error);
        res.status(500).json({ message: 'Lỗi máy chủ' });
    }
}

export const sendResetPasswordOtp = async (req, res) => {
    try {
        // Tạo transporter để gửi email
        console.log('📝 SignUp request received:', req.body); 
        const { email } = req.body;
        if (!email) {
            return res.status(400).json({ message: 'Vui lòng cung cấp email' });
        }
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ message: 'Người dùng không tồn tại' });
        }
        // tạo OTP 6 số
        const otp = Math.floor(100000 + Math.random() * 900000).toString();

        user.resetPasswordOtp = crypto
            .createHash('sha256')
            .update(otp)
            .digest('hex');

        user.resetPasswordExpires = Date.now() + OTP_TTL; // 5 phút
        await user.save();

        // gửi mail
        const transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: process.env.EMAIL_USER,
                pass: process.env.EMAIL_PASS,
            },
        });

        await transporter.sendMail({
            to: email,
            subject: 'Mã xác thực đặt lại mật khẩu',
            html: `<p>Mã OTP của bạn là: <b>${otp}</b></p>
             <p>Mã có hiệu lực trong 5 phút</p>`,
        });

        res.status(200).json({ message: 'Đã gửi mã xác thực' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Lỗi máy chủ' });
    }
};

export const verifyResetPasswordOtp = async (req, res) => {
    try {
        const { email, otp } = req.body;
        if (!email || !otp) {
            return res.status(400).json({ message: 'Vui lòng điền đầy đủ thông tin' });
        }
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ message: 'Người dùng không tồn tại' });
        }
        const hashedOtp = crypto
            .createHash('sha256')
            .update(otp)
            .digest('hex');
        if (hashedOtp !== user.resetPasswordOtp || Date.now() > user.resetPasswordExpires) {
            return res.status(400).json({ message: 'Mã OTP không hợp lệ hoặc đã hết hạn' });
        }
        return res.status(200).json({ message: 'Xác thực OTP thành công' });
    } catch (error) {
        console.error('Lỗi xác thực OTP:', error);
        res.status(500).json({ message: 'Lỗi máy chủ' });
    }
};


export const resetPassword = async (req, res) => {
    try {
        const { email, otp, newPassword } = req.body;
        if (!email || !otp || !newPassword) {
            return res.status(400).json({ message: 'Vui lòng điền đầy đủ thông tin' });
        }
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ message: 'Người dùng không tồn tại' });
        }
        const hashedOtp = crypto
            .createHash('sha256')
            .update(otp)
            .digest('hex');
        if (hashedOtp !== user.resetPasswordOtp || Date.now() > user.resetPasswordExpires) {
            return res.status(400).json({ message: 'Mã OTP không hợp lệ hoặc đã hết hạn' });
        }
        const hashedPassword = await bcrypt.hash(newPassword, 10);
        user.hashedPassword = hashedPassword;
        await user.save();
        return res.status(200).json({ message: 'Đặt lại mật khẩu thành công' });
    } catch (error) {
        console.error('Lỗi đặt lại mật khẩu:', error);
        res.status(500).json({ message: 'Lỗi máy chủ' });
    }
};
export const refreshToken = async (req, res) => {
    try {
       // lấy refresh token từ cookie
        const refreshToken = req.cookies?.refreshToken;
        if (!refreshToken) {
            return res.status(401).json({ message: 'Không tìm thấy token' });
        }   
        //kiểm tra token có hợp lệ không
        const session = await Session.findOne({ refreshToken });
        if (!session || session.expiresAt < Date.now()) {
            return res.status(401).json({ message: 'Token không hợp lệ hoặc đã hết hạn' });
        }
        //tạo access token mới
        const accessToken = jwt.sign(
            { userId: session.userId },
            process.env.ACCESS_TOKEN_SECRET,
            { expiresIn: ACCESS_TOKEN_TTL }
        );
        
        return res.status(200).json({ accessToken });
    } catch (error) {
        console.error('Lỗi khi gọi refreshtoken:', error);
        res.status(500).json({ message: 'Lỗi máy chủ' });
    }
};
// Logic for user sign-in

