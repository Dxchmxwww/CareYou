const express = require('express');
const router = express.Router();
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const sql = require('mysql2');
const config = require("../config");
const verifyToken = require("../middleware/verifyToken");
const JWT_SECRET = config.JWT_SECRET;
const {pool} = require("../config"); 

//-----------------------------------Register------------------------------------

//http://localhost:8000/auth/register
router.post("/register", async (req, res) => {
	const {
	  username,
	  password,
	  email,
	  role,
	  yourelderly_email,
	  yourelderly_relation,
	} = req.body;
  
	if (!role || (role !== "Caregiver" && role !== "Elderly")) {
	  return res.status(400).send("Invalid role");
	}
  
	try {
	  // Check if username or email already exists in both tables
	  const [userCheck] = await pool.promise().query(`
		SELECT username, email FROM careyou.Caregiver WHERE username = ? OR email = ?
		UNION
		SELECT username, email FROM careyou.Elderly WHERE username = ? OR email = ?
	  `, [username, email, username, email]);
  
	  if (userCheck.length > 0) {
		return res.status(400).send("Username or Email already exists");
	  }
  
	  // Hash the password
	  const hashedPassword = await bcrypt.hash(password, 10);
  
	  if (role === "Caregiver") {
		if (!username || !password || !email) {
		  return res.status(400).send("Username, password, and email are required for Caregiver role");
		}
  
		if (yourelderly_email) {
		  // Check if elderly user exists
		  const [checkelderlyemail] = await pool.promise().query(
			"SELECT * FROM careyou.Elderly WHERE email = ?", [yourelderly_email]
		  );
  
		  if (checkelderlyemail.length === 0) {
			return res.status(402).send("Elderly user not found with provided email");
		  }
  
		  // Check if elderly already has a caregiver
		  const [checkRepeatemail] = await pool.promise().query(
			"SELECT * FROM careyou.Caregiver WHERE yourelderly_email = ?", [yourelderly_email]
		  );
  
		  if (checkRepeatemail.length > 0) {
			return res.status(401).send("Elderly user already has caregiver");
		  }
		}
  
		// Insert caregiver into the database
		await pool.promise().query(
		  "INSERT INTO careyou.Caregiver (username, password, email, role, yourelderly_email, yourelderly_relation) VALUES (?, ?, ?, ?, ?, ?)",
		  [username, hashedPassword, email, role, yourelderly_email, yourelderly_relation]
		);
  
		if (yourelderly_email) {
		  await pool.promise().query(
			"UPDATE careyou.Elderly SET yourcaregiver_email = ? WHERE email = ?",
			[email, yourelderly_email]
		  );
		}
  
		res.status(201).send("Caregiver registered successfully");
	  } else if (role === "Elderly") {
		if (!username || !password || !email) {
		  return res.status(400).send("Username, password, and email are required for Elderly role");
		}
  
		await pool.promise().query(
		  "INSERT INTO careyou.Elderly (username, password, email, role) VALUES (?, ?, ?, ?)",
		  [username, hashedPassword, email, role]
		);
  
		res.status(201).send("Elderly registered successfully");
	  }
  
	} catch (error) {
	  console.error(error);
	  res.status(500).send("Server error");
	}
  });

//-----------------------------------Login------------------------------------------

//http://localhost:8000/auth/login
//-----------------------------------Authentication------------------------------------
async function authenticateUser(email, password, selectedRole) {
	try {
		
		const [userCheck] = await pool.promise().query(`
			SELECT id, email, password, role 
			FROM careyou.Caregiver 
			WHERE email = ?
			UNION
			SELECT id, email, password, role 
			FROM careyou.Elderly 
			WHERE email = ?
		  `, [email, email]);

		  if (!userCheck || userCheck.length === 0) {
			return res.status(400).send('No user found with that email');
		  }
		  
		  const user = userCheck[0];

		
		if (user.role !== selectedRole) {
			const error = new Error("Invalid role. Please ensure you are filling correct role.");
			error.statusCode = 402;
			throw error;
		}

		const isPasswordValid = await bcrypt.compare(password, user.password);
		if (!isPasswordValid) {
			throw new Error("Invalid credentials");
		}
		console.log(user.id);

		const token = generateToken(user.id);
		const role = user.role; // Generate token with user's email and role

		return { token, role }; // Return token and user's role
	} catch (error) {
		throw new Error(`Authentication failed: ${error.message}`);
	}
}

function generateToken(id) {
	return jwt.sign({ id }, JWT_SECRET, { expiresIn: "7d" });
}

router.post("/login", async (req, res) => {
	const { email, password, selectedRole } = req.body;
	console.log(`Login attempt: email=${email}, role=${selectedRole}`);
	try {
		const { token, role } = await authenticateUser(
			email,
			password,
			selectedRole
		); // Assuming authenticateUser returns both token and role

		// Set cookie with JWT token
		res.cookie("authToken", token, {
			httpOnly: true,
			maxAge: 3600000, // 1 hour in milliseconds
			secure: process.env.NODE_ENV === "production", // Set to true in production
		});

		// Respond with token, role, and message
		res.status(200).json({ message: "Login successful", token, role });
	} catch (error) {
		if (error.code === "ECONNREFUSED") {
			return res.status(503).json({
				error: "Server is currently unavailable, please try again later.",
			});
		}
		console.log(error);
		res.status(401).json({
			error: "Please check your email and password and try again",
		});
	}
});

//-----------------------------------Logout------------------------------------

const blacklist = new Set();

const checkBlacklist = (req, res, next) => {
	const token = req.headers["authorization"]?.split(" ")[1];
	if (blacklist.has(token)) {
		return res.status(401).send("Token has been invalidated");
	}
	next();
};

//http://localhost:8000/auth/logout

router.get("/logout", (req, res) => {
	res.clearCookie("authToken");
	res.status(200).json({ message: "Logged out successfully" });
});

module.exports = router;
