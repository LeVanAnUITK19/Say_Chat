import Conversation from '../models/Conversation.js';

export const loadConversation = async (req, res, next) => {
    try {
        const { conversationId } = req.body;
        
        if (!conversationId) {
            return res.status(400).json({ message: 'conversationId là bắt buộc' });
        }

        const conversation = await Conversation.findById(conversationId);
        
        if (!conversation) {
            return res.status(404).json({ message: 'Conversation không tồn tại' });
        }

        // Kiểm tra user có phải member không
        const userId = req.user._id.toString();
        const isMember = conversation.participants.some(
            p => p.userId.toString() === userId
        );

        if (!isMember) {
            return res.status(403).json({ message: 'Bạn không phải thành viên của conversation này' });
        }

        req.conversation = conversation;
        next();
    } catch (error) {
        console.error('Lỗi khi load conversation:', error);
        return res.status(500).json({ message: 'Lỗi hệ thống' });
    }
};
