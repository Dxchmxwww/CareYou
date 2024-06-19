const express = require("express");
const router = express.Router();
const sql = require("mssql");
const config = require("../config");
const bcrypt = require("bcryptjs");
const verifyToken = require("../middleware/verifyToken");

router.get("/Caregiver", verifyToken, async (req, res) => {
	try {
		const caregiverId = req.user.id;
		const pool = await sql.connect(config);

		// Check if the user is a caregiver
		const roleCheck = await pool.request().input("id", sql.Int, caregiverId)
			.query(`
                SELECT role FROM CareYou.[Caregiver] WHERE id = @id
                UNION
                SELECT role FROM CareYou.[Elderly] WHERE id = @id
            `);

		if (roleCheck.recordset[0].role !== "Caregiver") {
			// If user is not a caregiver, send appropriate response
			return res
				.status(403)
				.send("User is not authorized as a caregiver");
		}

		// Fetch caregiver information (username, email, yourelderly_email)
		const caregiverInfoQuery = `
            SELECT username, email, password, yourelderly_email ,yourelderly_relation
            FROM CareYou.[Caregiver] 
            WHERE id = @id
        `;
		const caregiverInfoResult = await pool
			.request()
			.input("id", sql.Int, caregiverId)
			.query(caregiverInfoQuery);

		if (caregiverInfoResult.recordset.length === 0) {
			return res.status(404).send("Caregiver information not found");
		}

		const caregiverInfo = caregiverInfoResult.recordset[0];

		const elderInfoQuery = `
            SELECT username
            FROM CareYou.[Elderly]
            WHERE email = @yourelderly_email
        `;
		const elderInfoResult = await pool
			.request()
			.input(
				"yourelderly_email",
				sql.VarChar,
				caregiverInfo.yourelderly_email
			)
			.query(elderInfoQuery);

		if (elderInfoResult.recordset.length === 0) {
			return res.status(404).send("Elder information not found");
		}

		const elders = elderInfoResult.recordset;

		const currentDate = new Date().toLocaleString("en-us", {
			weekday: "short",
			day: "numeric",
			year: "numeric",
		});

		res.json({
			caregiver: {
				username: caregiverInfo.username,
				email: caregiverInfo.email,
				yourelderly_email: caregiverInfo.yourelderly_email,
				yourelderly_relation: caregiverInfo.yourelderly_relation,
			},
			elders: elders.map((elder) => ({
				username: elder.username,
				// relation: elder.yourelary_relation,
			})),
			currentDate: currentDate,
		});
	} catch (err) {
		console.error(err);
		res.status(500).send("Internal Server Error");
	}
});

router.get("/Elderly", verifyToken, async (req, res) => {
	try {
		const elderlyId = req.user.id;
		const pool = await sql.connect(config);

		// Check if the user is an elderly
		const roleCheck = await pool.request().input("id", sql.Int, elderlyId)
			.query(`
                SELECT role FROM CareYou.[Caregiver] WHERE id = @id
                UNION
                SELECT role FROM CareYou.[Elderly] WHERE id = @id
            `);

		if (roleCheck.recordset[0] == "Elderly") {
			console.log(roleCheck.recordset[0]);
			// If user is not a caregiver, send appropriate response
			return res.status(403).send("User is not authorized as a Elderly");
		}

		const elderlyInfoQuery = `
            SELECT username, email, yourcaregiver_email
            FROM CareYou.[Elderly] 
            WHERE id = @id
        `;
		const elderlyInfoResult = await pool
			.request()
			.input("id", sql.Int, elderlyId)
			.query(elderlyInfoQuery);

		if (elderlyInfoResult.recordset.length === 0) {
			return res.status(404).send("Elderly information not found");
		}

		const elderlyInfo = elderlyInfoResult.recordset[0];
		const caregiverEmail = elderlyInfo.yourcaregiver_email;

		const caregiverUsernameQuery = `
            SELECT username
            FROM CareYou.[Caregiver] 
            WHERE email = @yourcaregiver_email
        `;
		const caregiverUsernameResult = await pool
			.request()
			.input("yourcaregiver_email", sql.VarChar, caregiverEmail)
			.query(caregiverUsernameQuery);

		if (caregiverUsernameResult.recordset.length === 0) {
			return res
				.status(404)
				.send("Caregiver username information not found");
		}

		const caregiverUsername = caregiverUsernameResult.recordset[0];

		const currentDate = new Date().toLocaleString("en-us", {
			weekday: "short",
			day: "numeric",
			year: "numeric",
		});

		res.json({
			username: elderlyInfo.username,
			email: elderlyInfo.email,
			your_caregiver: caregiverUsername.username,
			currentDate: currentDate,
		});
	} catch (err) {
		console.error(err);
		res.status(500).send("Internal Server Error");
	}
});

router.put("/EditPassword", verifyToken, async (req, res) => {
	const { oldPassword, newPassword } = req.body;

	if (!oldPassword || !newPassword) {
		return res
			.status(400)
			.json({ error: "Both old password and new password are required" });
	}

	try {
		const id = req.user.id;
		const pool = await sql.connect(config);

		// Check if the user is a caregiver or elderly
		const roleCheckQuery = `
            SELECT 'Caregiver' AS role FROM CareYou.[Caregiver] WHERE id = @id
            UNION
            SELECT 'Elderly' AS role FROM CareYou.[Elderly] WHERE id = @id
        `;
		const roleCheckResult = await pool
			.request()
			.input("id", sql.Int, id)
			.query(roleCheckQuery);

		if (roleCheckResult.recordset.length === 0) {
			return res.status(404).json({ error: "User not found" });
		}

		const userRole = roleCheckResult.recordset[0].role;

		// Fetch user's current hashed password from the appropriate table
		let fetchPasswordQuery, tableName;
		if (userRole === "Caregiver") {
			fetchPasswordQuery = `
                SELECT password
                FROM CareYou.[Caregiver]
                WHERE id = @id
            `;
			tableName = "Caregiver";
		} else if (userRole === "Elderly") {
			fetchPasswordQuery = `
                SELECT password
                FROM CareYou.[Elderly]
                WHERE id = @id
            `;
			tableName = "Elderly";
		}

		const fetchPasswordResult = await pool
			.request()
			.input("id", sql.Int, id)
			.query(fetchPasswordQuery);

		if (fetchPasswordResult.recordset.length === 0) {
			return res.status(404).json({ error: "User not found" });
		}

		const hashedPassword = fetchPasswordResult.recordset[0].password;

		// Compare old password with the hashed password from the database
		const isMatch = await bcrypt.compare(oldPassword, hashedPassword);

		if (!isMatch) {
			return res.status(400).json({ error: "Invalid old password" });
		}

		// Hash the new password
		const salt = await bcrypt.genSalt(10);
		const hashedNewPassword = await bcrypt.hash(newPassword, salt);

		// Update the password in the appropriate table
		const updatePasswordQuery = `
            UPDATE CareYou.[${tableName}]
            SET password = @hashedNewPassword
            WHERE id = @id
        `;
		await pool
			.request()
			.input("hashedNewPassword", sql.VarChar, hashedNewPassword)
			.input("id", sql.Int, id)
			.query(updatePasswordQuery);

		res.status(200).json({ message: "Password updated successfully" });
	} catch (err) {
		console.error(err);
		res.status(500).json({ error: "Internal Server Error" });
	}
});

// Endpoint to fetch username
router.get("/Showusername", verifyToken, async (req, res) => {
	try {
		const id = req.user.id;
		const pool = await sql.connect(config);

		// Check if the user is a caregiver or elderly
		const roleCheckQuery = `
            SELECT 'Caregiver' AS role FROM CareYou.[Caregiver] WHERE id = @id
            UNION
            SELECT 'Elderly' AS role FROM CareYou.[Elderly] WHERE id = @id
        `;
		const roleCheckResult = await pool
			.request()
			.input("id", sql.Int, id)
			.query(roleCheckQuery);

		if (roleCheckResult.recordset.length === 0) {
			return res.status(404).json({ error: "User not found" });
		}

		const userRole = roleCheckResult.recordset[0].role;
		let usernameQuery, tableName;

		// Determine query and table based on user role
		if (userRole === "Caregiver") {
			usernameQuery = `
                SELECT username FROM CareYou.[Caregiver] WHERE id = @id
            `;
			tableName = "Caregiver";
		} else if (userRole === "Elderly") {
			usernameQuery = `
                SELECT username FROM CareYou.[Elderly] WHERE id = @id
            `;
			tableName = "Elderly";
		}

		// Fetch username from the appropriate table
		const usernameResult = await pool
			.request()
			.input("id", sql.Int, id)
			.query(usernameQuery);

		if (usernameResult.recordset.length === 0) {
			return res.status(404).json({ error: "Username not found" });
		}
		const currentDate = new Date().toLocaleString("en-us", {
			weekday: "short",
			day: "numeric",
			year: "numeric",
		});
		const username = usernameResult.recordset[0].username;

		res.status(200).json({
			username,
			currentDate,
		});
	} catch (err) {
		console.error(err);
		res.status(500).json({ error: "Internal Server Error" });
	}
});

router.put("/EditUsername", verifyToken, async (req, res) => {
	const { newUsername } = req.body;

	if (!newUsername) {
		return res.status(400).json({ error: "New username is required" });
	}

	try {
		const id = req.user.id;
		const pool = await sql.connect(config);

		// Check if the user is a caregiver or elderly
		const roleCheckQuery = `
            SELECT 'Caregiver' AS role FROM CareYou.[Caregiver] WHERE id = @id
            UNION
            SELECT 'Elderly' AS role FROM CareYou.[Elderly] WHERE id = @id
        `;
		const roleCheckResult = await pool
			.request()
			.input("id", sql.Int, id)
			.query(roleCheckQuery);

		if (roleCheckResult.recordset.length === 0) {
			return res.status(404).json({ error: "User not found" });
		}

		const userRole = roleCheckResult.recordset[0].role;
		let updateUsernameQuery, tableName;

		// Determine query and table based on user role
		if (userRole === "Caregiver") {
			updateUsernameQuery = `
                UPDATE CareYou.[Caregiver]
                SET username = @newUsername
                WHERE id = @id
            `;
			tableName = "Caregiver";
		} else if (userRole === "Elderly") {
			updateUsernameQuery = `
                UPDATE CareYou.[Elderly]
                SET username = @newUsername
                WHERE id = @id
            `;
			tableName = "Elderly";
		}

		// Update username in the appropriate table
		await pool
			.request()
			.input("newUsername", sql.NVarChar, newUsername)
			.input("id", sql.Int, id)
			.query(updateUsernameQuery);

		res.status(200).json({ message: "Username updated successfully" });
	} catch (err) {
		console.error(err);
		res.status(500).json({ error: "Internal Server Error" });
	}
});

module.exports = router;