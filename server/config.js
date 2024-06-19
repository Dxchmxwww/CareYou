const crypto = require('crypto');
const JWT_SECRET = process.env.JWT_SECRET || crypto.randomBytes(32).toString('hex');
module.exports = {
    database: {
        user: 'careyou',
        password: 'kmutt-1234',
        server: 'integrate2024.database.windows.net',
        port: 1433,
        database: 'CareYou',
        authentication: {
            type: 'default'
        },
        options: {
            encrypt: true
        }
    },
    JWT_SECRET: JWT_SECRET
};
