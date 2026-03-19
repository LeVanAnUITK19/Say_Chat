import mongoose from 'mongoose'


const attachmentSchema = new mongoose.Schema({
    type: {
        type: String,
        enum: ["image", "audio", "sticker", "video", "file"],
        required: true
    },
    url: {
        type: String,
        required: true
    },
    metadata: {
        type: Object
    }
});


const reactionSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    emoji: {
        type: String,
        required: true
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
}, { _id: false });

const messageSchema = new mongoose.Schema({
    conversationId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Conversation",
        required: true,
        index: true,
    },
    senderId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    type: {
        type: String,
        enum: ["text", "image", "audio", "sticker", "file"],
        default: "text"
    },
    content: {
        type: String,
        trim: true,
    },
    attachments: [attachmentSchema],
    reactions: [reactionSchema],
},
    {
        timestamps: true
    }
);

messageSchema.index({conversationId: 1, createAt: -1});

const Message = mongoose.model("Message", messageSchema);

export default Message;