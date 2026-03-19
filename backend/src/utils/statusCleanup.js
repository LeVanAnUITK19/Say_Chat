import Session from '../models/Session.js';
import User from '../models/User.js';

/**
 * Cleanup job để set status offline cho users có session hết hạn
 * Chạy mỗi 5 phút
 */
export const startStatusCleanup = () => {
    const CLEANUP_INTERVAL = 5 * 60 * 1000; // 5 phút

    const cleanupExpiredSessions = async () => {
        try {
            // Tìm tất cả sessions đã hết hạn
            const expiredSessions = await Session.find({
                expiresAt: { $lt: new Date() }
            }).select('userId');

            if (expiredSessions.length > 0) {
                const expiredUserIds = expiredSessions.map(s => s.userId);
                
                // Kiểm tra xem user còn session nào active không
                const usersWithActiveSessions = await Session.find({
                    userId: { $in: expiredUserIds },
                    expiresAt: { $gte: new Date() }
                }).distinct('userId');

                // Chỉ set offline cho users không còn session nào active
                const usersToSetOffline = expiredUserIds.filter(
                    userId => !usersWithActiveSessions.some(
                        activeId => activeId.toString() === userId.toString()
                    )
                );

                if (usersToSetOffline.length > 0) {
                    await User.updateMany(
                        { _id: { $in: usersToSetOffline }, status: 'online' },
                        { status: 'offline' }
                    );
                    console.log(`✅ Set ${usersToSetOffline.length} users to offline`);
                }
            }
        } catch (error) {
            console.error('❌ Error in status cleanup:', error);
        }
    };

    // Chạy ngay lần đầu
    cleanupExpiredSessions();

    // Sau đó chạy định kỳ
    setInterval(cleanupExpiredSessions, CLEANUP_INTERVAL);
    
    console.log('🔄 Status cleanup job started (runs every 5 minutes)');
};
