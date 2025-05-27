const express = require('express');
const userController = require('./controllers/userController');
const { authenticateToken, requireAdmin } = require('./auth');

const router = express.Router();

router.post('/login', userController.loginUser); 
router.put('/:id', authenticateToken, userController.updateUser);
router.put('/admin-action', authenticateToken, requireAdmin, userController.adminAction);

module.exports = router;