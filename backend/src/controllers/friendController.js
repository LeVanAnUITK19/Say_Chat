import mongoose from 'mongoose';
import Friend from '../models/Friend.js';
import User from '../models/User.js';
import FriendRequest from '../models/FriendRequest.js';

export const sendFriendRequest = async (req, res) => {
    try {
        const { to, message } = req.body;

        const from = req.user._id;

        if (from === to) {
            return res.status(400).json({ message: "Không thể gửi lời mời cho chính mình" });
        }

        const userExists = await User.exists({ _id: to });

        if (!userExists) {
            return res.status(404).json({ message: "Người dùng không tồn tại" })
        }

        let userA = from.toString();
        let userB = to.toString();

        if (userA > userB) {
            [userA, userB] = [userB, userA];
        }

        const [alreadyFriends, existingRequest] = await Promise.all([
            Friend.findOne({ userA, userB }),
            FriendRequest.findOne({
                $or: [
                    { from, to },
                    { from: to, to: from }
                ]
            })
        ])
        if (alreadyFriends) {
            return res.status(400).json({ message: "Hai người đã là bạn bè" })
        }
        if (existingRequest) {
            return res.status(400).json({ message: "Đã  có lời mời kết bạn đang chờ" });
        }

        const request = await FriendRequest.create({
            from,
            to,
            message,
        })

        return res.status(201).json({ message: "Gửi lời mời kết bạn  thành công", request });

    }
    catch (error) {
        console.error("Lỗi khi gửi yêu cầu kết bạn", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });

    }

};

export const acceptFriendRequest = async (req, res) => {
    try {
        const { requestId } = req.params;
        const userId = req.user._id;
        const request = await FriendRequest.findById(requestId);
        if (!request) {
            return res.status(404).json({ message: "Không tìm thấy lời mời kết bạn" })
        }
        if (request.to.toString() !== userId.toString()) {
            return res.status(403).json({ message: "Bạn không có quyền chấp nhận lời mời này" });
        }

        // Sắp xếp userA và userB để đảm bảo tính nhất quán
        let userA = request.from.toString();
        let userB = request.to.toString();
        
        if (userA > userB) {
            [userA, userB] = [userB, userA];
        }

        const friend = await Friend.create({
            userA: new mongoose.Types.ObjectId(userA),
            userB: new mongoose.Types.ObjectId(userB)
        })

        await FriendRequest.findByIdAndDelete(requestId);

        const from = await User.findById(request.from).select('_id username avatarUrl status').lean();

        return res.status(200).json({
            message: 'Chấp nhận lời mời kết bạn thành công',
            newFriend: {
                _id: from?._id,
                username: from?.username,
                avatarUrl: from?.avatarUrl,
                status: from?.status
            }
        })
    }
    catch (error) {
        console.error("Lỗi khi chấp nhận lời mời kết bạn", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });

    }
};

export const declineFriendRequest = async (req, res) => {
    try {
        const {requestId} = req.params;
        const userId = req.user._id;

        const request = await FriendRequest.findById(requestId);
        if(!request){
            return res.status(404).json({message: "Không tìm thấy lời mời kết bạn"})
        }
        if(request.to.toString() !== userId.toString()){
            return res.status(403).json({message: "Bạn không có quyền từ chối lời mời này"})
        }
        await FriendRequest.findByIdAndDelete(requestId);
        return res.sendStatus(204);

    }
    catch (error) {
        console.error("Lỗi khi từ chối lời mời kết bạn", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });

    }
};

export const getAllFriends = async (req, res) => {
    try {
        const userId = req.user._id.toString();
        
        // Tìm tất cả các mối quan hệ bạn bè của user
        const friendships = await Friend.find({
            $or: [
                { userA: userId },
                { userB: userId }
            ]
        })
        .populate("userA", "_id username avatarUrl status")
        .populate("userB", "_id username avatarUrl status")
        .lean();

        if(!friendships.length){
            return res.status(200).json({friends: []});
        }

        const friends = friendships.map((f) => 
            f.userA._id.toString() === userId.toString() ? f.userB : f.userA);

        return res.status(200).json({friends})

    } catch (error) {
        console.error("Lỗi khi lấy danh sách bạn bè", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
};

export const getFriendOnlineStatus = async (req, res) => {
    try {
        const userId = req.user._id.toString();
        const friendships = await Friend.find({
            $or: [
                { userA: userId },
                { userB: userId }
            ]
        }).lean();

        const friendIds = friendships.map(f =>
            f.userA.toString() === userId ? f.userB.toString() : f.userA.toString()
        );

        const friends = await User.find({ _id: { $in: friendIds }, status: 'online' })
            .select('_id username avatarUrl status')
            .lean();

        return res.status(200).json({ friends });
    } catch (error) {
        console.error("Lỗi khi lấy trạng thái online của bạn bè", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
};

export const getFriendRequest = async (req, res) => {
    try {
        const userId = req.user._id;

    const populateFields = '_id username avatarUrl status';

    const [sent, received] = await Promise.all([
        FriendRequest.find({from: userId}).populate("to", populateFields),
        FriendRequest.find({to: userId}).populate("from", populateFields)
    ])
    res.status(200).json({sent, received});
    } catch (error) {
        console.error("Lỗi khi lấy danh sách lời mời kết bạn", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
};

export const searchUsers = async (req, res) => {
    try {
        const { q } = req.query;
        const currentUserId = req.user._id.toString();
        
        if (!q || q.trim().length === 0) {
            return res.status(400).json({ message: "Vui lòng nhập từ khóa tìm kiếm" });
        }

        const keyword = q.trim();
        
        // Kiểm tra xem keyword có phải email không
        const isEmail = keyword.includes('@');
        
        let users;
        if (isEmail) {
            // Tìm theo email (chính xác)
            users = await User.find({ 
                email: keyword,
                _id: { $ne: currentUserId }
            }).select('_id username email avatarUrl status').lean();
        } else {
            // Tìm theo username (gần đúng)
            users = await User.find({ 
                username: { $regex: keyword, $options: 'i' },
                _id: { $ne: currentUserId }
            }).select('_id username email avatarUrl status').lean();
        }

        // Kiểm tra friendship status của từng user
        const usersWithFriendshipStatus = await Promise.all(users.map(async (user) => {
            // Kiểm tra đã là bạn bè chưa
            let userA = currentUserId;
            let userB = user._id.toString();
            if (userA > userB) {
                [userA, userB] = [userB, userA];
            }
            
            const isFriend = await Friend.findOne({ userA, userB });
            if (isFriend) {
                return { ...user, friendshipStatus: 'friend' };
            }
            
            // Kiểm tra đã gửi lời mời chưa
            const pendingRequest = await FriendRequest.findOne({
                from: currentUserId,
                to: user._id
            });
            
            if (pendingRequest) {
                return { ...user, friendshipStatus: 'pending' };
            }
            
            return { ...user, friendshipStatus: 'none' };
        }));

        return res.status(200).json({ users: usersWithFriendshipStatus });

    } catch (error) {
        console.error("Lỗi khi tìm kiếm người dùng", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
};