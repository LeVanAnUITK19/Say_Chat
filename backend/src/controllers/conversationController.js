import Conversation from "../models/Conversation.js";
import Message from "../models/Message.js";
import { getIO } from "../libs/socket.js";

export const createConversation = async (req, res) => {
    try {
        const { type, name, memberIds } = req.body;
        const userId = req.user._id;

        console.log('📝 Create conversation request:', { type, name, memberIds, userId: userId.toString() });

        // Validate input
        if (!type || !memberIds || !Array.isArray(memberIds) || memberIds.length === 0) {
            console.log('❌ Validation failed: missing required fields');
            return res.status(400).json({
                message: "Type và danh sách thành viên là bắt buộc"
            });
        }

        if (type === 'group' && !name) {
            console.log('❌ Validation failed: group name required');
            return res.status(400).json({
                message: "Tên nhóm là bắt buộc cho group chat"
            });
        }

        let conversation;

        if (type === 'direct') {
            // Direct chat: chỉ 2 người
            if (memberIds.length !== 1) {
                console.log('❌ Validation failed: direct chat must have exactly 1 recipient');
                return res.status(400).json({
                    message: "Direct chat chỉ có thể có 1 người nhận"
                });
            }

            const participantId = memberIds[0];
            console.log('🔍 Checking existing direct conversation...');

            // Kiểm tra conversation đã tồn tại chưa
            conversation = await Conversation.findOne({
                type: 'direct',
                "participants.userId": { $all: [userId, participantId] }
            });

            if (conversation) {
                console.log('✅ Found existing conversation:', conversation._id);
            } else {
                console.log('📝 Creating new direct conversation...');
                // Nếu chưa có, tạo mới
                conversation = new Conversation({
                    type: 'direct',
                    participants: [
                        { userId, joinedAt: new Date() },
                        { userId: participantId, joinedAt: new Date() }
                    ],
                    lastMessageAt: new Date()
                });

                await conversation.save();
                console.log('✅ Created new conversation:', conversation._id);
            }
        } else if (type === 'group') {
            console.log('📝 Creating new group conversation...');
            // Group chat: nhiều người
            conversation = new Conversation({
                type: 'group',
                participants: [
                    { userId, joinedAt: new Date() },
                    ...memberIds.map((id) => ({ userId: id, joinedAt: new Date() }))
                ],
                group: {
                    name,
                    createdBy: userId
                },
                lastMessageAt: new Date()
            });

            await conversation.save();
            console.log('✅ Created group conversation:', conversation._id);
        } else {
            console.log('❌ Invalid type:', type);
            return res.status(400).json({ message: 'Type không hợp lệ (phải là direct hoặc group)' });
        }

        // Populate thông tin
        console.log('🔄 Populating conversation data...');
        await conversation.populate([
            { path: 'participants.userId', select: 'username avatarUrl status' },
            { path: 'seenBy', select: 'username avatarUrl' },
            { path: 'lastMessage.senderId', select: 'username avatarUrl' }
        ]);

        console.log('✅ Conversation created successfully');

        // Emit new_conversation tới tất cả participants để họ cập nhật list ngay
        const io = getIO();
        conversation.participants.forEach((p) => {
            const participantId = p.userId?._id?.toString() ?? p.userId?.toString();
            if (participantId) {
                io.to(`user_${participantId}`).emit('new_conversation', { conversation });
            }
        });

        return res.status(201).json({ conversation });
    }
    catch (error) {
        console.error("❌ Lỗi khi tạo conversation:", error);
        return res.status(500).json({
            message: 'Lỗi hệ thống',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

export const getConversations = async (req, res) => {
    try {
        const userId = req.user._id;
        const username = req.user.username;
        const conversations = await Conversation.find({
            'participants.userId': userId
        })
            .sort({ lastMessageAt: -1, updatedAt: -1 })
            .populate({
                path: 'participants.userId',
                select: 'username avatarUrl'
            })
            .populate({
                path: 'lastMessage.senderId',
                select: "username avatarUrl"
            })
            .populate({
                path: "seenBy",
                select: "username avatarUrl",
            });

        const formatted = conversations.map((convo) => {
            const participants = (convo.participants || []).map((p) => ({
                _id: p.userId?._id,
                username: p.userId?.username,
                avatarUrl: p.userId?.avatarUrl ?? null,
                joinedAt: p.joinedAt,
            }));
            return {
                ...convo.toObject(),
                unreadCounts: convo.unreadCounts || {},
                participants,
            }
        });
        return res.status(200).json({ conversations: formatted });
    }
    catch (error) {
        console.error("Lỗi xảy ra khi lấy conversations", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });

    }
};

export const getConversationGroupInfo = async (req, res) => {
    try {
        const userId = req.user._id;
        const username = req.user.username;
        const conversations = await Conversation.find({
            'participants.userId': userId, type: 'group'
        })
            .sort({ lastMessageAt: -1, updatedAt: -1 })
            .populate({
                path: 'participants.userId',
                select: 'username avatarUrl'
            })
            .populate({
                path: 'lastMessage.senderId',
                select: "username avatarUrl"
            })
            .populate({
                path: "seenBy",
                select: "username avatarUrl",
            });
            

        const formatted = conversations.map((convo) => {
            const participants = (convo.participants || []).map((p) => ({
                _id: p.userId?._id,
                username: p.userId?.username,
                avatarUrl: p.userId?.avatarUrl ?? null,
                joinedAt: p.joinedAt,
            }));
            return {
                ...convo.toObject(),
                unreadCounts: convo.unreadCounts || {},
                participants,
            }
        });
        return res.status(200).json({ conversations: formatted });
    }
    catch (error) {
        console.error("Lỗi xảy ra khi lấy conversations group", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });

    }
};


export const getMessages = async (req, res) => {
    try {
        const { conversationId } = req.params;
        const { limit = 50, cursor } = req.query;
        const limitNum = Math.min(Number(limit), 100); // tối đa 100

        const query = { conversationId };
        if (cursor) {
            query.createdAt = { $lt: new Date(cursor) }; // fix typo: createAt → createdAt
        }

        let messages = await Message.find(query)
            .populate("senderId", "username avatarUrl")
            .sort({ createdAt: 1 })
            .limit(limitNum + 1);

        let nextCursor = null;
        if (messages.length > limitNum) {
            // Có thêm tin nhắn cũ hơn (pagination ngược)
            const oldest = messages[0];
            nextCursor = oldest.createdAt.toISOString();
            messages = messages.slice(1); // bỏ item thừa ở đầu
        }

        return res.status(200).json({ messages, nextCursor });
    }
    catch (error) {
        console.error("Lỗi xảy ra khi lấy messages", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
};