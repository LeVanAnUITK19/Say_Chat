export const updateConversationAfterCreateMessage = (conversation, message, senderId) => {
    // Tạo preview content dựa trên type của message
    let previewContent = message.content;
    
    if(message.type !== "text" && (!message.content || message.content.trim() === "")){
        // Nếu không có text content, hiển thị type của message
        const typeLabels = {
            image: "📷 Hình ảnh",
            audio: "🎵 Tin nhắn thoại",
            sticker: "😊 Sticker",
            video: "🎥 Video",
            file: "📎 Tệp đính kèm"
        };
        previewContent = typeLabels[message.type] || "📎 Tệp đính kèm";
    }
    
    conversation.set({
        seenBy: [],
        lastMessageAt: message.createdAt,
        lastMessage: {
            _id: message._id,
            content: previewContent,
            senderId,
            createAt: message.createAt,
            type: message.type
        }
    });

    conversation.participants.forEach((p) => {
        const memberId = p.userId.toString();
        const isSender = memberId === senderId.toString();
        const prevCount = conversation.unreadCounts.get(memberId) || 0;
        conversation.unreadCounts.set(memberId, isSender ? 0 : prevCount + 1)
    })
}