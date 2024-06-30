// const crypto = require("crypto");

// const JWT_SECRET =
// 	process.env.JWT_SECRET || crypto.randomBytes(32).toString("hex");

// const databaseConfig = {
// 	user: "careyou",
// 	password: "kmutt-1234",
// 	server: "integrate2024.database.windows.net",
// 	port: 1433,
// 	database: "CareYou",
// 	authentication: {
// 		type: "default",
// 	},
// 	options: {
// 		encrypt: true,
// 	},
// };

// module.exports = {
// 	database: databaseConfig,
// 	JWT_SECRET: JWT_SECRET,
// };


const dotenv = require('dotenv');

// Load environment variables from .env file
dotenv.config();

const crypto = require('crypto');

const JWT_SECRET = crypto.randomBytes(32).toString('hex');

const databaseConfig = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_SERVER,
  port: parseInt(process.env.DB_PORT, 10),
  database: process.env.DB_DATABASE,
  authentication: {
    type: 'default',
  },
  options: {
    encrypt: true,
  },
};



module.exports = {
  database: databaseConfig,
  JWT_SECRET: JWT_SECRET,
  BASE_URL: process.env.BASE_URL,
  ANDROID_URL: process.env.ANDROID_URL,
};

