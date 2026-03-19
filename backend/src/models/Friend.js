import mongoose from "mongoose";


const friendSchema = new mongoose.Schema({
    userA: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    userB: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    }
},
    {
        timestamps: true,
    });

friendSchema.index({userA: 1, userB: 1}, {unique: true});

const Friend = mongoose.model('Friend', friendSchema);

export default Friend;