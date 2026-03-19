import express from 'express'

import{
    acceptFriendRequest,
    sendFriendRequest,
    declineFriendRequest,
    getAllFriends,
    getFriendRequest,
    searchUsers,
    getFriendOnlineStatus

}from '../controllers/friendController.js';


const router = express.Router();

router.post('/requests', sendFriendRequest);
router.post('/requests/:requestId/accept', acceptFriendRequest);
router.post('/requests/:requestId/decline', declineFriendRequest);

router.get('/search', searchUsers);
router.get('/', getAllFriends);
router.get('/online-status', getFriendOnlineStatus);
router.get('/requests', getFriendRequest);


export default router;