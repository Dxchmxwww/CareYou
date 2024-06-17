const jwt = require('jsonwebtoken');
const config = require('../config');

const JWT_SECRET = config.JWT_SECRET;

function verifyToken(req, res, next) {
	const bearerHeader = req.cookies.authToken;

	if (!bearerHeader) {
		return res.status(401).json({ error: "Unauthorized" });
	}

	const bearerToken = bearerHeader.split(" ")[1];
    console.log(bearerToken);
	jwt.verify(bearerToken, JWT_SECRET, (err, decoded) => {
		if (err) {
            console.log(err);
			return res.status(401).json({ error: "Invalid token" });
            
		}
		req.user = { id: decoded.id };
		next();
	});
}

module.exports = verifyToken;