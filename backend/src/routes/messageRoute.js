import express from "express";
import { checkFriendship } from "../middlewares/friendMiddleware.js";

import {
    sendDirectMessage,
    sendGroupMessage
} from '../controllers/messageController.js';

const router = express.Router();

router.post('/direct',checkFriendship, sendDirectMessage);
router.post('/group', sendGroupMessage);

export default router;
