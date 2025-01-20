const express = require("express");
const router = express.Router();
const sql = require('mysql2');
const config = require("../config");
const bcrypt = require("bcryptjs");
const verifyToken = require("../middleware/verifyToken");
const {pool} = require("../config");

router.get("/Caregiver", verifyToken, async (req, res) => {
	try {
		const caregiverId = req.user.id;

		// Check if the user is a caregiver
		const [roleCheck] = await pool.promise().query(`
            SELECT role FROM careyou.Caregiver WHERE id = ?
            UNION
            SELECT role FROM careyou.Elderly WHERE id = ?
        `, [caregiverId, caregiverId]);


		if (roleCheck.length === 0 || roleCheck[0].role !== "Caregiver") {
			// If user is not a caregiver, send appropriate response
			return res
				.status(403)
				.send("User is not authorized as a caregiver");
		}

		// Fetch caregiver information (username, email, yourelderly_email)
		const [caregiverInfoResult] = await pool.promise().query(`
            SELECT username, email, password, yourelderly_email ,yourelderly_relation
            FROM careyou.Caregiver
            WHERE id = ?
        `, [caregiverId]);

		if (caregiverInfoResult.length === 0) {
			return res.status(404).send("Caregiver information not found");
		}

		const caregiverInfo = caregiverInfoResult[0];

		// Fetch elder information based on the caregiver's 'yourelderly_email'
		const [elderInfoResult] = await pool.promise().query(`
            SELECT username
            FROM careyou.Elderly
            WHERE email = ?
        `, [caregiverInfo.yourelderly_email]);

		if (elderInfoResult.length === 0) {
			return res.status(404).send("Elder information not found");
		}

		const elders = elderInfoResult;

		// Get current date in a consistent format
		const currentDate = new Date().toLocaleString("en-us", {
			weekday: "short",
			day: "numeric",
			year: "numeric",
		});

		// Send response
		res.json({
			caregiver: {
				username: caregiverInfo.username,
				email: caregiverInfo.email,
				yourelderly_email: caregiverInfo.yourelderly_email,
				yourelderly_relation: caregiverInfo.yourelderly_relation,
			},
			elders: elders.map((elder) => ({
				username: elder.username,
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
  
	  // Check if the user is an elderly using promise-based queries
	  const roleCheck = await pool.promise().query(`
		SELECT role FROM careyou.Caregiver WHERE id = ?
		UNION
		SELECT role FROM careyou.Elderly WHERE id = ?`,
		[elderlyId, elderlyId]
	  );
  
	  if (roleCheck[0].length === 0 || roleCheck[0][0].role !== "Elderly") {
		// If user is not an elderly, send appropriate response
		return res.status(403).send("User is not authorized as an Elderly");
	  }
  
	  // Fetch elderly information using parameterized queries
	  const elderlyInfoResult = await pool.promise().query(`
		SELECT username, email, yourcaregiver_email
		FROM careyou.Elderly
		WHERE id = ?`, [elderlyId]);
  
	  if (elderlyInfoResult[0].length === 0) {
		return res.status(404).send("Elderly information not found");
	  }
  
	  const elderlyInfo = elderlyInfoResult[0][0];
	  const caregiverEmail = elderlyInfo.yourcaregiver_email;
  
	  // Fetch caregiver username based on email
	  let caregiverUsername = "You don't have a caregiver.";
	  if (caregiverEmail) {
		const caregiverUsernameResult = await pool.promise().query(`
		  SELECT username
		  FROM careyou.Caregiver
		  WHERE email = ?`, [caregiverEmail]);
  
		if (caregiverUsernameResult[0].length > 0) {
		  caregiverUsername = caregiverUsernameResult[0][0].username;
		}
	  }
  
	  // Format current date consistently
	  const currentDate = new Date().toLocaleString("en-us", {
		weekday: "short",
		day: "numeric",
		year: "numeric",
	  });
  
	  res.json({
		username: elderlyInfo.username,
		email: elderlyInfo.email,
		your_caregiver: caregiverUsername,
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

		// Check if the user is a caregiver or elderly
		const roleCheckQuery = `
			SELECT 'Caregiver' AS role FROM careyou.Caregiver WHERE id = ?
			UNION
			SELECT 'Elderly' AS role FROM careyou.Elderly WHERE id = ?`;
		const roleCheckResult = await pool.promise().query(roleCheckQuery, [id, id]);

		if (roleCheckResult[0].length === 0) {
			return res.status(404).json({ error: "User not found" });
		}

		const userRole = roleCheckResult[0][0].role;

		// Fetch user's current hashed password from the appropriate table
		let fetchPasswordQuery, tableName;
		if (userRole === "Caregiver") {
			fetchPasswordQuery = `
				SELECT password
				FROM careyou.Caregiver
				WHERE id = ?`;
			tableName = "Caregiver";
		} else if (userRole === "Elderly") {
			fetchPasswordQuery = `
				SELECT password
				FROM careyou.Elderly
				WHERE id = ?`;
			tableName = "Elderly";
		}

		const fetchPasswordResult = await pool.promise().query(fetchPasswordQuery, [id]);

		if (fetchPasswordResult[0].length === 0) {
			return res.status(404).json({ error: "User not found" });
		}

		const hashedPassword = fetchPasswordResult[0][0].password;

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
			UPDATE careyou.${tableName}
			SET password = ?
			WHERE id = ?`;
		await pool.promise().query(updatePasswordQuery, [hashedNewPassword, id]);

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

		// Check if the user is a caregiver or elderly
		const roleCheckQuery = `
			SELECT 'Caregiver' AS role FROM careyou.Caregiver WHERE id = ?
			UNION
			SELECT 'Elderly' AS role FROM careyou.Elderly WHERE id = ?`;
		const roleCheckResult = await pool.promise().query(roleCheckQuery, [id, id]);

		if (roleCheckResult[0].length === 0) {
			return res.status(404).json({ error: "User not found" });
		}

		const userRole = roleCheckResult[0][0].role;
		let usernameQuery, tableName;

		// Determine query and table based on user role
		if (userRole === "Caregiver") {
			usernameQuery = `
				SELECT username FROM careyou.Caregiver WHERE id = ?`;
			tableName = "Caregiver";
		} else if (userRole === "Elderly") {
			usernameQuery = `
				SELECT username FROM careyou.Elderly WHERE id = ?`;
			tableName = "Elderly";
		}

		// Fetch username from the appropriate table
		const usernameResult = await pool.promise().query(usernameQuery, [id]);

		if (usernameResult[0].length === 0) {
			return res.status(404).json({ error: "Username not found" });
		}
		const currentDate = new Date().toLocaleString("en-us", {
			weekday: "short",
			day: "numeric",
			year: "numeric",
		});
		const username = usernameResult[0][0].username;

		res.status(200).json({
			username,
			currentDate,
		});
	} catch (err) {
		console.error(err);
		res.status(500).json({ error: "Internal Server Error" });
	}
});

router.get("/Elderly", verifyToken, async (req, res) => {
	try {
		const elderlyId = req.user.id;
  
		// Check if the user is an elderly
		const roleCheck = await pool.promise().query(
			`SELECT role FROM careyou.Caregiver WHERE id = ?
			UNION
			SELECT role FROM careyou.Elderly WHERE id = ?`,
			[elderlyId, elderlyId]
		);
		console.log(roleCheck)

		if (roleCheck[0][0] !== "Elderly") {
			// If user is not an elderly, send appropriate response
			return res.status(403).send("User is not authorized as an Elderly");
		}
  
		// Fetch elderly information
		const elderlyInfoQuery = `
			SELECT username, email, yourcaregiver_email
			FROM careyou.Elderly
			WHERE id = ?`;
		const elderlyInfoResult = await pool.promise().query(elderlyInfoQuery, [elderlyId]);
  
		if (elderlyInfoResult[0].length === 0) {
			return res.status(404).send("Elderly information not found");
		}
  
		const elderlyInfo = elderlyInfoResult[0][0];
		const caregiverEmail = elderlyInfo.yourcaregiver_email;
  
		// Fetch caregiver username based on email
		let caregiverUsername = "You don't have a caregiver.";
		if (caregiverEmail) {
			const caregiverUsernameQuery = `
				SELECT username
				FROM careyou.Caregiver
				WHERE email = ?`;
			const caregiverUsernameResult = await pool.promise().query(caregiverUsernameQuery, [caregiverEmail]);
  
			if (caregiverUsernameResult[0].length > 0) {
				caregiverUsername = caregiverUsernameResult[0][0].username;
			}
		}
  
		// Format current date
		const currentDate = new Date().toLocaleString("en-us", {
			weekday: "short",
			day: "numeric",
			year: "numeric",
		});
  
		res.json({
			username: elderlyInfo.username,
			email: elderlyInfo.email,
			your_caregiver: caregiverUsername,
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
			SELECT 'Caregiver' AS role FROM careyou.Caregiver WHERE id = ?
			UNION
			SELECT 'Elderly' AS role FROM careyou.Elderly WHERE id = ?`;
		const roleCheckResult = await pool.promise().query(roleCheckQuery, [id, id]);

		if (roleCheckResult[0].length === 0) {
			return res.status(404).json({ error: "User not found" });
		}

		const userRole = roleCheckResult[0][0].role;

		// Fetch user's current hashed password from the appropriate table
		let fetchPasswordQuery, tableName;
		if (userRole === "Caregiver") {
			fetchPasswordQuery = `
				SELECT password
				FROM careyou.[Caregiver]
				WHERE id = ?`;
			tableName = "Caregiver";
		} else if (userRole === "Elderly") {
			fetchPasswordQuery = `
				SELECT password
				FROM careyou.[Elderly]
				WHERE id = ?`;
			tableName = "Elderly";
		}

		const fetchPasswordResult = await pool.promise().query(fetchPasswordQuery, [id]);

		if (fetchPasswordResult[0].length === 0) {
			return res.status(404).json({ error: "User not found" });
		}

		const hashedPassword = fetchPasswordResult[0][0].password;

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
			UPDATE careyou.${tableName}
			SET password = ?
			WHERE id = ?`;
		await pool.promise().query(updatePasswordQuery, [hashedNewPassword, id]);

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

		// Check if the user is a caregiver or elderly
		const roleCheckQuery = `
			SELECT 'Caregiver' AS role FROM careyou.Caregiver WHERE id = ?
			UNION
			SELECT 'Elderly' AS role FROM careyou.Elderly WHERE id = ?`;
		const roleCheckResult = await pool.promise().query(roleCheckQuery, [id, id]);

		if (roleCheckResult[0].length === 0) {
			return res.status(404).json({ error: "User not found" });
		}

		const userRole = roleCheckResult[0][0].role;
		let usernameQuery, tableName;

		// Determine query and table based on user role
		if (userRole === "Caregiver") {
			usernameQuery = `
				SELECT username FROM careyou.Caregiver WHERE id = ?`;
			tableName = "Caregiver";
		} else if (userRole === "Elderly") {
			usernameQuery = `
				SELECT username FROM careyou.Elderly WHERE id = ?`;
			tableName = "Elderly";
		}

		// Fetch username from the appropriate table
		const usernameResult = await pool.promise().query(usernameQuery, [id]);

		if (usernameResult[0].length === 0) {
			return res.status(404).json({ error: "Username not found" });
		}
		const currentDate = new Date().toLocaleString("en-us", {
			weekday: "short",
			day: "numeric",
			year: "numeric",
		});
		const username = usernameResult[0][0].username;

		res.status(200).json({
			username,
			currentDate,
		});
	} catch (err) {
		console.error(err);
		res.status(500).json({ error: "Internal Server Error" });
	}
});


module.exports = router;