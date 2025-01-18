// const dotenv = require('dotenv');

// // Load environment variables from .env file
// dotenv.config();

// const crypto = require('crypto');

// const JWT_SECRET = crypto.randomBytes(32).toString('hex');

// const databaseConfig = {
//   user: process.env.DB_USER,
//   password: process.env.DB_PASSWORD,
//   server: process.env.DB_SERVER,
//   port: parseInt(process.env.DB_PORT, 10),
//   database: process.env.DB_DATABASE,
//   authentication: {
//     type: 'default',
//   },
//   options: {
//     encrypt: true,
//   },
// };

// sql

// module.exports = {
//   database: databaseConfig,
//   JWT_SECRET: JWT_SECRET,
//   BASE_URL: process.env.BASE_URL,
//   ANDROID_URL: process.env.ANDROID_URL,
// };


const dotenv = require('dotenv');

// Load environment variables from .env file
dotenv.config();

// MySQL library for connecting to MySQL database
const mysql = require('mysql2');

// Database configuration for MySQL
const databaseConfig = {
  host: process.env.DB_SERVER,  // Ensure DB_SERVER is set in your .env
  user: process.env.DB_USER,    // Ensure DB_USER is set in your .env
  password: process.env.DB_PASSWORD,  // Ensure DB_PASSWORD is set in your .env
  database: process.env.DB_DATABASE,  // Ensure DB_DATABASE is set in your .env
  port: parseInt(process.env.DB_PORT, 10) || 3306,  // Default to port 3306
};

const pool = mysql.createPool(databaseConfig);

// Test the pool connection
pool.getConnection((err, connection) => {
  if (err) {
    console.error('Database connection failed: ' + err.stack);
    return;
  }
  console.log('Connected to the database.');
  connection.release();  // Release the connection back to the pool
});

// Optional: Generate JWT_SECRET if you need it
const crypto = require('crypto');
const JWT_SECRET = crypto.randomBytes(32).toString('hex');

// Export the configuration, pool, and JWT_SECRET
module.exports = {
  pool: pool,              // Export the pool for use in other parts of your application
  JWT_SECRET: JWT_SECRET,  // Export the JWT secret
  BASE_URL: process.env.BASE_URL,  // Ensure BASE_URL is set in your .env
  ANDROID_URL: process.env.ANDROID_URL,  // Ensure ANDROID_URL is set in your .env
};
