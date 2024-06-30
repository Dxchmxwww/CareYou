// const express = require("express");
// const app = express();
// const corsMiddleware = require("./middleware/Middleware");
// const pillRoutes = require("./Routes/Pill_management");
// const authRoutes = require("./Routes/auth");
// const notificationsRoutes = require("./Routes/Notification");
// const AppointmentRoutes = require("./Routes/Appointment_management");
// const profileRoutes = require("./Routes/profile");
// const verifyToken = require("./middleware/verifyToken");
// const cookieParser = require("cookie-parser");
// const bodyParser = require("body-parser");
// const port = 8000;

// app.use(corsMiddleware);

// // Route middlewares
// app.use(bodyParser.json());

// app.use('/auth', authRoutes);

// app.use(cookieParser());
// app.use(verifyToken);

// app.use('/pills', pillRoutes);
// app.use('/appointments', AppointmentRoutes);
// app.use('/profiles', profileRoutes);
// app.use('/notifications', notificationsRoutes);

// app.listen(port, () => {
// 	console.log(`Server is running on http://localhost:${port}`);
// });


const express = require("express");
const app = express();
const corsMiddleware = require("./middleware/Middleware");
const pillRoutes = require("./Routes/Pill_management");
const authRoutes = require("./Routes/auth");
const notificationsRoutes = require("./Routes/Notification");
const AppointmentRoutes = require("./Routes/Appointment_management");
const profileRoutes = require("./Routes/profile");
const verifyToken = require("./middleware/verifyToken");
const cookieParser = require("cookie-parser");
const bodyParser = require("body-parser");
const dotenv = require('dotenv');


dotenv.config();

const port = 8000;
const baseUrl = process.env.BASE_URL;
const androidUrl = process.env.ANDROID_URL;

console.log(`Base URL: ${baseUrl}`);
console.log(`Android URL: ${androidUrl}`);


app.use(corsMiddleware);

// Route middlewares
app.use(bodyParser.json());

app.use('/auth', authRoutes);

app.use(cookieParser());
app.use(verifyToken);

app.use('/pills', pillRoutes);
app.use('/appointments', AppointmentRoutes);
app.use('/profiles', profileRoutes);
app.use('/notifications', notificationsRoutes);

app.listen(port, '0.0.0.0' ,() => {
	console.log(`Server is running on ${port}`);
});
