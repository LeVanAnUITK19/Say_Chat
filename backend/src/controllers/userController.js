import UserModel from '../models/User.js';



export const authMe = async (req, res) => {
    try {
        //lấy user từ req (đã được gán trong authMiddleware)
        const user = req.user;

        //trả về thông tin user (trừ hashedPassword)
        return res.status(200).json({
            id: user._id,
            username: user.username,
            email: user.email,
            avatarUrl: user.avatarUrl,
            qrCode: user.qrCode,
            status: user.status,
            createdAt: user.createdAt
        });
    } catch (error) {
        console.error('Lỗi lấy thông tin người dùng:', error);
        res.status(500).json({ message: 'Lỗi máy chủ' });
    }
};

export const heartbeat = async (req, res) => {
    try {
        const userId = req.user._id;
        
        // Cập nhật status thành online và timestamp
        await UserModel.findByIdAndUpdate(userId, { 
            status: 'online',
            lastActive: new Date()
        });
        
        return res.sendStatus(204);
    } catch (error) {
        console.error('Lỗi heartbeat:', error);
        res.status(500).json({ message: 'Lỗi máy chủ' });
    }
};

export const findUser = async (req, res) => {
    try {
       
        const { email } = req.params;
       
        const users = await UserModel.find({ email: { $regex: email, $options: 'i' } }).select('-hashedPassword');
        return res.status(200).json({ users });

    } catch (error) {
        console.error('Lỗi lấy thông tin người dùng khác:', error);
        res.status(500).json({ message: 'Lỗi máy chủ' });
    }
};

export const getUserById = async (req, res) => {
    try {
        const { userId } = req.params;
        const currentUserId = req.user._id.toString();

        const user = await UserModel.findById(userId)
            .select('_id username email avatarUrl status createdAt');

        if (!user) {
            return res.status(404).json({ message: 'Không tìm thấy người dùng' });
        }

        // Kiểm tra friendship status
        const Friend = (await import('../models/Friend.js')).default;
        const FriendRequest = (await import('../models/FriendRequest.js')).default;

        let userA = currentUserId;
        let userB = userId;
        if (userA > userB) [userA, userB] = [userB, userA];

        const isFriend = await Friend.findOne({ userA, userB });
        let friendshipStatus = 'none';

        if (isFriend) {
            friendshipStatus = 'friend';
        } else {
            const pending = await FriendRequest.findOne({
                $or: [
                    { from: currentUserId, to: userId },
                    { from: userId, to: currentUserId }
                ]
            });
            if (pending) {
                friendshipStatus = pending.from.toString() === currentUserId ? 'pending_sent' : 'pending_received';
            }
        }

        return res.status(200).json({
            id: user._id,
            username: user.username,
            email: user.email,
            avatarUrl: user.avatarUrl,
            status: user.status,
            createdAt: user.createdAt,
            friendshipStatus,
        });
    } catch (error) {
        console.error('Lỗi lấy thông tin user:', error);
        res.status(500).json({ message: 'Lỗi máy chủ' });
    }
};

export const findUserByQrCode = async (req, res) => {
    try {
        const { qrCode } = req.params;
        
        const user = await UserModel.findOne({ qrCode })
            .select('-hashedPassword -resetPasswordOtp -resetPasswordExpires');
        
        if (!user) {
            return res.status(404).json({ message: 'Không tìm thấy người dùng' });
        }
        
        // Trả về object với các field riêng lẻ thay vì nested user object
        return res.status(200).json({
            id: user._id,
            username: user.username,
            email: user.email,
            avatarUrl: user.avatarUrl,
            qrCode: user.qrCode,
            status: user.status,
            createdAt: user.createdAt
        });
    } catch (error) {
        console.error('Lỗi tìm user bằng QR:', error);
        res.status(500).json({ message: 'Lỗi máy chủ' });
    }
};



export const updateAvatar = async (req, res) => {
    try {
        const userId = req.user._id;
        const { avatarUrl } = req.body;

        if (!avatarUrl) {
            return res.status(400).json({ message: 'avatarUrl là bắt buộc' });
        }

        const updatedUser = await UserModel.findByIdAndUpdate(
            userId,
            { avatarUrl },
            { new: true }
        ).select('-hashedPassword');

        return res.status(200).json({
            id: updatedUser._id,
            username: updatedUser.username,
            email: updatedUser.email,
            avatarUrl: updatedUser.avatarUrl,
            status: updatedUser.status,
        });
    } catch (error) {
        console.error('Lỗi cập nhật avatar:', error);
        res.status(500).json({ message: 'Lỗi máy chủ' });
    }
};
