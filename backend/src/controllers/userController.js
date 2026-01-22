
export const authMe = async (req, res) => {
    try {
        //lấy user từ req (đã được gán trong authMiddleware)
        const user = req.user;
        
        //trả về thông tin user (trừ hashedPassword)
            return res.status(200).json({   
            username: user.username,        
            email: user.email,
            avatarUrl: user.avatarUrl,
            createdAt: user.createdAt
        });
    } catch (error) {
        console.error('Lỗi lấy thông tin người dùng:', error);
        res.status(500).json({ message: 'Lỗi máy chủ' });
    }
            };