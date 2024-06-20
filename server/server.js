const express = require("express");
const app = express();
const corsMiddleware = require("./middleware/Middleware");
const pillRoutes = require("./Routes/Pill_management");
const authRoutes = require("./Routes/auth");
const AppointmentRoutes = require("./Routes/Appointment_management");
const profileRoutes = require("./Routes/profile");
const verifyToken = require("./middleware/verifyToken");
const cookieParser = require("cookie-parser");
const bodyParser = require("body-parser");
const port = 8000;

app.use(corsMiddleware);

// Route middlewares
app.use(bodyParser.json());

app.use('/auth', authRoutes);

app.use(cookieParser());
app.use(verifyToken);

app.use('/pills', pillRoutes);
app.use('/appointments', AppointmentRoutes);
app.use('/profiles', profileRoutes);

app.listen(port, () => {
	console.log(`Server is running on http://localhost:${port}`);
});
