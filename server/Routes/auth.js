const express = require("express");
const router = express.Router();
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const sql = require("mssql");
const config = require("../config");
const verifyToken = require("../middleware/verifyToken");
const JWT_SECRET = config.JWT_SECRET;

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
		const pool = await sql.connect(config.database);

		// Check if username or email already exists in both tables
		const userCheck = await pool
			.request()
			.input("username", sql.VarChar, username)
			.input("email", sql.VarChar, email).query(`
              SELECT username, email FROM CareYou.[Caregiver] WHERE username = @username OR email = @email
              UNION
              SELECT username, email FROM CareYou.[Elderly] WHERE username = @username OR email = @email
          `);

		if (userCheck.recordset.length > 0) {
			return res.status(400).send("Username or Email already exists");
		}

		const hashedPassword = await bcrypt.hash(password, 10);

		if (role === "Caregiver") {
			if (!username || !password || !email) {
				return res
					.status(400)
					.send(
						"Username, password, and email are required for Caregiver role"
					);
			}

			if (yourelderly_email) {
				const checkelderlyemail = await pool
					.request()
					.input("yourelderly_email", sql.VarChar, yourelderly_email)
					.query(
						"SELECT * FROM CareYou.[Elderly] WHERE email = @yourelderly_email"
					);

				if (checkelderlyemail.recordset.length === 0) {
					return res
						.status(400)
						.send("Elderly user not found with provided email");
				}

				const checkRepeatemail = await pool
					.request()
					.input("yourelderly_email", sql.VarChar, yourelderly_email)
					.query(
						"SELECT * FROM CareYou.[Caregiver] WHERE yourelderly_email = @yourelderly_email"
					);

				if (checkRepeatemail.recordset.length > 0) {
					return res
						.status(400)
						.send("Elderly user already has caregiver");
				}
			}

			await pool
				.request()
				.input("username", sql.VarChar, username)
				.input("password", sql.VarChar, hashedPassword)
				.input("email", sql.VarChar, email)
				.input("role", sql.VarChar, role)
				.input("yourelderly_email", sql.VarChar, yourelderly_email)
				.input(
					"yourelderly_relation",
					sql.VarChar,
					yourelderly_relation
				)
				.query(
					"INSERT INTO CareYou.[Caregiver] (username, password, email, role, yourelderly_email, yourelderly_relation) VALUES (@username, @password, @email, @role, @yourelderly_email, @yourelderly_relation)"
				);

			if (yourelderly_email) {
				await pool
					.request()
					.input("yourcaregiver_email", sql.VarChar, email)
					.input("yourelderly_email", sql.VarChar, yourelderly_email)
					.query(
						"UPDATE CareYou.[Elderly] SET yourcaregiver_email = @yourcaregiver_email WHERE email = @yourelderly_email"
					);
			}

			res.status(201).send("Caregiver registered successfully");
		} else if (role === "Elderly") {
			if (!username || !password || !email) {
				return res
					.status(400)
					.send(
						"Username, password, and email are required for Elderly role"
					);
			}

			await pool
				.request()
				.input("username", sql.VarChar, username)
				.input("password", sql.VarChar, hashedPassword)
				.input("email", sql.VarChar, email)
				.input("role", sql.NVarChar, role)
				.query(
					"INSERT INTO CareYou.[Elderly] (username, password, email, role) VALUES (@username, @password, @email, @role)"
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
		const pool = await sql.connect(config.database);
		const userCheck = await pool
			.request()
			.input("email", sql.VarChar, email).query(`
              SELECT id, email, password, role FROM CareYou.[Caregiver] WHERE email = @email
              UNION
              SELECT id, email, password, role FROM CareYou.[Elderly] WHERE email = @email 
          `);

		if (userCheck.recordset.length === 0) {
			throw new Error("User not found");
		}

		const user = userCheck.recordset[0];
		console.log(user);
		if (user.role === selectedRole) {
		} else {
			throw new Error("Invalid role");
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
	return jwt.sign({ id: id }, JWT_SECRET, { expiresIn: "1h" });
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
