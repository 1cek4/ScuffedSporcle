const User = require('../models/user');
const { generateToken } = require('../jwt');

const userController = {
    loginUser: async (req, res) => {
        const { username, password } = req.body;
        const user = await User.findUserByUsername(username);
        if (!user || user.Password !== password) { 
            return res.status(401).json({ message: 'Invalid credentials' });
        }
        const token = generateToken(user);
        res.json({ token });
    },
    updateUser: (req, res) => {
        res.status(200).json({ message: 'User updated ' });
    },
    adminAction: (req, res) => {
        res.status(200).json({ message: 'Admin action performed!' });
    }
};

module.exports = userController;