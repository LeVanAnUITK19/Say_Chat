import Conversation from "../models/Conversation.js";
import Message from "../models/Message.js";
import { updateConversationAfterCreateMessage } from "../utils/messageHelper.js";
import { getIO } from "../libs/socket.js";


export const sendDirectMessage = async (req, res) =>{
    try{
        const {recipientId, content, conversationId, username, type, attachments} = req.body;
        const senderId = req.user._id;
        let conversation;
        
        // Validate: phải có content hoặc attachments
        if(!content && (!attachments || attachments.length === 0)){
            return res.status(400).json({message: "Thiếu nội dung hoặc tệp đính kèm"});
        }
        
        if(conversationId){
            conversation = await Conversation.findById(conversationId);
        }
        if(!conversation){
            conversation = await Conversation.create({
                type: "direct",
                participants: [
                    {userId: senderId, joinedAt: new Date()},
                    {userId: recipientId, joinedAt: new Date()}
                ],
                lastMessageAt: new Date(),
                unreadCounts: new Map(),
            })
        }
        
        // Tạo message với type và attachments
        const messageData = {
            conversationId: conversation._id,
            senderId, 
            username,
            type: type || "text",
            content: content || ""
        };
        
        if(attachments && attachments.length > 0){
            messageData.attachments = attachments;
        }
        
        const message = await Message.create(messageData);
        updateConversationAfterCreateMessage(conversation, message, senderId);

        await conversation.save();

        // Populate senderId trước khi emit để client có đủ thông tin
        await message.populate('senderId', 'username avatarUrl');

        // Emit tin nhắn mới tới tất cả client trong room
        getIO().to(conversation._id.toString()).emit('new_message', { message });

        // Notify từng participant để cập nhật conversation list ở home
        const io = getIO();
        const lastMessagePreview = {
            conversationId: conversation._id.toString(),
            lastMessage: {
                content: message.content,
                type: message.type,
                senderId: { _id: message.senderId._id, username: message.senderId.username },
            },
            lastMessageAt: conversation.lastMessageAt,
        };
        conversation.participants.forEach((p) => {
            io.to(`user_${p.userId.toString()}`).emit('conversation_updated', lastMessagePreview);
        });

        return res.status(201).json({message});
    }
    catch(error){
        console.error("Lỗi xảy ra khi gửi tin nhắn trực tiếp", error);
        return res.status(500).json({message: "Lỗi hệ thống"});

    }

}

export const sendGroupMessage = async (req, res) => {
    try {
        const { conversationId, content, username, type, attachments } = req.body;
        const senderId = req.user._id;

        console.log('📝 Send group message request:', { conversationId, senderId: senderId.toString(), type });

        // Validate input
        if (!conversationId) {
            console.log('❌ Missing conversationId');
            return res.status(400).json({ message: "conversationId là bắt buộc" });
        }

        // Validate: phải có content hoặc attachments
        if (!content && (!attachments || attachments.length === 0)) {
            console.log('❌ Missing content and attachments');
            return res.status(400).json({ message: "Thiếu nội dung hoặc tệp đính kèm" });
        }

        // Load conversation
        const conversation = await Conversation.findById(conversationId);
        
        if (!conversation) {
            console.log('❌ Conversation not found');
            return res.status(404).json({ message: "Conversation không tồn tại" });
        }

        // Kiểm tra user có phải member không
        const isMember = conversation.participants.some(
            p => p.userId.toString() === senderId.toString()
        );

        if (!isMember) {
            console.log('❌ User is not a member');
            return res.status(403).json({ message: "Bạn không phải thành viên của conversation này" });
        }

        console.log('✅ Creating message...');
        
        // Tạo message với type và attachments
        const messageData = {
            conversationId: conversation._id,
            senderId,
            username,
            type: type || "text",
            content: content ? content.trim() : ""
        };
        
        if(attachments && attachments.length > 0){
            messageData.attachments = attachments;
        }
        
        const message = await Message.create(messageData);

        console.log('✅ Message created:', message._id);

        // Update conversation
        updateConversationAfterCreateMessage(conversation, message, senderId);
        await conversation.save();

        console.log('✅ Conversation updated');

        // Populate senderId trước khi emit để client có đủ thông tin
        await message.populate('senderId', 'username avatarUrl');

        // Emit tin nhắn mới tới tất cả client trong room
        getIO().to(conversation._id.toString()).emit('new_message', { message });

        // Notify từng participant để cập nhật conversation list ở home
        const io = getIO();
        const lastMessagePreview = {
            conversationId: conversation._id.toString(),
            lastMessage: {
                content: message.content,
                type: message.type,
                senderId: { _id: message.senderId._id, username: message.senderId.username },
            },
            lastMessageAt: conversation.lastMessageAt,
        };
        conversation.participants.forEach((p) => {
            io.to(`user_${p.userId.toString()}`).emit('conversation_updated', lastMessagePreview);
        });

        return res.status(201).json({ message });
    }
    catch (error) {
        console.error("❌ Lỗi xảy ra khi gửi tin nhắn nhóm:", error);
        return res.status(500).json({ 
            message: "Lỗi hệ thống",
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
}