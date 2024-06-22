const express = require("express");
const router = express.Router();
const { body, validationResult } = require("express-validator");
const sql = require("mssql");
const config = require("../config");
const verifyToken = require("../middleware/verifyToken");
const moment  = require("moment");

// CreateAppointmentReminder route
router.post(
	"/CreateAppointmentReminder",
	verifyToken,
	[
		body("Appointment_name")
			.notEmpty()
			.withMessage("Appointment name is required"),
		body("Date").isDate().withMessage("Date must be a valid date"),
		body("StartTime")
			.matches(/^([01]\d|2[0-3]):([0-5]\d):00$/)
			.withMessage("Start time must be in HH:MM format"),
		body("EndTime")
			.matches(/^([01]\d|2[0-3]):([0-5]\d):00$/)
			.withMessage("Start time must be in HH:MM format"),
		body("Location").notEmpty().withMessage("Location is required"),
	],
	async (req, res) => {
		const errors = validationResult(req);
		if (!errors.isEmpty()) {
			return res.status(400).json({ errors: errors.array() });
		}

		const { Appointment_name, Date, StartTime, EndTime, Location } =
			req.body;

		const caregiver_id = req.user.id;

		try {
			const pool = await sql.connect(config.database);

			// Check if the user is a caregiver
			const roleCheck = await pool
				.request()
				.input("id", sql.Int, caregiver_id)
				.query("SELECT role FROM CareYou.[Caregiver] WHERE id = @id");

			if (
				roleCheck.recordset.length === 0 ||
				roleCheck.recordset[0].role !== "Caregiver"
			) {
				return res
					.status(403)
					.send("User is not authorized as a caregiver");
			}

			const GetCaregiveremail = await pool
				.request()
				.input("caregiver_id", sql.Int, caregiver_id)
				.query(
					"SELECT email FROM CareYou.[Caregiver] WHERE id = @caregiver_id AND role = 'Caregiver'"
				);

			if (GetCaregiveremail.recordset.length === 0) {
				return res.status(400).send("Caregiver not found");
			}

			const Caregiver_email = GetCaregiveremail.recordset[0].email;
			console.log(Caregiver_email);
			const Getelderly_id = await pool
				.request()
				.input("yourcaregiver_email", sql.VarChar, Caregiver_email)
				.query(
					"SELECT id FROM CareYou.[Elderly] WHERE yourcaregiver_email = @yourcaregiver_email AND role = 'Elderly'"
				);

			if (Getelderly_id.recordset.length === 0) {
				return res
					.status(400)
					.send("Elderly user not found with provided email");
			}

			const elderly_id = Getelderly_id.recordset[0].id;

			const createAppointmentReminderRequest = pool.request();
			const createAppointmentReminderQuery = `
                INSERT INTO CareYou.Appointment_Reminder 
                (Appointment_name, Date, StartTime, EndTime, caregiver_id, elderly_id,Location) 
                VALUES 
                (@appointment_name, @Date, @StartTime, @EndTime, @caregiver_id, @elderly_id, @Location);
            `;

			await createAppointmentReminderRequest
				.input("Appointment_name", sql.VarChar, Appointment_name)
				.input("Date", sql.Date, Date)
				.input("StartTime", sql.VarChar, StartTime)
				.input("EndTime", sql.VarChar, EndTime)
				.input("caregiver_id", sql.Int, caregiver_id)
				.input("elderly_id", sql.Int, elderly_id)
				.input("Location", sql.VarChar, Location)
				.query(createAppointmentReminderQuery);

			res.status(200).send("Appointment reminder created successfully");
		} catch (error) {
			console.error(error);
			res.status(500).send("Internal Server Error");
		}
	}
);

router.get(
	"/ShowTodayAppointmentOfElderForCaregiverHome",
	verifyToken, // Middleware to verify token
	async (req, res) => {
		try {
			const pool = await sql.connect(config);
			const id = req.user.id;

			// Check if the user is a caregiver
			const roleCheck = await pool
				.request()
				.input("id", sql.Int, id)
				.query(
					"SELECT * FROM CareYou.[Caregiver] WHERE id = @id AND role = 'Caregiver'"
				);

			if (roleCheck.recordset.length === 0) {
				return res
					.status(403)
					.send("User is not authorized as a caregiver");
			}

			// Get today's date
			const today = new Date();
			const year = today.getFullYear();
			const month = String(today.getMonth() + 1).padStart(2, "0"); // Months are zero-indexed, so add 1
			const day = String(today.getDate()).padStart(2, "0");
			const todayDate = `${year}-${month}-${day}`;

			const getTodayAppointmentsQuery = `
        SELECT 
          Appointment_name, 
          CONVERT(VARCHAR, StartTime, 108) AS StartTime, -- HH:mm:ss format
          CONVERT(VARCHAR, EndTime, 108) AS EndTime,     -- HH:mm:ss format
          Location
        FROM CareYou.Appointment_reminder 
        WHERE caregiver_id = @caregiver_id AND CONVERT(DATE, date) = @todayDate
      `;

			const todayAppointmentsResult = await pool
				.request()
				.input("caregiver_id", sql.Int, id)
				.input("todayDate", sql.Date, todayDate)
				.query(getTodayAppointmentsQuery);

			if (todayAppointmentsResult.recordset.length === 0) {
				return res.status(404).send("No appointments found for today");
			}

			// Format the appointments
			const formattedAppointments = todayAppointmentsResult.recordset.map(
				(appointment) => ({
					Appointment_name: appointment.Appointment_name,
					StartTime: appointment.StartTime.substring(0, 5), // Extract "HH:mm" from 'HH:mm:ss'
					EndTime: appointment.EndTime.substring(0, 5), // Extract "HH:mm" from 'HH:mm:ss'
					Location: appointment.Location,
				})
			);

			console.log("Formatted appointments:", formattedAppointments);
			res.status(200).json(formattedAppointments);
		} catch (err) {
			console.error(err);
			res.status(500).send("Internal Server Error");
		}
	}
);

router.get(
	"/ShowAppointmentListForElderlyAppointmentBoxs",
	verifyToken,
	async (req, res) => {
		try {
			const pool = await sql.connect(config);
			const id = req.user.id;

			// Check if the user is an elderly
			const roleCheck = await pool
				.request()
				.input("id", sql.Int, id)
				.query(
					"SELECT * FROM CareYou.[Elderly] WHERE id = @id AND role = 'Elderly'"
				);

			if (roleCheck.recordset.length === 0) {
				return res.status(403).send("Unauthorized access");
			}
            const currentTime = new Date();
            const year = currentTime.getFullYear();
            const month = String(currentTime.getMonth() + 1).padStart(2, "0");
            const day = String(currentTime.getDate()).padStart(2, "0");
            

			// Get today's date in 'YYYY-MM-DD' format
			// const today = new Date().toISOString().split("T")[0];

			// Fetch today's appointments for the elderly
			const elderlyAppointmentList = await pool
				.request()
				.input("elderly_id", sql.Int, id)
				.input("today", sql.Date, `${year}-${month}-${day}`).query(`
                    SELECT 
                        *
                    FROM 
                        CareYou.[Appointment_reminder] 
                    WHERE 
                        elderly_id = @elderly_id
                        AND Date >= @today 
                `);

                
                if (elderlyAppointmentList.recordset.length > 0) {
                    const AppointmentList = elderlyAppointmentList.recordset.map(row => {
                        // Format StartTime to HH:mm
                        // const startTime = new Date(row.StartTime);
                        // const endTime = new Date(row.EndTime);

                        // // Check if parsing was successful
                        // if (isNaN(startTime.getTime()) || isNaN(endTime.getTime())) {
                        //     throw new Error('Invalid date format');
                        // }

                        // // Format StartTime and EndTime to HH:mm
                        // const formattedStartTime = startTime.toLocaleTimeString('en-US', {
                        //     hour: '2-digit',
                        //     minute: '2-digit',
                        //     hour12: false
                        // });
                        // const formattedEndTime = endTime.toLocaleTimeString('en-US', {
                        //     hour: '2-digit',
                        //     minute: '2-digit',
                        //     hour12: false
                        // });
                
                        return {
                            Appointment_id: row.Appointment_id,
                            Appointment_name: row.Appointment_name,
                            Date: row.Date,
                            StartTime: row.StartTime,
                            EndTime: row.EndTime,
                            Location: row.Location
                        };
                    });
                
                    res.status(200).json(AppointmentList);
                } else {
                    throw err; // Handle the error as per your application's requirements
                }
                
		} catch (err) {
			console.error(err);
			res.status(500).send("Internal Server Error");
		}
	}
);

router.get(
	"/ShowAllInfoAppointmentRemailderforCaregiver",
	verifyToken,
	async (req, res) => {
		try {
			const pool = await sql.connect(config);
			const id = req.user.id;

			// Check if the user is a caregiver
			const roleCheck = await pool
				.request()
				.input("id", sql.Int, id)
				.query(
					"SELECT * FROM CareYou.[Caregiver] WHERE id = @id AND role = 'Caregiver'"
				);

			if (roleCheck.recordset.length === 0) {
				return res
					.status(403)
					.send("User is not authorized as a caregiver");
			}

			// Get today's date
			const today = new Date();
			const year = today.getFullYear();
			const month = String(today.getMonth() + 1).padStart(2, "0"); // Months are zero-indexed, so add 1
			const day = String(today.getDate()).padStart(2, "0");
			const todayDate = `${year}-${month}-${day}`;

			console.log(todayDate);

			// Query to get today's pill reminders
			const getTodayPillRemindersQuery = `
                SELECT Pill_name, Dosage, Time
                FROM CareYou.Pill_reminder 
                WHERE caregiver_id = @caregiver_id AND date = @todayDate
            `;
			const todayPillRemindersResult = await pool
				.request()
				.input("caregiver_id", sql.Int, id)
				.input("todayDate", sql.Date, todayDate)
				.query(getTodayPillRemindersQuery);

			if (todayPillRemindersResult.recordset.length === 0) {
				return res
					.status(404)
					.send("No pill reminders found for today");
			}

			res.status(200).json(todayPillRemindersResult.recordset);
		} catch (err) {
			console.error(err);
			res.status(500).send("Internal Server Error");
		}
	}
);

router.get(
	"/ShowAppointmentListForElderlyAppointmentBoxs",
	verifyToken,
	async (req, res) => {
		try {
			const pool = await sql.connect(config);
			const id = req.user.id;

			// Check if the user is an elderly
			const roleCheck = await pool
				.request()
				.input("id", sql.Int, id)
				.query(
					"SELECT * FROM CareYou.[Elderly] WHERE id = @id AND role = 'Elderly'"
				);

			if (roleCheck.recordset.length === 0) {
				return res.status(403).send("Unauthorized access");
			}
			const currentTime = new Date();
			const year = currentTime.getFullYear();
			const month = String(currentTime.getMonth() + 1).padStart(2, "0");
			const day = String(currentTime.getDate()).padStart(2, "0");

			// Get today's date in 'YYYY-MM-DD' format
			// const today = new Date().toISOString().split("T")[0];

			// Fetch today's appointments for the elderly
			const elderlyAppointmentList = await pool
				.request()
				.input("elderly_id", sql.Int, id)
				.input("today", sql.Date, `${year}-${month}-${day}`).query(`
                    SELECT 
                        *
                    FROM 
                        CareYou.[Appointment_reminder] 
                    WHERE 
                        elderly_id = @elderly_id
                        AND Date >= @today 
                `);

			if (elderlyAppointmentList.recordset.length > 0) {
				const AppointmentList = elderlyAppointmentList.recordset.map(
					(row) => {
						// Format StartTime to HH:mm
						// const startTime = new Date(row.StartTime);
						// const endTime = new Date(row.EndTime);

						// // Check if parsing was successful
						// if (isNaN(startTime.getTime()) || isNaN(endTime.getTime())) {
						//     throw new Error('Invalid date format');
						// }

						// // Format StartTime and EndTime to HH:mm
						// const formattedStartTime = startTime.toLocaleTimeString('en-US', {
						//     hour: '2-digit',
						//     minute: '2-digit',
						//     hour12: false
						// });
						// const formattedEndTime = endTime.toLocaleTimeString('en-US', {
						//     hour: '2-digit',
						//     minute: '2-digit',
						//     hour12: false
						// });

						return {
							Appointment_id: row.Appointment_id,
							Appointment_name: row.Appointment_name,
							Date: row.Date,
							StartTime: row.StartTime,
							EndTime: row.EndTime,
							Location: row.Location,
						};
					}
				);

				res.status(200).json(AppointmentList);
			} else {
				
			}
		} catch (err) {
			console.error(err);
			res.status(500).send("Internal Server Error");
		}
	}
);

router.get(
	"/ShowAllInfoAppointmentRemailderforCaregiver",
	verifyToken,
	async (req, res) => {
		try {
			const pool = await sql.connect(config);
			const id = req.user.id;

			const RoleCheck = await pool
				.request()
				.input("id", sql.Int, id)
				.query(
					"SELECT * FROM CareYou.[Caregiver] WHERE id = @id AND role = 'Caregiver'"
				);

			if (RoleCheck.recordset.length > 0) {
				console.log("User is authorized as a caregiver");
			}

			const CaregiverAppointmentList = await pool
				.request()
				.input("caregiver_id", sql.Int, id)
				.query(
					"SELECT Appointment_name, Date, StartTime, EndTime,Location FROM CareYou.[Appointment_reminder] WHERE caregiver_id = @caregiver_id"
				);

			if (CaregiverAppointmentList.recordset.length > 0) {
				const AppointmentList = CaregiverAppointmentList.recordset.map(
					(row) => ({
						Appointment_name: row.Appointment_name,
						Date: row.Date,
						StartTime: row.StartTime,
						EndTime: row.EndTime,
						Location: row.Location,
					})
				);
				res.json(AppointmentList);
			} else {
				res.json([]);
			}
			res.status(200).send("Appointments reminder already show");
		} catch (err) {
			console.error(err);
			res.status(500).send(err.message);
		}
	}
);
router.get(
	"/ShowAppointmentReminderListforCaregiver",
	verifyToken,
	async (req, res) => {
		try {
			const pool = await sql.connect(config);
			const id = req.user.id;

			const RoleCheck = await pool
				.request()
				.input("id", sql.Int, id)
				.query(
					"SELECT * FROM CareYou.[Caregiver] WHERE id = @id AND role = 'Caregiver'"
				);

			if (RoleCheck.recordset.length > 0) {
				console.log("User is authorized as a caregiver");
			}
            const today = new Date();
            const year = today.getFullYear();
            const month = String(today.getMonth() + 1).padStart(2, "0"); // Months are zero-indexed, so add 1
            const day = String(today.getDate()).padStart(2, "0");
            
			const todayDate = `${year}-${month}-${day}`;
			console.log(todayDate); 
            

			const CaregiverAppointmentList = await pool
				.request()
				.input("caregiver_id", sql.Int, id)
				.input("today", sql.Date, todayDate)
				.query(
					"SELECT * FROM CareYou.[Appointment_reminder] WHERE caregiver_id = @caregiver_id AND Date >= @today"
				);

			if (CaregiverAppointmentList.recordset.length > 0) {
				const AppointmentList = CaregiverAppointmentList.recordset.map(
					(row) => ({
                        Appointment_id: row.Appointment_id,
						Appointment_name: row.Appointment_name,
						Date: row.Date,
						StartTime: row.StartTime,
						EndTime: row.EndTime,
						Location: row.Location,
                        
					})
				);
				res.status(200).json(AppointmentList)
			} 
			
		} catch (err) {
			console.error(err);
			res.status(500).send(err.message);
		}
	}
);

router.get(
	"/ShowTodayAppointmentRemailderListForElderly",
	verifyToken,
	async (req, res) => {
		try {
			const id = req.user.id;
			const pool = await sql.connect(config);

			// Check if the user is a caregiver
			const roleCheck = await pool
				.request()
				.input("id", sql.Int, id)
				.query(
					"SELECT * FROM CareYou.[Elderly] WHERE id = @id AND role = 'Elderly'"
				);

			if (roleCheck.recordset.length === 0) {
				return res
					.status(403)
					.send("User is not authorized as a elderly");
			}

			// Get today's date
			const today = new Date();
			const year = today.getFullYear();
			const month = String(today.getMonth() + 1).padStart(2, "0"); // Months are zero-indexed, so add 1
			const day = String(today.getDate()).padStart(2, "0");

			const todayDate = `${year}-${month}-${day}`;
			console.log(todayDate); // Output: 2024-06-15

			// Fetch today's appointments for the elderly user
			const getTodayAppointmentsQuery = `
                SELECT Appointment_name, Date, StartTime, EndTime,Location
                FROM CareYou.Appointment_reminder 
                WHERE elderly_id = @elderly_id AND date = @todayDate
            `;
			const todayAppointmentsResult = await pool
				.request()
				.input("elderly_id", sql.Int, id)
				.input("todayDate", sql.Date, todayDate)
				.query(getTodayAppointmentsQuery);

			if (todayAppointmentsResult.recordset.length === 0) {
				return res.status(404).send("No appointments found for today");
			}

			res.status(200).json(todayAppointmentsResult.recordset);
		} catch (err) {
			console.error(err);
			res.status(500).send("Internal Server Error");
		}
	}
);

router.put(
	"/EditAppointmentReminder/:Appointment_id",
	verifyToken,
	[
		body("Appointment_name")
			.optional()
			.notEmpty()
			.withMessage("Appointment name is required"),
		body("Date")
			.optional()
			.isDate()
			.withMessage("Date must be a valid date"),
		body("StartTime")
			.optional()
			.matches(/^([01]\d|2[0-3]):([0-5]\d):00$/)
			.withMessage("Start time must be in HH:MM format"),
		body("EndTime")
			.optional()
			.matches(/^([01]\d|2[0-3]):([0-5]\d):00$/)
			.withMessage("End time must be in HH:MM format"),
		body("Location")
			.optional()
			.notEmpty()
			.withMessage("Location is required"),
	],
	async (req, res) => {
		const errors = validationResult(req);
		if (!errors.isEmpty()) {
			return res.status(400).json({ errors: errors.array() });
		}

		const { Appointment_id } = req.params;
		const { Appointment_name, Date, StartTime, EndTime, Location } =
			req.body;

		const caregiver_id = req.user.id;

		try {
			const pool = await sql.connect(config.database);

			// Check if the user is a caregiver
			const roleCheck = await pool
				.request()
				.input("id", sql.Int, caregiver_id)
				.query("SELECT role FROM CareYou.[Caregiver] WHERE id = @id");

			if (
				roleCheck.recordset.length === 0 ||
				roleCheck.recordset[0].role !== "Caregiver"
			) {
				return res
					.status(403)
					.send("User is not authorized as a caregiver");
			}

			// Fetch the existing appointment reminder to preserve unchanged fields
			const fetchAppointmentQuery = `
                SELECT *
                FROM CareYou.Appointment_reminder
                WHERE Appointment_id = @Appointment_id
                  AND caregiver_id = @caregiver_id
            `;
			const fetchAppointmentResult = await pool
				.request()
				.input("Appointment_id", sql.Int, Appointment_id)
				.input("caregiver_id", sql.Int, caregiver_id)
				.query(fetchAppointmentQuery);

			if (fetchAppointmentResult.recordset.length === 0) {
				return res
					.status(404)
					.send(
						"Appointment reminder not found or unauthorized to edit"
					);
			}

			const existingAppointment = fetchAppointmentResult.recordset[0];

			// Prepare the update query based on the provided fields
			const updateAppointmentRequest = pool.request();
			let updateAppointmentQuery =
				"UPDATE CareYou.Appointment_reminder SET ";
			const updateParams = [];

			if (Appointment_name !== undefined) {
				updateAppointmentQuery +=
					"Appointment_name = @Appointment_name, ";
				updateParams.push({
					name: "Appointment_name",
					type: sql.VarChar,
					value: Appointment_name,
				});
			} else {
				updateParams.push({
					name: "Appointment_name",
					type: sql.VarChar,
					value: existingAppointment.Appointment_name,
				});
			}

			if (Date !== undefined) {
				updateAppointmentQuery += "Date = @Date, ";
				updateParams.push({
					name: "Date",
					type: sql.Date,
					value: Date,
				});
			} else {
				updateParams.push({
					name: "Date",
					type: sql.Date,
					value: existingAppointment.Date,
				});
			}

			if (StartTime !== undefined) {
				updateAppointmentQuery += "StartTime = @StartTime, ";
				updateParams.push({
					name: "StartTime",
					type: sql.VarChar,
					value: StartTime,
				});
			} else {
				updateParams.push({
					name: "StartTime",
					type: sql.VarChar,
					value: existingAppointment.StartTime,
				});
			}

			if (EndTime !== undefined) {
				updateAppointmentQuery += "EndTime = @EndTime, ";
				updateParams.push({
					name: "EndTime",
					type: sql.VarChar,
					value: EndTime,
				});
			} else {
				updateParams.push({
					name: "EndTime",
					type: sql.VarChar,
					value: existingAppointment.EndTime,
				});
			}

			if (Location !== undefined) {
				updateAppointmentQuery += "Location = @Location ";
				updateParams.push({
					name: "Location",
					type: sql.VarChar,
					value: Location,
				});
			} else {
				updateParams.push({
					name: "Location",
					type: sql.VarChar,
					value: existingAppointment.Location,
				});
			}

			updateAppointmentQuery += "WHERE Appointment_id = @Appointment_id;";

			// Execute the update query
			for (const param of updateParams) {
				updateAppointmentRequest.input(
					param.name,
					param.type,
					param.value
				);
			}

			await updateAppointmentRequest
				.input("Appointment_id", sql.Int, Appointment_id)
				.query(updateAppointmentQuery);

			res.status(200).send("Appointment reminder updated successfully");
		} catch (error) {
			console.error(error);
			res.status(500).send("Internal Server Error");
		}
	}
);

router.delete(
	"/DeleteAppointmentReminder/:Appointment_id",
	verifyToken,
	async (req, res) => {
		const { Appointment_id } = req.params;

		try {
			const pool = await sql.connect(config);

			const id = req.user.id;

			const RoleCheck = await pool
				.request()
				.input("id", sql.Int, id)
				.query(
					"SELECT * FROM CareYou.[Caregiver] WHERE id = @id AND role = 'Caregiver'"
				);

			if (RoleCheck.recordset.length === 0) {
				return res
					.status(403)
					.send("User is not authorized as a Caregiver");
			}

			console.log(RoleCheck);

			// Check if the appointment exists and belongs to the authenticated user
			const checkAppointmentQuery = `
                SELECT *
                FROM CareYou.Appointment_reminder
                WHERE Appointment_id = @Appointment_id
                  AND caregiver_id = (
                      SELECT id
                      FROM CareYou.[Caregiver]
                      WHERE id = @id
                  )
            `;
			const checkAppointmentResult = await pool
				.request()
				.input("Appointment_id", sql.Int, Appointment_id)
				.input("id", sql.Int, id)
				.query(checkAppointmentQuery);

			if (checkAppointmentResult.recordset.length === 0) {
				return res.status(404).json({
					error: "Appointment not found or unauthorized to delete",
				});
			}

			// Delete the appointment
			const deleteAppointmentQuery = `
                DELETE FROM CareYou.Appointment_reminder
                WHERE Appointment_id = @Appointment_id
            `;
			await pool
				.request()
				.input("Appointment_id", sql.Int, Appointment_id)
				.query(deleteAppointmentQuery);

			res.status(200).json({
				message: "Appointment deleted successfully",
			});
		} catch (err) {
			console.error(err);
			res.status(500).json({ error: "Internal Server Error" });
		}
	}
);

module.exports = router;
