const { Router } = require("express");
const express = require("express");
const router = express.Router();
const { body, validationResult } = require("express-validator");
const sql = require('mysql2');
const config = require("../config");
const verifyToken = require("../middleware/verifyToken");
const moment = require("moment");
const {pool} = require("../config"); 

//-----------------------------------CreatePill------------------------------------
router.post(
	"/CreatePillReminder",
	verifyToken,
	[
	  body("pill_name").notEmpty().withMessage("Pill name is required"),
	  body("pill_note")
		.optional()
		.notEmpty()
		.withMessage("Pill note is required"),
	  body("pill_type").notEmpty().withMessage("Pill type is required"),
	  body("start_date").isDate().withMessage("Start date must be a valid date"),
	  body("end_date").isDate().withMessage("End date must be a valid date"),
	  body("frequency")
		.isInt({ min: 1 })
		.withMessage("Frequency must be a positive integer"),
	  body("reminder_times")
		.isArray({ min: 1 })
		.withMessage(
		  "Reminder times must be an array with at least one time slot"
		),
	  body("reminder_times.*")
		.matches(/^([01]\d|2[0-3]):([0-5]\d)$/)
		.withMessage(
		  "Each reminder time must be in HH:MM:SS format ending with :00"
		),
	  body("NumberofPills")
		.isInt({ min: 1 })
		.withMessage("Number of pills must be a positive integer"),
	  body("pill_Time").notEmpty().withMessage("Pill time is required"),
	],
  
	async (req, res) => {
	  const errors = validationResult(req);
	  if (!errors.isEmpty()) {
		return res.status(400).json({ errors: errors.array() });
	  }
	  const {
		pill_name,
		pill_note,
		pill_type,
		start_date,
		end_date,
		frequency,
		reminder_times,
		NumberofPills,
		pill_Time,
	  } = req.body;
  
	  const caregiver_id = req.user.id;
  
	  try {
  
		const roleCheckQuery = `
		  SELECT role FROM careyou.Caregiver WHERE id = ?
		  UNION
		  SELECT role FROM careyou.Elderly WHERE id = ?
		`;
		const roleCheckResult = await pool.promise().query(roleCheckQuery, [caregiver_id, caregiver_id]);
  
		if (
		  roleCheckResult[0].length === 0 ||
		  roleCheckResult[0][0].role !== "Caregiver"
		) {
		  return res.status(403).send("User is not authorized as a caregiver");
		}
  
		const getCaregiverEmailQuery = `
		  SELECT email FROM careyou.Caregiver WHERE id = ? AND role = 'Caregiver'
		`;
		const getCaregiverEmailResult = await pool.promise().query(getCaregiverEmailQuery, [caregiver_id]);
  
		if (getCaregiverEmailResult[0].length === 0) {
		  return res.status(400).send("Caregiver not found");
		}
  
		const caregiverEmail = getCaregiverEmailResult[0][0].email;
  
		const getElderlyIdQuery = `
		  SELECT id FROM careyou.Elderly WHERE yourcaregiver_email = ? AND role = 'Elderly'
		`;
		const getElderlyIdResult = await pool.promise().query(getElderlyIdQuery, [caregiverEmail]);
  
		if (getElderlyIdResult[0].length === 0) {
		  return res.status(400).send("Elderly user not found with provided email");
		}
  
		const elderly_id = getElderlyIdResult[0][0].id;
  
		const createPillReminderQuery = `
		  INSERT INTO careyou.Pill_Reminder 
		  (pill_name, pill_note, pill_type, start_date, end_date, frequency, NumberofPills, pill_Time, caregiver_id, elderly_id) 
		  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
		`;
		const createPillReminderResult = await pool.promise().query(createPillReminderQuery, [
		  pill_name,
		  pill_note || null,
		  pill_type,
		  start_date,
		  end_date,
		  frequency,
		  NumberofPills,
		  pill_Time,
		  caregiver_id,
		  elderly_id
		]);
  
		const pillReminderId = createPillReminderResult[0].insertId;
  
		const startDate = moment(start_date);
		const endDate = moment(end_date);
		let currentDate = startDate.clone();
  
		const insertReminderTimesPromises = [];
  
		while (currentDate <= endDate) {
		  reminder_times.forEach((time) => {
			const insertReminderTimeQuery = `
			  INSERT INTO careyou.PillReminder_Time (PillReminder_id, reminderDates, reminder_times) 
			  VALUES (?, ?, ?);
			`;
			insertReminderTimesPromises.push(
			  pool.promise().query(insertReminderTimeQuery, [
				pillReminderId,
				currentDate.format("YYYY-MM-DD"),
				time
			  ])
			);
		  });
		  currentDate.add(1, "days"); // Move to the next day
		}
  
		await Promise.all(insertReminderTimesPromises);
  
		res.status(201).send("Pill reminder created successfully");
	  } catch (error) {
		console.error(error);
		res.status(500).send("Internal Server Error");
	  }
	}
  );
  
  
  
  router.get(
	"/ShowPillRemailderListForCaregiver",
	verifyToken,
	async (req, res) => {
	  try {
		const id = req.user.id;
  
		// Check if the user is a caregiver
		const roleCheck = await pool
		  .promise()
		  .query(
			"SELECT * FROM careyou.Caregiver WHERE id = ? AND role = 'Caregiver'",
			[id]
		  );
  
		if (roleCheck[0].length === 0) {
		  return res.status(403).send("Unauthorized access");
		}
  
		// Determine today's date in SQL-compatible format (YYYY-MM-DD)
		const today = new Date();
		const todayDate = today.toISOString().split("T")[0];
  
		// Fetch pill reminders
		const query = `
		  SELECT 
			PillReminder_id, pill_name, pill_type, pill_note, frequency, pill_Time 
		  FROM 
			careyou.Pill_Reminder 
		  WHERE 
			caregiver_id = ? 
			AND (
			  (Start_date <= ? AND End_date >= ?) OR 
			  (Start_date > ?)
			)
		`;
  
		const result = await pool
		  .promise()
		  .query(query, [id, todayDate, todayDate, todayDate]);
  
		if (result[0].length > 0) {
		  const PillList = result[0].map((row) => ({
			PillReminder_id: row.PillReminder_id,
			pill_name: row.pill_name,
			pill_type: row.pill_type,
			pill_note: row.pill_note,
			frequency: row.frequency,
			pill_Time: row.pill_Time,
		  }));
		  res.status(200).json(PillList);
		} else {
		  res.status(204).json({ message: "No pill reminders found" });
		}
	  } catch (err) {
		console.error("Error fetching pill reminders:", err);
		res.status(500).send("Internal Server Error");
	  }
	}
  );
  
  router.get(
	"/ShowPillRemindersListForElderlyPillBoxs",
	verifyToken,
	async (req, res) => {
	  try {
		const id = req.user.id;
  
		// Check if the user is elderly
		const roleCheck = await pool
		  .promise()
		  .query(
			"SELECT * FROM careyou.Elderly WHERE id = ? AND role = 'Elderly'",
			[id]
		  );
  
		if (roleCheck[0].length === 0) {
		  return res.status(403).send("Unauthorized access");
		}
  
		// Get today's date in 'YYYY-MM-DD' format
		const today = new Date().toISOString().split("T")[0];
  
		// Fetch today's pill reminders for the elderly
		const elderlyPillList = await pool
		  .promise()
		  .query(
			`
			SELECT 
			  pill_name, 
			  pill_type, 
			  pill_note,  
			  pill_Time,
			  Frequency
			FROM 
			  careyou.Pill_Reminder
			WHERE 
			  elderly_id = ? 
			  AND start_date <= ? 
			  AND end_date >= ?
		  `,
			[id, today, today]
		  );
  
		if (elderlyPillList[0].length > 0) {
		  const pillList = elderlyPillList[0].map((row) => ({
			pill_name: row.pill_name,
			pill_type: row.pill_type,
			pill_note: row.pill_note,
			pill_Time: row.pill_Time,
			frequency: row.Frequency,
		  }));
		  res.status(200).json(pillList);
		} else {
		  res.status(404).send("No pill reminders found for today");
		}
	  } catch (err) {
		console.error(err);
		res.status(500).send("Internal Server Error");
	  }
	}
  );
  
  router.get(
	"/ShowTodayPillRemindersOfElderForCaregiverHome",
	verifyToken,
	async (req, res) => {
	  try {
		const id = req.user.id;
  
		// Verify the user role
		const RoleCheck = await pool.promise().query(
		  "SELECT * FROM careyou.Caregiver WHERE id = ? AND role = 'Caregiver'",
		  [id]
		);
  
		if (RoleCheck[0].length === 0) {
		  return res.status(403).send("Unauthorized access");
		}
  
		const todays = new Date();
		const year = todays.getFullYear();
		const month = String(todays.getMonth() + 1).padStart(2, "0");
		const day = String(todays.getDate()).padStart(2, "0");
		const today = `${year}-${month}-${day}`;
  
		console.log(today);
  
		// Query to get pill reminders
		const CaregiverPillList = await pool
		  .promise()
		  .query(
			`
			  SELECT 
				  pr.pill_name, 
				  pr.pill_type, 
				  pr.pill_note,  
				  pr.pill_Time,
				  prt.reminder_times,
				  prt.reminderDates,
				  0 AS status
			  FROM 
				  careyou.Pill_Reminder as pr
			  JOIN 
				  careyou.PillReminder_Time as prt 
			  ON 
				  pr.PillReminder_id = prt.PillReminder_id
			  WHERE 
				  pr.caregiver_id = ?
				  AND CAST(pr.start_date AS DATE) <= ?
				  AND CAST(pr.end_date AS DATE) >= ?
				  AND CAST(prt.reminderDates AS DATE) = ?
  
			  UNION ALL
  
			  SELECT 
				  pr.pill_name, 
				  pr.pill_type, 
				  pr.pill_note,  
				  pr.pill_Time,
				  tp.reminderTimes AS reminder_times,
				  tp.reminderDates AS reminderDates,
				  1 AS status
			  FROM 
				  careyou.Pill_Reminder as pr
			  JOIN
				  careyou.TakenPill as tp 
			  ON 
				  pr.PillReminder_id = tp.PillReminder_id
			  WHERE 
				  pr.caregiver_id = ?
				  AND CAST(pr.start_date AS DATE) <= ?
				  AND CAST(pr.end_date AS DATE) >= ?
				  AND CAST(tp.reminderDates AS DATE) = ?
			`,
			[id, today, today, today, id, today, today, today]
		  );
  
		if (CaregiverPillList[0].length > 0) {
		  const PillList = CaregiverPillList[0].map((row) => ({
			pill_name: row.pill_name,
			pill_type: row.pill_type,
			pill_note: row.pill_note,
			pill_Time: row.pill_Time,
			reminderDates: row.reminderDates,
			reminder_times: new Date(row.reminder_times)
			  .toISOString()
			  .split("T")[1]
			  .substring(0, 5),
			status: row.status,
		  }));
		  res.status(200).json(PillList);
		} else {
		  res.status(204).send( "Your elder has no pills for today");
		}
	  } catch (err) {
		console.error(err);
		res.status(500).send("Internal Server Error");
	  }
	}
  );
  
  router.get(
	"/ShowTodayPillRemailderListForElderly",
	verifyToken,
	async (req, res) => {
	  try {
		const id = req.user.id;
  
		const RoleCheck = await pool.promise().query(
		  "SELECT * FROM careyou.Elderly WHERE id = ? AND role = 'Elderly'",
		  [id]
		);
  
		if (RoleCheck[0].length === 0) {
		  return res.status(403).send("Unauthorized access");
		}
  
		const todays = new Date();
		const year = todays.getFullYear();
		const month = String(todays.getMonth() + 1).padStart(2, "0");
		const day = String(todays.getDate()).padStart(2, "0");
		const today = `${year}-${month}-${day}`;
  
		console.log(today);
  
		const CaregiverPillList = await pool
		  .promise()
		  .query(
			`
			  SELECT 
				  pr.PillReminder_id,
				  pr.pill_name, 
				  pr.pill_type, 
				  pr.pill_note,  
				  pr.pill_Time,
				  prt.reminderDates,
				  prt.reminder_times
			  FROM 
				  careyou.Pill_Reminder as pr
			  JOIN 
				  careyou.PillReminder_Time as prt 
			  ON 
				  pr.PillReminder_id = prt.PillReminder_id
			  WHERE 
				  pr.elderly_id = ?
				  AND CAST(pr.start_date AS DATE) <= ?
				  AND CAST(pr.end_date AS DATE) >= ?
				  AND CAST(prt.reminderDates AS DATE) = ?
			`,
			[id, today, today, today]
		  );
  
		if (CaregiverPillList[0].length > 0) {
		  const PillList = CaregiverPillList[0].map((row) => ({
			PillReminder_id: row.PillReminder_id,
			pill_name: row.pill_name,
			pill_type: row.pill_type,
			pill_note: row.pill_note,
			pill_Time: row.pill_Time,
			reminderDates: row.reminderDates,
			reminder_times: new Date(row.reminder_times)
			  .toISOString()
			  .split("T")[1]
			  .substring(0, 5),
		  }));
		  res.status(200).json(PillList);
		} else {
		  res.status(204).send( "You have no pills for today",);
		}
	  } catch (err) {
		console.error(err);
		res.status(500).send(err.message);
	  }
	}
  );

  router.put(
	"/EditPillReminder/:PillReminder_id",
	verifyToken,
	[
		body("pill_name")
			.optional()
			.notEmpty()
			.withMessage("Pill name is required"),
		body("pill_note")
			.optional()
			.notEmpty()
			.withMessage("Pill note is required"),
		body("pill_type")
			.optional()
			.notEmpty()
			.withMessage("Pill type is required"),
		body("start_date")
			.optional()
			.isDate()
			.withMessage("Start date must be a valid date"),
		body("end_date")
			.optional()
			.isDate()
			.withMessage("End date must be a valid date"),
		body("frequency")
			.optional()
			.isInt({ min: 1 })
			.withMessage("Frequency must be a positive integer"),
		body("reminder_times")
			.optional()
			.isArray({ min: 1 })
			.withMessage(
				"Reminder times must be an array with at least one time slot"
			),
		body("reminder_times.*")
			.optional()
			.matches(/^([01]\d|2[0-3]):([0-5]\d)$/)
			.withMessage(
				"Each reminder time must be in HH:MM format ending with :00"
			),
		body("NumberofPills")
			.optional()
			.isInt({ min: 1 })
			.withMessage("Number of pills must be a positive integer"),
		body("pill_image")
			.optional()
			.isURL()
			.withMessage("Pill image must be a valid URL"),
		body("pill_Time")
			.optional()
			.notEmpty()
			.withMessage("Pill time is required"),
	],

	async (req, res) => {
		const errors = validationResult(req);
		if (!errors.isEmpty()) {
			return res.status(400).json({ errors: errors.array() });
		}

		const { PillReminder_id } = req.params;
		const {
			pill_name,
			pill_note,
			pill_type,
			start_date,
			end_date,
			frequency,
			reminder_times,
			NumberofPills,
			pill_image,
			pill_Time,
		} = req.body;

		const caregiver_id = req.user.id;

		try {

			// Check if the user is authorized caregiver
			const roleCheckQuery = `
				SELECT role FROM careyou.Caregiver WHERE id = ?
			`;
			const roleCheckResult = await pool.promise().query(roleCheckQuery, [caregiver_id]);

			if (
				roleCheckResult[0].length === 0 ||
				roleCheckResult[0][0].role !== "Caregiver"
			) {
				return res
					.status(403)
					.send("User is not authorized as a caregiver");
			}

			// Fetch the existing pill reminder to preserve unchanged fields
			const fetchPillReminderQuery = `
				SELECT * FROM careyou.Pill_Reminder WHERE PillReminder_id = ?
			`;
			const pillReminderResult = await pool.promise().query(fetchPillReminderQuery, [PillReminder_id]);

			if (pillReminderResult[0].length === 0) {
				return res.status(404).send("Pill reminder not found");
			}

			const existingPillReminder = pillReminderResult[0][0];

			// Prepare the update query based on the provided fields
			let updatePillReminderQuery = "UPDATE careyou.Pill_Reminder SET ";
			const updateParams = [];

			if (pill_name !== undefined) {
				updatePillReminderQuery += "pill_name = ?, ";
				updateParams.push(pill_name);
			} else {
				updateParams.push(existingPillReminder.pill_name);
			}

			if (pill_note !== undefined) {
				updatePillReminderQuery += "pill_note = ?, ";
				updateParams.push(pill_note);
			} else {
				updateParams.push(existingPillReminder.pill_note);
			}

			if (pill_type !== undefined) {
				updatePillReminderQuery += "pill_type = ?, ";
				updateParams.push(pill_type);
			} else {
				updateParams.push(existingPillReminder.pill_type);
			}

			if (start_date !== undefined) {
				updatePillReminderQuery += "start_date = ?, ";
				updateParams.push(start_date);
			} else {
				updateParams.push(existingPillReminder.start_date);
			}

			if (end_date !== undefined) {
				updatePillReminderQuery += "end_date = ?, ";
				updateParams.push(end_date);
			} else {
				updateParams.push(existingPillReminder.end_date);
			}

			if (frequency !== undefined) {
				updatePillReminderQuery += "frequency = ?, ";
				updateParams.push(frequency);
			} else {
				updateParams.push(existingPillReminder.frequency);
			}

			if (NumberofPills !== undefined) {
				updatePillReminderQuery += "NumberofPills = ?, ";
				updateParams.push(NumberofPills);
			} else {
				updateParams.push(existingPillReminder.NumberofPills);
			}

			if (pill_image !== undefined) {
				updatePillReminderQuery += "pill_image = ?, ";
				updateParams.push(pill_image);
			} else {
				updateParams.push(existingPillReminder.pill_image);
			}

			if (pill_Time !== undefined) {
				updatePillReminderQuery += "pill_Time = ? ";
				updateParams.push(pill_Time);
			} else {
				updateParams.push(existingPillReminder.pill_Time);
			}

			updatePillReminderQuery += "WHERE PillReminder_id = ?";

			// Execute the update query
			await pool.promise().query(updatePillReminderQuery, [...updateParams, PillReminder_id]);

			// Update reminder times if provided
			if (reminder_times !== undefined && reminder_times.length > 0) {
				// First delete existing reminder times
				const deleteReminderTimesQuery = `
					DELETE FROM careyou.PillReminder_Time WHERE PillReminder_id = ?
				`;
				await pool.promise().query(deleteReminderTimesQuery, [PillReminder_id]);

				const startDate = moment(start_date);
				const endDate = moment(end_date);
				let currentDate = startDate.clone();
		
				const insertReminderTimesPromises = [];
		
				while (currentDate <= endDate) {
				reminder_times.forEach((time) => {
					const insertReminderTimeQuery = `
					INSERT INTO careyou.PillReminder_Time (PillReminder_id, reminderDates, reminder_times) 
					VALUES (?, ?, ?);
					`;
					insertReminderTimesPromises.push(
					pool.promise().query(insertReminderTimeQuery, [
						PillReminder_id,
						currentDate.format("YYYY-MM-DD"),
						time
					])
					);
				});
				currentDate.add(1, "days"); // Move to the next day
				}

				await Promise.all(insertReminderTimesPromises);
			}

			res.status(200).send("Pill reminder updated successfully");
		} catch (error) {
			console.error(error);
			res.status(500).send("Internal Server Error");
		}
	}
);


router.put("/UpdatePillStatus", verifyToken, async (req, res) => {
    const { PillReminder_id, reminder_times } = req.body;

    // Validate request body
    if (!PillReminder_id || !reminder_times) {
        return res.status(400).send("PillReminder_id and reminder_times are required");
    }

    try {
        const elderly_id = req.user.id; // Assuming elderly_id is obtained from the token

        const verifyPillReminder = await pool.promise().query(`
            SELECT pr.*, prt.reminder_times 
            FROM careyou.Pill_Reminder pr
            JOIN careyou.PillReminder_Time prt ON pr.PillReminder_id = prt.PillReminder_id
            WHERE pr.PillReminder_id = ? 
              AND pr.elderly_id = ?
              AND prt.reminder_times = ?`, [PillReminder_id, elderly_id, reminder_times]);

        if (verifyPillReminder[0].length === 0) {
            return res.status(403).send("Unauthorized access or PillReminder not found");
        }

        // Start a transaction
        const transaction = await pool.beginTransaction();

        try {
            const todays = new Date();
            const year = todays.getFullYear();
            const month = String(todays.getMonth() + 1).padStart(2, "0"); // Months are zero-indexed, so add 1
            const day = String(todays.getDate()).padStart(2, "0");
            const today = `${year}-${month}-${day}`;

            console.log(today);

            // Insert into the TakenPill table
            const insertQuery = `
                INSERT INTO careyou.TakenPill (PillReminder_id, reminderDates, reminderTimes, status)
                VALUES (?, ?, ?, 1)
            `;
            const insertResult = await transaction.query(insertQuery, [PillReminder_id, today, reminder_times]);

            console.log("Insert Result:", insertResult);

            // Delete from the PillReminder_Time table
            const deleteQuery = `
                DELETE FROM careyou.PillReminder_Time
                WHERE PillReminder_id = ? 
                  AND reminder_times = ?
            `;
            const deleteResult = await transaction.query(deleteQuery, [PillReminder_id, reminder_times]);

            console.log("Delete Result:", deleteResult);

            await transaction.commit(); // Commit the transaction
            console.log("Transaction committed successfully");

            res.status(200).send("Pill status updated and moved to TakenPill successfully");
        } catch (err) {
            await transaction.rollback(); // Rollback transaction on error
            console.error("Transaction Error:", err);
            res.status(500).send("Transaction failed. Pill status not updated.");
        }
    } catch (err) {
        console.error("Connection Error:", err);
        res.status(500).send("Internal Server Error");
    }
});

router.delete("/DeletePillReminder/:id", verifyToken, async (req, res) => {
	try {
	  const id = req.user.id;
	  const PillReminder_id = req.params.id;
  
	  // Check if the user is a Caregiver or Elderly
	  const RoleCheck = await pool.promise().query(`
		SELECT role FROM careyou.Caregiver WHERE id = ?
		UNION
		SELECT role FROM careyou.Elderly WHERE id = ?`, [id, id]);
  
	  if (RoleCheck[0].length === 0) {
		return res.status(403).send("Unauthorized access");
	  }
  
	  const userRole = RoleCheck[0][0].role;
	  if (
		(userRole !== "Caregiver" && userRole !== "Elderly") ||
		userRole == "Elderly"
	  ) {
		return res.status(403).send("Unauthorized access");
	  }
  
	  // Ensure the pill reminder exists and is associated with the current user
	  const PillReminderCheck = await pool.promise().query(
		"SELECT * FROM careyou.Pill_Reminder WHERE PillReminder_id = ?", 
		[PillReminder_id]
	  );
  
	  if (PillReminderCheck[0].length === 0) {
		return res.status(404).send("Pill reminder not found");
	  }
	  
	  const pillReminder = PillReminderCheck[0][0];
	  if (userRole === "Caregiver" && pillReminder.caregiver_id !== id) {
		return res.status(403).send("Unauthorized access");
	  }
	  if (userRole === "Elderly" && pillReminder.elderly_id !== id) {
		return res.status(403).send("Unauthorized access");
	  }
  
	  // Start a transaction
	  const connection = await pool.promise().getConnection();
  
	  try {
		// Begin a transaction
		await connection.beginTransaction();
  
		// Delete associated reminder times
		await connection.query(
		  "DELETE FROM careyou.PillReminder_Time WHERE PillReminder_id = ?", 
		  [PillReminder_id]
		);
  
		// Delete taken pills records
		await connection.query(
		  "DELETE FROM careyou.TakenPill WHERE PillReminder_id = ?", 
		  [PillReminder_id]
		);
  
		// Delete the pill reminder itself
		await connection.query(
		  "DELETE FROM careyou.Pill_Reminder WHERE PillReminder_id = ?", 
		  [PillReminder_id]
		);
  
		// Commit the transaction if all queries succeed
		await connection.commit();
  
		res.status(200).send("Pill reminder deleted successfully");
	  } catch (err) {
		// Rollback the transaction if any query fails
		await connection.rollback();
		console.error(err);
		res.status(500).send("Failed to delete pill reminder");
	  } finally {
		// Release the connection back to the pool
		connection.release();
	  }
	} catch (err) {
	  console.error(err);
	  res.status(500).send("Internal Server Error");
	}
  });
  


module.exports = router;











