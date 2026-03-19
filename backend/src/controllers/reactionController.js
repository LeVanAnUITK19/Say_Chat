import Message from "../models/Message.js";

// Thêm hoặc cập nhật reaction
export const addReaction = async (req, res) => {
    try {
        const { messageId } = req.params;
        const { emoji } = req.body;
        const userId = req.user._id;

        console.log('📝 Add reaction request:', { messageId, emoji, userId: userId.toString() });

        if (!emoji) {
            return res.status(400).json({ message: "Emoji là bắt buộc" });
        }

        const message = await Message.findById(messageId);
        
        if (!message) {
            return res.status(404).json({ message: "Tin nhắn không tồn tại" });
        }

        // Kiểm tra user đã react chưa
        const existingReactionIndex = message.reactions.findIndex(
            r => r.userId.toString() === userId.toString()
        );

        if (existingReactionIndex !== -1) {
            // Nếu emoji giống nhau thì xóa reaction (toggle)
            if (message.reactions[existingReactionIndex].emoji === emoji) {
                message.reactions.splice(existingReactionIndex, 1);
                console.log('🗑️ Removed reaction');
            } else {
                // Nếu khác thì cập nhật emoji mới
                message.reactions[existingReactionIndex].emoji = emoji;
                message.reactions[existingReactionIndex].createdAt = new Date();
                console.log('🔄 Updated reaction');
            }
        } else {
            // Thêm reaction mới
            message.reactions.push({
                userId,
                emoji,
                createdAt: new Date()
            });
            console.log('✅ Added new reaction');
        }

        await message.save();

        // Populate user info cho reactions
        await message.populate('reactions.userId', 'username avatarUrl');

        return res.status(200).json({ 
            message: "Cập nhật reaction thành công",
            reactions: message.reactions
        });
    } catch (error) {
        console.error("❌ Lỗi khi thêm reaction:", error);
        return res.status(500).json({ 
            message: "Lỗi hệ thống",
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

// Xóa reaction
export const removeReaction = async (req, res) => {
    try {
        const { messageId } = req.params;
        const userId = req.user._id;

        console.log('🗑️ Remove reaction request:', { messageId, userId: userId.toString() });

        const message = await Message.findById(messageId);
        
        if (!message) {
            return res.status(404).json({ message: "Tin nhắn không tồn tại" });
        }

        // Xóa reaction của user
        message.reactions = message.reactions.filter(
            r => r.userId.toString() !== userId.toString()
        );

        await message.save();

        console.log('✅ Reaction removed');

        return res.status(200).json({ 
            message: "Xóa reaction thành công",
            reactions: message.reactions
        });
    } catch (error) {
        console.error("❌ Lỗi khi xóa reaction:", error);
        return res.status(500).json({ 
            message: "Lỗi hệ thống",
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

// Lấy danh sách reactions của một tin nhắn
export const getReactions = async (req, res) => {
    try {
        const { messageId } = req.params;

        const message = await Message.findById(messageId)
            .populate('reactions.userId', 'username avatarUrl');
        
        if (!message) {
            return res.status(404).json({ message: "Tin nhắn không tồn tại" });
        }

        return res.status(200).json({ reactions: message.reactions });
    } catch (error) {
        console.error("❌ Lỗi khi lấy reactions:", error);
        return res.status(500).json({ 
            message: "Lỗi hệ thống",
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};
