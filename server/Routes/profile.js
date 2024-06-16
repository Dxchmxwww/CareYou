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
            .query('SELECT * FROM CareYou.[user] WHERE id = @id AND role = \'Caregiver\'');

            
        if (roleCheck.recordset.length === 0) {
            // If user is not a caregiver, send appropriate response
            return res.status(403).send('User is not authorized as a caregiver');
        }

        // Fetch caregiver information (username, email, yourelderly_email)
        const caregiverInfoQuery = `
            SELECT username, email, password, yourelderly_email ,yourelderly_relation
            FROM CareYou.[user] 
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

        // const currentDate = new Date().toLocaleString('en-us', {
        //     weekday: 'short',
        //     day: 'numeric',
        //     year: 'numeric',
        // });

        res.json({
            username: caregiverInfo.username,
            email: caregiverInfo.email,
            yourelderly_email: caregiverInfo.yourelderly_email,
            yourelderly_relation: caregiverInfo.yourelderly_relation,
            // currentDate: currentDate
            
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
            .query('SELECT * FROM CareYou.[user] WHERE id = @id AND role = \'Elderly\'');

            
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



module.exports = router;
