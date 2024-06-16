const crypto = require('crypto');

module.exports = {
    database: {
        user: 'intregrate2',
        password: 'kmutt-1234',
        server: 'intregrate2.database.windows.net',
        port: 1433,
        database: 'CareYou',
        authentication: {
            type: 'default'
        },
        options: {
            encrypt: true
        }
    },
    JWT_SECRET: crypto.randomBytes(32).toString('hex')
};
