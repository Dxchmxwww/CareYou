const jwt = require('jsonwebtoken');
const config = require('../config');

const JWT_SECRET = config.JWT_SECRET;

function verifyToken(req, res, next) {
    const token = req.cookies.authToken;

    if (!token) {
        return res.status(401).json({ error: 'Unauthorized' });
    }

    jwt.verify(token, JWT_SECRET, (err, decoded) => {
        if (err) {
            return res.status(401).json({ error: 'Invalid token' });
        }
        req.user = { id: decoded.id }; 
        next();
    });
}

module.exports = verifyToken;
