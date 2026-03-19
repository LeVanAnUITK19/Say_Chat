import express from "express";
import { addReaction, removeReaction, getReactions } from "../controllers/reactionController.js";

const router = express.Router();

// Thêm/cập nhật reaction
router.post("/:messageId", addReaction);

// Xóa reaction
router.delete("/:messageId", removeReaction);

// Lấy danh sách reactions
router.get("/:messageId", getReactions);

export default router;
