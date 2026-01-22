import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
    username: {
        type: String,
        required: true,
        unique: true,
        trim: true,
        lowercase: true

    },
    hashedPassword: {
        type: String,
        required: true
    },
    email: {
        type: String,
        required: true,
        unique: true,
        trim: true,
        lowercase: true
    },
    resetPasswordOtp: {
        type: String
    },
    resetPasswordExpires: {
        type: Date
    },
    avatarUrl: {
        type: String, // link CDN để hiển thị
    },
    avatarId: {
        type: String, // id ảnh trên cloudinary để xóa ảnh
    } ,
    

},
    { timestamps: true });

const User = mongoose.model("User", userSchema);
export default User;