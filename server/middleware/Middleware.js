const cors = require('cors');

const corsMiddleware = cors({
    origin: '*', // You can specify allowed origins here
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    preflightContinue: false,
    optionsSuccessStatus: 204
});

module.exports = corsMiddleware;
