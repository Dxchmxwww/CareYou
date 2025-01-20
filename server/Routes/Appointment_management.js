const express = require("express");
const router = express.Router();
const { body, validationResult } = require("express-validator");
const sql = require('mysql2');
const config = require("../config");
const verifyToken = require("../middleware/verifyToken");
const moment  = require("moment");
const {pool} = require("../config"); 

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
  
	  const { Appointment_name, Date, StartTime, EndTime, Location } = req.body;
	  const caregiver_id = req.user.id;
  
	  try {
		// Check if the user is a caregiver
		const [roleCheck] = await pool.promise().query(
		  "SELECT role FROM careyou.Caregiver WHERE id = ? AND role = 'Caregiver'",
		  [caregiver_id]
		);
  
		if (roleCheck.length === 0 || roleCheck[0].role !== "Caregiver") {
		  return res.status(403).send("User is not authorized as a caregiver");
		}
  
		// Get caregiver's email
		const [GetCaregiveremail] = await pool.promise().query(
		  "SELECT email FROM careyou.Caregiver WHERE id = ? AND role = 'Caregiver'",
		  [caregiver_id]
		);
  
		if (GetCaregiveremail.length === 0) {
		  return res.status(400).send("Caregiver not found");
		}
  
		const Caregiver_email = GetCaregiveremail[0].email;
  
		// Get elderly user by caregiver email
		const [Getelderly_id] = await pool.promise().query(
		  "SELECT id FROM careyou.Elderly WHERE yourcaregiver_email = ? AND role = 'Elderly'",
		  [Caregiver_email]
		);
  
		if (Getelderly_id.length === 0) {
		  return res.status(400).send("Elderly user not found with provided email");
		}
  
		const elderly_id = Getelderly_id[0].id;
  
		// Create appointment reminder
		await pool.promise().query(
		  "INSERT INTO careyou.Appointment_reminder (Appointment_name, Date, StartTime, EndTime, caregiver_id, elderly_id, Location) VALUES (?, ?, ?, ?, ?, ?, ?)",
		  [Appointment_name, Date, StartTime, EndTime, caregiver_id, elderly_id, Location]
		);
  
		res.status(200).send("Appointment reminder created successfully");
	  } catch (error) {
		console.error(error);
		res.status(500).send("Internal Server Error");
	  }
	}
  );
  

  router.get(
	"/ShowTodayAppointmentOfElderForCaregiverHome",
	verifyToken,
	async (req, res) => {
	  try {
		const id = req.user.id;
  
		// Check if the user is a caregiver
		const [roleCheck] = await pool.promise().query(
		  "SELECT * FROM careyou.Caregiver WHERE id = ? AND role = 'Caregiver'",
		  [id]
		);
  
		if (roleCheck.length === 0) {
		  return res.status(403).send("User is not authorized as a caregiver");
		}
  
		// Get today's date in YYYY-MM-DD format
		const today = new Date();
		const year = today.getFullYear();
		const month = String(today.getMonth() + 1).padStart(2, "0");
		const day = String(today.getDate()).padStart(2, "0");
		const todayDate = `${year}-${month}-${day}`;
  
		// Get today's appointments for the caregiver
		const [todayAppointmentsResult] = await pool.promise().query(
		  `SELECT 
			  Appointment_name, 
			  DATE_FORMAT(StartTime, '%H:%i') AS StartTime,  -- Format StartTime as HH:mm
			  DATE_FORMAT(EndTime, '%H:%i') AS EndTime,    -- Format EndTime as HH:mm
			  Location
		  FROM careyou.Appointment_reminder 
		  WHERE caregiver_id = ? AND DATE(Date) = ?`,
		  [id, todayDate]
		);
  
		if (todayAppointmentsResult.length === 0) {
		  return res.status(404).send("No appointments found for today");
		}
  
		// Return the formatted appointments
		const formattedAppointments = todayAppointmentsResult.map(
		  (appointment) => ({
			Appointment_name: appointment.Appointment_name,
			StartTime: appointment.StartTime,
			EndTime: appointment.EndTime,
			Location: appointment.Location,
		  })
		);
  
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
		// Check if the user is elderly
		const elderly_id = req.user.id;
  
		const [roleCheck] = await pool.promise().query(
		  "SELECT * FROM careyou.Elderly WHERE id = ? AND role = 'Elderly'",
		  [elderly_id]
		);
  
		if (roleCheck.length === 0) {
		  return res.status(403).send("User is not authorized as an elderly");
		}
  
		const currentTime = new Date();
		const year = currentTime.getFullYear();
		const month = String(currentTime.getMonth() + 1).padStart(2, "0");
		const day = String(currentTime.getDate()).padStart(2, "0");
  
		// Fetch today's appointments for the elderly
		const [elderlyAppointmentList] = await pool.promise().query(
		  `
			SELECT * 
			FROM careyou.Appointment_reminder
			WHERE elderly_id = ? AND Date >= ?
		  `,
		  [elderly_id, `${year}-${month}-${day}`]
		);
  
		if (elderlyAppointmentList.length > 0) {
		  const AppointmentList = elderlyAppointmentList.map(row => ({
			Appointment_id: row.Appointment_id,
			Appointment_name: row.Appointment_name,
			Date: row.Date,
			StartTime: row.StartTime,
			EndTime: row.EndTime,
			Location: row.Location
		  }));
  
		  res.status(200).json(AppointmentList);
		} else {
		  return res.status(404).send("No appointments found");
		}
  
	  } catch (err) {
		console.error(err);
		res.status(500).send("Internal Server Error");
	  }
	}
  );
  

// router.get(
// 	"/ShowAllInfoAppointmentReminderforCaregiver",
// 	verifyToken,
// 	async (req, res) => {
// 	  try {
// 		const id = req.user.id;
  
// 		// Check if the user is authorized as a caregiver
// 		const [roleCheck] = await pool.promise().query(
// 		  "SELECT * FROM careyou.Caregiver WHERE id = ? AND role = 'Caregiver'",
// 		  [id]
// 		);
  
// 		if (roleCheck.length === 0) {
// 		  return res.status(403).send("User is not authorized as a caregiver");
// 		}
  
// 		// Get today's date
// 		const today = new Date();
// 		const year = today.getFullYear();
// 		const month = String(today.getMonth() + 1).padStart(2, "0"); // Months are zero-indexed, so add 1
// 		const day = String(today.getDate()).padStart(2, "0");
// 		const todayDate = `${year}-${month}-${day}`;
  
// 		console.log(todayDate);
  
// 		// Query to get today's pill reminders
// 		const [todayPillRemindersResult] = await pool.promise().query(
// 		  `
// 			SELECT Pill_name, Dosage, Time
// 			FROM careyou.Pill_Reminder 
// 			WHERE caregiver_id = ? AND date = ?
// 		  `,
// 		  [id, todayDate]
// 		);
  
// 		if (todayPillRemindersResult.length === 0) {
// 		  return res.status(404).send("No pill reminders found for today");
// 		}
  
// 		res.status(200).json(todayPillRemindersResult);
// 	  } catch (err) {
// 		console.error(err);
// 		res.status(500).send("Internal Server Error");
// 	  }
// 	}
//   );
  

router.get(
	"/ShowAppointmentReminderListforCaregiver",
	verifyToken,
	async (req, res) => {
		const id = req.user.id;
	  try {
		
  
		const RoleCheck = await pool.promise().query(
		  "SELECT * FROM careyou.Caregiver WHERE id = ? AND role = 'Caregiver'",
		  [id]
		);
  
		if (RoleCheck[0].length > 0) {
		  console.log("User is authorized as a caregiver");
		}
  
		const today = new Date();
		const year = today.getFullYear();
		const month = String(today.getMonth() + 1).padStart(2, "0"); // Months are zero-indexed, so add 1
		const day = String(today.getDate()).padStart(2, "0");
  
		const todayDate = `${year}-${month}-${day}`;
		console.log(todayDate);
  
		const CaregiverAppointmentList = await pool
		  .promise()
		  .query(
			"SELECT * FROM careyou.Appointment_reminder WHERE caregiver_id = ? AND Date >= ?",
			[id, todayDate]
		  );
  
		if (CaregiverAppointmentList[0].length > 0) {
		  const AppointmentList = CaregiverAppointmentList[0].map((row) => ({
			Appointment_id: row.Appointment_id,
			Appointment_name: row.Appointment_name,
			Date: row.Date,
			StartTime: row.StartTime,
			EndTime: row.EndTime,
			Location: row.Location,
		  }));
		  res.status(200).json(AppointmentList);
		} else {
		  res.status(404).send("No appointments found");
		}
	  } catch (err) {
		console.error(err);
		res.status(500).send(err.message);
	  }
	}
  );
  
  
  router.get(
	"/ShowAllInfoAppointmentRemailderforCaregiver",
	verifyToken,
	async (req, res) => {
	  try {
		const id = req.user.id;
  
		const RoleCheck = await pool.promise().query(
		  "SELECT * FROM careyou.Caregiver WHERE id = ? AND role = 'Caregiver'",
		  [id]
		);
  
		if (RoleCheck[0].length > 0) {
		  console.log("User is authorized as a caregiver");
		}
  
		const CaregiverAppointmentList = await pool
		  .promise()
		  .query(
			"SELECT Appointment_name, Date, StartTime, EndTime, Location FROM careyou.Appointment_reminder WHERE caregiver_id = ?",
			[id]
		  );
  
		if (CaregiverAppointmentList[0].length > 0) {
		  const AppointmentList = CaregiverAppointmentList[0].map((row) => ({
			Appointment_name: row.Appointment_name,
			Date: row.Date,
			StartTime: row.StartTime,
			EndTime: row.EndTime,
			Location: row.Location,
		  }));
		  res.status(200).json(AppointmentList);
		} else {
		  res.status(404).json([]);
		}
	  } catch (err) {
		console.error(err);
		res.status(500).send(err.message);
	  }
	}
  );
  
  router.get(
	"/ShowTodayAppointmentReminderListForElderly",
	verifyToken,
	async (req, res) => {
	  try {
		const id = req.user.id;
		const roleCheck = await pool
		  .promise()
		  .query("SELECT * FROM careyou.Elderly WHERE id = ? AND role = 'Elderly'", [
			id,
		  ]);
  
		if (roleCheck[0].length === 0) {
		  return res.status(403).send("User is not authorized as an elderly");
		}
  
		const today = new Date();
		const year = today.getFullYear();
		const month = String(today.getMonth() + 1).padStart(2, "0");
		const day = String(today.getDate()).padStart(2, "0");
  
		const todayDate = `${year}-${month}-${day}`;
		console.log(todayDate);
  
		const getTodayAppointmentsQuery = `
		  SELECT Appointment_name, Date, StartTime, EndTime, Location
		  FROM careyou.Appointment_reminder 
		  WHERE elderly_id = ? AND date = ?`;
  
		const todayAppointmentsResult = await pool
		  .promise()
		  .query(getTodayAppointmentsQuery, [id, todayDate]);
  
		if (todayAppointmentsResult[0].length === 0) {
		  return res.status(404).send("No appointments found for today");
		}
  
		res.status(200).json(todayAppointmentsResult[0]);
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
            .withMessage("Start time must be in HH:MM:SS format"),
        body("EndTime")
            .optional()
            .matches(/^([01]\d|2[0-3]):([0-5]\d):00$/)
            .withMessage("End time must be in HH:MM:SS format"),
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
        const { Appointment_name, Date, StartTime, EndTime, Location } = req.body;

        const caregiver_id = req.user.id;

        try {

            // Check if the user is a caregiver
            const [roleCheck] = await pool.promise().query(
				"SELECT * FROM careyou.Caregiver WHERE id = ? AND role = 'Caregiver'",
				[caregiver_id]
			);

            if (!roleCheck.length || roleCheck[0].role !== "Caregiver") {
                return res.status(403).send("User is not authorized as a caregiver");
            }

            // Fetch the existing appointment reminder to preserve unchanged fields
            const [fetchAppointmentResult] = await pool
                .promise()
                .query(
                    "SELECT * FROM careyou.Appointment_reminder WHERE Appointment_id = ? AND caregiver_id = ?", 
                    [Appointment_id, caregiver_id]
                );

            if (!fetchAppointmentResult.length) {
                return res.status(404).send("Appointment reminder not found or unauthorized to edit");
            }

            const existingAppointment = fetchAppointmentResult[0];

            // Prepare the update query based on the provided fields
            const updateFields = [];
            const updateValues = [];

            if (Appointment_name !== undefined) {
                updateFields.push("Appointment_name = ?");
                updateValues.push(Appointment_name);
            } else {
                updateValues.push(existingAppointment.Appointment_name);
            }

            if (Date !== undefined) {
                updateFields.push("Date = ?");
                updateValues.push(Date);
            } else {
                updateValues.push(existingAppointment.Date);
            }

            if (StartTime !== undefined) {
                updateFields.push("StartTime = ?");
                updateValues.push(StartTime);
            } else {
                updateValues.push(existingAppointment.StartTime);
            }

            if (EndTime !== undefined) {
                updateFields.push("EndTime = ?");
                updateValues.push(EndTime);
            } else {
                updateValues.push(existingAppointment.EndTime);
            }

            if (Location !== undefined) {
                updateFields.push("Location = ?");
                updateValues.push(Location);
            } else {
                updateValues.push(existingAppointment.Location);
            }

            updateValues.push(Appointment_id);

            const updateQuery = `UPDATE careyou.Appointment_reminder SET ${updateFields.join(", ")} WHERE Appointment_id = ?`;

            // Execute the update query
            await pool.promise().query(updateQuery, updateValues);

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

            const id = req.user.id;

            // Check if the user is a caregiver
            const [roleCheckResult] = await pool.promise().query(
                "SELECT * FROM careyou.Caregiver WHERE id = ? AND role = 'Caregiver'",
                [id]
            );

            if (roleCheckResult.length === 0) {
                return res.status(403).send("User is not authorized as a Caregiver");
            }

            // Check if the appointment exists and belongs to the authenticated user
            const [checkAppointmentResult] = await pool.promise().query(
                `SELECT *
                 FROM careyou.Appointment_reminder
                 WHERE Appointment_id = ?
                   AND caregiver_id = (SELECT id FROM careyou.Caregiver WHERE id = ?)`,
                [Appointment_id, id]
            );

            if (checkAppointmentResult.length === 0) {
                return res.status(404).json({
                    error: "Appointment not found or unauthorized to delete",
                });
            }

            // Delete the appointment
            await pool.promise().query(
                "DELETE FROM careyou.Appointment_reminder WHERE Appointment_id = ?",
                [Appointment_id]
            );

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
