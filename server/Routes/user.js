const express = require('express');
const router = express.Router();
const sql = require('mssql');
const config = require('../config'); 
const bcrypt = require('bcryptjs');
const verifyToken = require('../middleware/verifyToken');


// Endpoint to fetch username
router.get('/Showusername', verifyToken, async (req, res) => {
    try {
        const id = req.user.id;
        const pool = await sql.connect(config);
        const UsernameCheck = await pool.request()
            .input('id', sql.Int, id)
            .query('SELECT username FROM CareYou.[user] WHERE id = @id');

        if (UsernameCheck.recordset.length === 0) {
            return res.status(404).json({ error: 'Username not found' });
        }

        res.json(UsernameCheck.recordset[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

module.exports = router;
