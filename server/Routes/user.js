const express = require('express');
const router = express.Router();
const sql = require('mssql');
const config = require('../config'); 
const bcrypt = require('bcryptjs');
const verifyToken = require('../middleware/verifyToken');

// Endpoint to update user password
router.put('/EditPassword', verifyToken, async (req, res) => {
    const { oldPassword, newPassword } = req.body;

    if (!oldPassword || !newPassword) {
        return res.status(400).json({ error: 'Both old password and new password are required' });
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
        await pool.request()
            .input('hashedNewPassword', sql.VarChar, hashedNewPassword)
            .input('idd', sql.Int, req.user.id)
            .query(updatePasswordQuery);

        res.status(200).json({ message: 'Password updated successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

// Endpoint to fetch username
router.get('/Showusername', verifyToken, async (req, res) => {
    try {
        const id = req.user.id;
        const pool = await sql.connect(config);
        const UsernameCheck = await pool.request()
            .input('id', sql.Int, id)
            .query(`
                SELECT username FROM CareYou.[Caregiver] WHERE id = @id
                UNION
                SELECT username FROM CareYou.[Elderly] WHERE id = @id
            `);

        if (UsernameCheck.recordset.length === 0) {
            return res.status(404).json({ error: 'Username not found' });
        }

        res.status(200).json(UsernameCheck.recordset[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

module.exports = router;
