const express = require('express');
const router = express.Router();
const sql = require('mssql');
const config = require('../config'); 
const bcrypt = require('bcryptjs');
const verifyToken = require('../middleware/verifyToken');

router.get('/Caregiver', verifyToken, async (req, res) => {
    try {
        const caregiverId = req.user.id;
        const pool = await sql.connect(config);

        // Check if the user is a caregiver
        const roleCheck = await pool.request()
            .input('id', sql.Int, caregiverId)
            .query('SELECT * FROM CareYou.[Caregiver] WHERE id = @id AND role = \'Caregiver\'');

            
        if (roleCheck.recordset.length === 0) {
            // If user is not a caregiver, send appropriate response
            return res.status(403).send('User is not authorized as a caregiver');
        }

        // Fetch caregiver information (username, email, yourelderly_email)
        const caregiverInfoQuery = `
            SELECT username, email, password, yourelderly_email ,yourelderly_relation
            FROM CareYou.[Caregiver] 
            WHERE id = @id
        `;
        const caregiverInfoResult = await pool.request()
            .input('id', sql.Int, caregiverId)
            .query(caregiverInfoQuery);

        if (caregiverInfoResult.recordset.length === 0) {
            return res.status(404).send('Caregiver information not found');
        }

        const caregiverInfo = caregiverInfoResult.recordset[0];
        // console.log(caregiverInfo.password);
        // const isPassword = await bcrypt.caregiverInfo.password;
        // const passwordLength = isPassword.length;
        // console.log(isPassword);

        const elderInfoQuery = `
            SELECT username, yourelderly_relation
            FROM CareYou.[user]
            WHERE yourelderly_email = @yourelderly_email
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

        const currentDate = new Date().toLocaleString('en-us', {
            weekday: 'short',
            day: 'numeric',
            year: 'numeric',
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
				relation: elder.relation,
			})),
			currentDate: currentDate,
		});

    } catch (err) {
        console.error(err);
        res.status(500).send('Internal Server Error');
    }
});


router.get('/Elderly', verifyToken, async (req, res) => {
    try {
        const elderlyId = req.user.id;
        const pool = await sql.connect(config);

        // Check if the user is a caregiver
        const roleCheck = await pool.request()
            .input('id', sql.Int, elderlyId)
            .query('SELECT * FROM CareYou.[Elderly] WHERE id = @id AND role = \'Elderly\'');

            
        if (roleCheck.recordset.length === 0) {
            // If user is not a caregiver, send appropriate response
            return res.status(403).send('User is not authorized as a elderlyr');
        }

        const elderlyInfoQuery = `
            SELECT username, email, yourcaregiver_email
            FROM CareYou.[user] 
            WHERE id = @id
        `;
        const elderlyInfoResult = await pool.request()
            .input('id', sql.Int, elderlyId)
            .query(elderlyInfoQuery);

        if (elderlyInfoResult.recordset.length === 0) {
            return res.status(404).send('Elderly information not found');
        }

        const elderlyInfo = elderlyInfoResult.recordset[0];

        const CaregiverEmail = elderlyInfo.yourcaregiver_email;

        const CaregiverUsernameQuery = `
            SELECT username
            FROM CareYou.[user] 
            WHERE email = @yourcaregiver_email
        `;
        const CaregiverUsernameResult = await pool.request()
            .input('yourcaregiver_email', sql.VarChar, CaregiverEmail)
            .query(CaregiverUsernameQuery);

        if (CaregiverUsernameResult.recordset.length === 0) {
            return res.status(404).send('Caregiver Username information not found');
        }

        const CaregiverUsername = CaregiverUsernameResult.recordset[0];

        const currentDate = new Date().toLocaleString('en-us', {
            weekday: 'short',
            day: 'numeric',
            year: 'numeric',
        });

        res.json({
            username: elderlyInfo.username,
            email: elderlyInfo.email,
            your_caregiver: CaregiverUsername.username,
            currentDate: currentDate
            
        });
        
    } catch (err) {
        console.error(err);
        res.status(500).send('Internal Server Error');
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
		const pool = await sql.connect(config);

		// Fetch user's current hashed password from the database
		const fetchPasswordQuery = `
            SELECT password
            FROM CareYou.[user]
            WHERE id = @id
        `;
        const fetchPasswordResult = await pool.request()
            .input('id', sql.Int, req.user.id)
            .query(fetchPasswordQuery);

        if (fetchPasswordResult.recordset.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        const hashedPassword = fetchPasswordResult.recordset[0].password;

        // Compare old password with the hashed password from the database
        const isMatch = await bcrypt.compare(oldPassword, hashedPassword);

        if (!isMatch) {
            return res.status(400).json({ error: 'Invalid old password' });
        }

        // Hash the new password
        const salt = await bcrypt.genSalt(10);
        const hashedNewPassword = await bcrypt.hash(newPassword, salt);

        // Update the password in the database
        const updatePasswordQuery = `
            UPDATE CareYou.[user]
            SET password = @hashedNewPassword
            WHERE id = @idd
        `;
		await pool
			.request()
			.input("hashedNewPassword", sql.VarChar, hashedNewPassword)
			.input("idd", sql.Int, req.user.id)
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
		const UsernameCheck = await pool
			.request()
			.input("id", sql.Int, id)
			.query("SELECT username FROM CareYou.[user] WHERE id = @id");

		if (UsernameCheck.recordset.length === 0) {
			return res.status(404).json({ error: "Username not found" });
		}

		res.json(UsernameCheck.recordset[0]);
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
		const pool = await sql.connect(config);

		// Update username in the database
		const updateUsernameQuery = `
            UPDATE CareYou.[user]
            SET username = @newUsername
            WHERE id = @id
        `;
		await pool
			.request()
			.input("newUsername", sql.NVarChar, newUsername)
			.input("id", sql.Int, req.user.id)
			.query(updateUsernameQuery);

		res.status(200).json({ message: "Username updated successfully" });
	} catch (err) {
		console.error(err);
		res.status(500).json({ error: "Internal Server Error" });
	}
});

router.post("/AddElderly", verifyToken, async (req, res) => {
	const { elderEmail, relation } = req.body;

	if (!elderEmail || !relation) {
		return res
			.status(400)
			.json({ error: "Both elderEmail and relation are required" });
	}

	try {
		const pool = await sql.connect(config);

		// Check if elderEmail already exists
		const emailCheckQuery = `
            SELECT COUNT(*) AS count
            FROM CareYou.[user]
            WHERE yourelderly_email = @yourelderly_email
        `;
		const emailCheckResult = await pool
			.request()
			.input("yourelderly_email", sql.VarChar, elderEmail)
			.query(emailCheckQuery);

		if (emailCheckResult.recordset[0].count > 0) {
			return res
				.status(400)
				.json({ error: "Elderly with this email already exists" });
		}

		// Insert new elderly user
		const insertElderQuery = `
            INSERT INTO CareYou.[user] (email, role, yourcaregiver_email, yourelderly_relation)
            VALUES (@yourelderly_email, 'Elderly', @yourcaregiver_email, @yourelderly_relation)
        `;
		await pool
			.request()
			.input("yourelderly_email", sql.VarChar, elderEmail)
			.input("yourcaregiver_email", sql.VarChar, req.user.email) // Assuming req.user.email is caregiver's email
			.input("yourelderly_relation", sql.NVarChar, relation)
			.query(insertElderQuery);

		res.status(200).json({ message: "Elderly added successfully" });
	} catch (err) {
		console.error(err);
		res.status(500).json({ error: "Internal Server Error" });
	}
});

// router.delete("/DeleteElderly/:elderId", verifyToken, async (req, res) => {
// 	const elderId = req.params.elderId;

// 	try {
// 		const pool = await sql.connect(config);

// 		// Check if the user making the request is a caregiver and has permission
// 		// Assuming you have a middleware function verifyToken to check and decode the JWT token
// 		const { email } = req.user; // Assuming verifyToken adds `user` object to req
// 		const userRoleQuery = `
//             SELECT role
//             FROM CareYou.[user]
//             WHERE email = @email
//         `;
// 		const roleResult = await pool
// 			.request()
// 			.input("email", sql.VarChar, email)
// 			.query(userRoleQuery);

// 		if (roleResult.recordset.length === 0) {
// 			return res.status(404).json({ error: "User not found" });
// 		}

// 		const userRole = roleResult.recordset[0].role;

// 		// Only caregivers can perform this action
// 		if (userRole !== "caregiver") {
// 			return res.status(403).json({ error: "Unauthorized" });
// 		}

// 		// Update elderly user's yourelderly_email and yourelderly_relationship to NULL
// 		const updateElderQuery = `
//             UPDATE CareYou.[user]
//             SET yourelderly_email = NULL,
//                 yourelderly_relation = NULL
//             WHERE id = @elderId AND role = 'elderly'
//         `;
// 		const updateResult = await pool
// 			.request()
// 			.input("elderId", sql.Int, elderId)
// 			.query(updateElderQuery);

// 		if (updateResult.rowsAffected[0] === 0) {
// 			return res.status(404).json({ error: "Elderly not found" });
// 		}

// 		res.status(200).json({
// 			message: "Elderly details deleted successfully",
// 		});
// 	} catch (err) {
// 		console.error(err);
// 		res.status(500).json({ error: "Internal Server Error" });
// 	}
// });



module.exports = router;
