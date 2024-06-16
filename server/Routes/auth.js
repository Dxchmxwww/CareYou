const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const sql = require('mssql');
const config = require('../config');

const JWT_SECRET = config.JWT_SECRET;


//-----------------------------------Authentication------------------------------------
async function registerUser(username, password, email, role, yourelderly_email,yourelderly_relation) {
    try {
        const pool = await sql.connect(config.database);

        // Check if username already exists
        const usernameCheck = await pool.request()
            .input('username', sql.VarChar, username)
            .query('SELECT * FROM CareYou.[user] WHERE username = @username');

        if (usernameCheck.recordset.length > 0) {
            throw new Error('Username already exists');
        }

        // Check if email already exists
        const emailCheck = await pool.request()
            .input('email', sql.VarChar, email)
            .query('SELECT * FROM CareYou.[user] WHERE email = @email');

        if (emailCheck.recordset.length > 0) {
            throw new Error('Email already exists');
        }

        // Hash the password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Insert new user into database
        await pool.request()
            .input('username', sql.VarChar, username)
            .input('password', sql.VarChar, hashedPassword)
            .input('email', sql.VarChar, email)
            .input('role', sql.NVarChar, role)
            .input('yourelderly_email', sql.VarChar, yourelderly_email)
            .input('yourelderly_relation', sql.VarChar, yourelderly_relation)
            .query('INSERT INTO CareYou.[user] (username, password, email, role, yourelderly_email,yourelderly_relation) VALUES (@username, @password, @email, @role, @yourelderly_email,@yourelderly_relation)');
    } catch (error) {
        res.status(400).send(error.message);
    }
}

async function authenticateUser(email, password) {
    try {
        const pool = await sql.connect(config.database);
        const userCheck = await pool.request()
            .input('email', sql.VarChar, email)
            .query('SELECT * FROM CareYou.[user] WHERE email = @email');

        if (userCheck.recordset.length === 0) {
            throw new Error('User not found');
        }

        const user = userCheck.recordset[0];

        const isPasswordValid = await bcrypt.compare(password, user.password);
        if (!isPasswordValid) {
            throw new Error('Invalid credentials');
        }

        const token = generateToken(user.id);

        return {token};
    } catch (error) {
        res.status(400).send(error.message);
    }
}

function generateToken(id) {
    return jwt.sign({ id }, JWT_SECRET, { expiresIn: '1h' });
}


//-----------------------------------Register------------------------------------

//http://localhost:8000/auth/register

router.post('/register', async (req, res) => {
    try {
      const { username, password, email, role, yourelderly_email, yourelderly_relation } = req.body;
  
      if (!role || (role !== 'Caregiver' && role !== 'Elderly')) {
        throw new Error('Invalid role');
      }
  
      if (role === 'Caregiver') {
        if (!username || !password || !email) {
          throw new Error('Username, password, and email are required for Caregiver role');
        }
  
        if (yourelderly_email) {
        const pool = await sql.connect(config.database);
        const checkelderlyemail = await pool.request()
          .input('yourelderly_email', sql.VarChar, yourelderly_email) 
          .query('SELECT * FROM CareYou.[user] WHERE email = @yourelderly_email AND role = \'Elderly\'');
        
        console.log(checkelderlyemail);
        const checkRepeatemail = await pool.request()
          .input('yourelderly_email', sql.VarChar, yourelderly_email)
          .query('SELECT * FROM CareYou.[user] WHERE yourelderly_email = @yourelderly_email AND role = \'Caregiver\'');
        
          console.log(checkRepeatemail);
        if (checkelderlyemail.recordset.length === 0) {
          throw new Error('Elderly user not found with provided email');
        }

        if (checkRepeatemail.recordset.length > 0) {
            throw new Error('Elderly user already has caregiver');
        }
      }

        await registerUser(username, password, email, role, yourelderly_email,yourelderly_relation);
        const pool = await sql.connect(config.database);    
        await pool.request()
            .input('yourcaregiver_email', sql.VarChar, email)
            .input('yourelderly_email', sql.VarChar, yourelderly_email)
            .query('UPDATE CareYou.[user] SET yourcaregiver_email = @yourcaregiver_email WHERE email = @yourelderly_email AND role = \'Elderly\'');

        res.status(201).send('User registered successfully');
      } else if (role === 'Elderly') {
        if (!username || !password || !email) {
          throw new Error('Username, password, and email are required for Elderly role');
        }
        const register = await registerUser(username, password, email, role);
        res.status(201).send('User registered successfully');
      }
  

    } catch (error) {
      console.log(error);
      res.status(400).send(error.message);
    }
  });


//-----------------------------------Login------------------------------------------

//http://localhost:8000/auth/login
async function getUserByEmail(email) {
    try {
     const pool = await sql.connect(config.database);
     const userCheck = await pool
      .request()
      .input("email", sql.VarChar, email)
      .query("SELECT * FROM CareYou.[user] WHERE email = @email");
   
     if (userCheck.recordset.length === 0) {
      return null; // Return null if user not found
     }
   
     return userCheck.recordset[0]; // Return the first user found
    } catch (error) {
     throw new Error(`Error retrieving user by email: ${error.message}`);
    }
   }
   
router.post("/login", async (req, res) => {
    const { email, password, selectedRole } = req.body;
    console.log(`Login attempt: email=${email}, role=${selectedRole}`);
   try {
    const { token } = await authenticateUser(email, password); 
    console.log(token)
    
    const user = await getUserByEmail(email);
      console.log(`User data from database: ${JSON.stringify(user)}`);
    // // Check if user's role matches selectedRole
    console.log(user);
    const role = user.role;
    if (!user || user.role !== selectedRole) {
     return res.status(401).json({ error: "Role mismatch" });
    } 
  
    // Set cookie with JWT token
    res.cookie("authToken", token, {
     httpOnly: true,
     maxAge: 3600000, // 1 hour in milliseconds
     secure: process.env.NODE_ENV === "production", // Set to true in production
    });
  
    // Respond with token, role, and message
    res.status(200).json({ message: "Login successful", token, role});
   } catch (error) {
    console.log(error)
    res.status(401).json({
     error: "Please check your email and password and try again",
    });
   }
  });
//-----------------------------------Logout------------------------------------
  
  const blacklist = new Set();
  
  const checkBlacklist = (req, res, next) => {
    const token = req.headers['authorization']?.split(' ')[1];
    if (blacklist.has(token)) {
      return res.status(401).send('Token has been invalidated');
    }
    next();
  };

//http://localhost:8000/auth/logout

router.get('/logout', (req, res) => {
    res.clearCookie('authToken');
    res.status(200).json({ message: 'Logged out successfully' });
});
  

module.exports = router;

