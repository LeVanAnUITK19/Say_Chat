import express from 'express';
import { createConversation, getConversations, getMessages, getConversationGroupInfo } from '../controllers/conversationController.js';
import { checkFriendship } from '../middlewares/friendMiddleware.js';

const router = express.Router();

router.post('/', createConversation);
router.get('/', getConversations);

router.get('/group', getConversationGroupInfo); // Lấy conversations nhóm
router.get('/:conversationId/messages', getMessages);

export default router;


