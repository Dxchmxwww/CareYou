const jwt = require("jsonwebtoken");
const config = require("../config");

const JWT_SECRET = config.JWT_SECRET;


function verifyToken(req, res, next) {
	const bearerHeader = req.headers["authorization"] || req.cookies.authToken || req.headers.authorization;
	if (!bearerHeader) {
		return res.status(401).json({ error: "Unauthorized" });
	}

	const bearerToken = bearerHeader.split(" ")[1];
	console.log("Bearer Token received for verification:", bearerToken); 
	jwt.verify(bearerToken, JWT_SECRET, (err, decoded) => {
		if (err) {
			console.error("Token verification failed:", err);
			return res.status(401).json({ error: "Invalid token", err });
		}
		req.user = { id: decoded.id };
		console.log("User ID extracted from token:", decoded.id);
		next();
	});
}

module.exports = verifyToken;
