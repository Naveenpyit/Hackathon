import { Router } from "oak";
import { designationController } from "../controllers/designationController.ts";

const router = new Router();

// Get all designations (for dropdown in frontend)
router.get("/api/designations", designationController.getAll);

export const designationRouter = router;