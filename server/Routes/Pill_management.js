const { Router } = require("express");
const express = require("express");
const router = express.Router();
const { body, validationResult } = require("express-validator");
const sql = require("mssql");
const config = require("../config");
const verifyToken = require("../middleware/verifyToken");
const moment = require("moment");

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
    body("pill_image").isURL().withMessage("Pill image must be a valid URL"),
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
      pill_image,
      pill_Time,
    } = req.body;

    const caregiver_id = req.user.id;

    try {
      const pool = await sql.connect(config.database);

      const roleCheck = await pool.request().input("id", sql.Int, caregiver_id)
        .query(`
                SELECT role FROM CareYou.[Caregiver] WHERE id = @id
                UNION
                SELECT role FROM CareYou.[Elderly] WHERE id = @id
            `);

      if (
        roleCheck.recordset.length === 0 ||
        roleCheck.recordset[0].role !== "Caregiver"
      ) {
        return res.status(403).send("User is not authorized as a caregiver");
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

      const createPillReminderRequest = pool.request();
      const createPillReminderQuery = `
                INSERT INTO CareYou.Pill_Reminder 
                (pill_name, pill_note, pill_type, start_date, end_date, frequency, NumberofPills, pill_image, pill_Time, caregiver_id, elderly_id) 
                VALUES 
                (@pill_name, @pill_note, @pill_type, @start_date, @end_date, @frequency, @NumberofPills, @pill_image, @pill_Time, @caregiver_id, @elderly_id);
                SELECT SCOPE_IDENTITY() AS PillReminder_id;
            `;

      const createPillReminderResult = await createPillReminderRequest
        .input("pill_name", sql.VarChar, pill_name)
        .input("pill_note", sql.VarChar, pill_note || null)
        .input("pill_type", sql.NVarChar, pill_type)
        .input("start_date", sql.Date, start_date)
        .input("end_date", sql.Date, end_date)
        .input("frequency", sql.Int, frequency)
        .input("NumberofPills", sql.Int, NumberofPills)
        .input("pill_image", sql.VarChar, pill_image)
        .input("pill_Time", sql.NVarChar, pill_Time)
        .input("caregiver_id", sql.Int, caregiver_id)
        .input("elderly_id", sql.Int, elderly_id)
        .query(createPillReminderQuery);

      const PillReminder_id =
        createPillReminderResult.recordset[0].PillReminder_id;
      console.log(reminder_times);
      const startDate = moment(start_date);
      const endDate = moment(end_date);
      let currentDate = startDate.clone();

      const insertReminderTimesPromises = [];

      while (currentDate <= endDate) {
        reminder_times.forEach((time) => {
          const insertReminderTimeRequest = pool.request();
          const insertReminderTimeQuery = `
                        INSERT INTO CareYou.PillReminder_Time (PillReminder_id, reminderDates, reminder_times) 
                        VALUES (@PillReminder_id, @reminderDates, @reminder_times);
                    `;
          insertReminderTimesPromises.push(
            insertReminderTimeRequest
              .input("PillReminder_id", sql.Int, PillReminder_id)
              .input(
                "reminderDates",
                sql.Date,
                currentDate.format("YYYY-MM-DD")
              )
              .input("reminder_times", sql.NVarChar, time)
              .query(insertReminderTimeQuery)
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
      const pool = await sql.connect(config);
      const id = req.user.id;

      const RoleCheck = await pool.request().input("id", sql.Int, id).query(`
                SELECT role FROM CareYou.[Caregiver] WHERE id = @id
                UNION
                SELECT role FROM CareYou.[Elderly] WHERE id = @id
            `);

      if (RoleCheck.recordset.length > 0) {
        console.log("This account is Caregiver");
      }

      const today = new Date().toISOString().split("T")[0];
      const currentDate = new Date().toLocaleString("en-us", {
        weekday: "short",
        day: "numeric",
        year: "numeric",
      });

      const CaregiverPillList = await pool
        .request()
        .input("caregiver_id", sql.Int, id)
        .input("today", sql.Date, today)
        .query(
          "SELECT pill_name, pill_type, pill_note, frequency, pill_Time FROM CareYou.[Pill_Reminder] WHERE caregiver_id = @caregiver_id  AND start_date <= @today AND end_date > @today OR end_date = @today"
        );

      if (CaregiverPillList.recordset.length > 0) {
        const PillList = CaregiverPillList.recordset.map((row) => ({
          pill_name: row.pill_name,
          pill_type: row.pill_type,
          pill_note: row.pill_note,
          frequency: row.frequency,
          pill_Time: row.pill_Time,
        }));
        res.json(PillList);
      }
      res.status(201).send("Pill reminder already show");
    } catch (err) {
      res.status(500).send(err.message);
    }
  }
);

router.get(
  "/ShowPillRemindersListForElderlyPillBoxs",
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

      // Get today's date in 'YYYY-MM-DD' format
      const today = new Date().toISOString().split("T")[0];

      // Fetch today's pill reminders for the elderly
      const elderlyPillList = await pool
        .request()
        .input("elderly_id", sql.Int, id)
        .input("today", sql.Date, today).query(`
                    SELECT 
                        pill_name, 
                        pill_type, 
                        pill_note,  
                        pill_Time,
                        Frequency
                    FROM 
                        CareYou.[Pill_Reminder] 
                    WHERE 
                        elderly_id = @elderly_id
                        AND start_date <= @today 
                        AND end_date >= @today
                        
                `);

      if (elderlyPillList.recordset.length > 0) {
        const pillList = elderlyPillList.recordset.map((row) => ({
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
      const pool = await sql.connect(config);
      const id = req.user.id;

      // Verify the user role
      const RoleCheck = await pool
        .request()
        .input("id", sql.Int, id)
        .query(
          "SELECT * FROM CareYou.[Caregiver] WHERE id = @id AND role = 'Caregiver'"
        );

      if (RoleCheck.recordset.length === 0) {
        return res.status(403).send("Unauthorized access");
      }

      const todays = new Date();
      const year = todays.getFullYear();
      const month = String(todays.getMonth() + 1).padStart(2, "0"); // Months are zero-indexed, so add 1
      const day = String(todays.getDate()).padStart(2, "0");
      const today = `${year}-${month}-${day}`;

      console.log(today);

      // Query to get pill reminders
      const CaregiverPillList = await pool
        .request()
        .input("caregiver_id", sql.Int, id)
        .input("today", sql.Date, today) // Assuming 'today' is '2024-06-20'
        .query(`
                    SELECT 
                        pr.pill_name, 
                        pr.pill_type, 
                        pr.pill_note,  
                        pr.pill_Time,
                        prt.reminder_times,
                        prt.reminderDates,
                        0 AS status
                    FROM 
                        CareYou.[Pill_Reminder] as pr
                    JOIN 
                        CareYou.[PillReminder_Time] as prt 
                    ON 
                        pr.PillReminder_id = prt.PillReminder_id
                    WHERE 
                        pr.caregiver_id = @caregiver_id
                        AND CAST(pr.start_date AS DATE) <= @today
                        AND CAST(pr.end_date AS DATE) >= @today
                        AND CAST(prt.reminderDates AS DATE) = @today

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
                        CareYou.[Pill_Reminder] as pr
                    JOIN 
                        CareYou.[TakenPill] as tp 
                    ON 
                        pr.PillReminder_id = tp.PillReminder_id
                    WHERE 
                        pr.caregiver_id = @caregiver_id
                        AND CAST(pr.start_date AS DATE) <= @today
                        AND CAST(pr.end_date AS DATE) >= @today
                        AND CAST(tp.reminderDates AS DATE) = @today
                `);

      if (CaregiverPillList.recordset.length > 0) {
        const PillList = CaregiverPillList.recordset.map((row) => ({
          pill_name: row.pill_name,
          pill_type: row.pill_type,
          pill_note: row.pill_note,
          pill_Time: row.pill_Time,
          reminderDates: row.reminderDates,
          reminder_times: new Date(row.reminder_times)
            .toISOString()
            .split("T")[1]
            .substring(0, 5),
          // status: row.status === 1 ? "Taken" : "Not Taken"
          status: row.status,
        }));
        res.status(200).json(PillList);
      } else {
        // Return a JSON response with the message
        res.status(204).json({
          message: "Your elder have no pills for today",
        });
      }
    } catch (err) {
      console.error(err);
      res.status(500).send("Internal Server Error");
    }
  }
);

module.exports = router;

router.get(
  "/ShowTodayPillRemailderListForElderly",
  verifyToken,
  async (req, res) => {
    try {
      const pool = await sql.connect(config);
      const id = req.user.id;

      const RoleCheck = await pool
        .request()
        .input("id", sql.Int, id)
        .query(
          "SELECT * FROM CareYou.[Elderly] WHERE id = @id AND role = 'Elderly'"
        );

      if (RoleCheck.recordset.length === 0) {
        return res.status(403).send("Unauthorized access");
      }

      const today = new Date().toISOString().split("T")[0]; // Get today's date in 'YYYY-MM-DD' format

      const CaregiverPillList = await pool
        .request()
        .input("elderly_id", sql.Int, id)
        .input("today", sql.Date, today).query(`
                    SELECT 
                        pr.pill_name, 
                        pr.pill_type, 
                        pr.pill_note,  
                        pr.pill_Time,
                        prt.reminder_times
                    FROM 
                        CareYou.[Pill_Reminder] as pr
                    JOIN 
                        CareYou.[PillReminder_Time] as prt 
                    ON 
                        pr.PillReminder_id = prt.PillReminder_id
                    WHERE 
                        pr.elderly_id = @elderly_id
                        AND pr.start_date <= @today 
                        AND pr.end_date >= @today
                `);

      if (CaregiverPillList.recordset.length > 0) {
        const PillList = CaregiverPillList.recordset.map((row) => ({
          pill_name: row.pill_name,
          pill_type: row.pill_type,
          pill_note: row.pill_note,
          pill_Time: row.pill_Time,
          reminder_times: new Date(row.reminder_times)
            .toISOString()
            .split("T")[1]
            .substring(0, 5),
        }));
        res.status(200).json(PillList);
      } else {
        // Return a JSON response with the message
        res.status(204).json({
          message: "You have no pills for Today",
        });
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
      const pool = await sql.connect(config.database);

      // Check if the user is authorized caregiver
      const roleCheck = await pool
        .request()
        .input("id", sql.Int, caregiver_id)
        .query("SELECT role FROM CareYou.[Caregiver] WHERE id = @id");

      if (
        roleCheck.recordset.length === 0 ||
        roleCheck.recordset[0].role !== "Caregiver"
      ) {
        return res.status(403).send("User is not authorized as a caregiver");
      }

      // Fetch the existing pill reminder to preserve unchanged fields
      const fetchPillReminderQuery = `
                SELECT * FROM CareYou.Pill_Reminder WHERE PillReminder_id = @PillReminder_id;
            `;
      const pillReminderResult = await pool
        .request()
        .input("PillReminder_id", sql.Int, PillReminder_id)
        .query(fetchPillReminderQuery);

      if (pillReminderResult.recordset.length === 0) {
        return res.status(404).send("Pill reminder not found");
      }

      const existingPillReminder = pillReminderResult.recordset[0];

      // Prepare the update query based on the provided fields
      const updatePillReminderRequest = pool.request();
      let updatePillReminderQuery = "UPDATE CareYou.Pill_Reminder SET ";
      const updateParams = [];

      if (pill_name !== undefined) {
        updatePillReminderQuery += "pill_name = @pill_name, ";
        updateParams.push({
          name: "pill_name",
          type: sql.VarChar,
          value: pill_name,
        });
      } else {
        updateParams.push({
          name: "pill_name",
          type: sql.VarChar,
          value: existingPillReminder.pill_name,
        });
      }

      if (pill_note !== undefined) {
        updatePillReminderQuery += "pill_note = @pill_note, ";
        updateParams.push({
          name: "pill_note",
          type: sql.VarChar,
          value: pill_note,
        });
      } else {
        updateParams.push({
          name: "pill_note",
          type: sql.VarChar,
          value: existingPillReminder.pill_note,
        });
      }

      if (pill_type !== undefined) {
        updatePillReminderQuery += "pill_type = @pill_type, ";
        updateParams.push({
          name: "pill_type",
          type: sql.NVarChar,
          value: pill_type,
        });
      } else {
        updateParams.push({
          name: "pill_type",
          type: sql.NVarChar,
          value: existingPillReminder.pill_type,
        });
      }

      if (start_date !== undefined) {
        updatePillReminderQuery += "start_date = @start_date, ";
        updateParams.push({
          name: "start_date",
          type: sql.Date,
          value: start_date,
        });
      } else {
        updateParams.push({
          name: "start_date",
          type: sql.Date,
          value: existingPillReminder.start_date,
        });
      }

      if (end_date !== undefined) {
        updatePillReminderQuery += "end_date = @end_date, ";
        updateParams.push({
          name: "end_date",
          type: sql.Date,
          value: end_date,
        });
      } else {
        updateParams.push({
          name: "end_date",
          type: sql.Date,
          value: existingPillReminder.end_date,
        });
      }

      if (frequency !== undefined) {
        updatePillReminderQuery += "frequency = @frequency, ";
        updateParams.push({
          name: "frequency",
          type: sql.Int,
          value: frequency,
        });
      } else {
        updateParams.push({
          name: "frequency",
          type: sql.Int,
          value: existingPillReminder.frequency,
        });
      }

      if (NumberofPills !== undefined) {
        updatePillReminderQuery += "NumberofPills = @NumberofPills, ";
        updateParams.push({
          name: "NumberofPills",
          type: sql.Int,
          value: NumberofPills,
        });
      } else {
        updateParams.push({
          name: "NumberofPills",
          type: sql.Int,
          value: existingPillReminder.NumberofPills,
        });
      }

      if (pill_image !== undefined) {
        updatePillReminderQuery += "pill_image = @pill_image, ";
        updateParams.push({
          name: "pill_image",
          type: sql.VarChar,
          value: pill_image,
        });
      } else {
        updateParams.push({
          name: "pill_image",
          type: sql.VarChar,
          value: existingPillReminder.pill_image,
        });
      }

      if (pill_Time !== undefined) {
        updatePillReminderQuery += "pill_Time = @pill_Time ";
        updateParams.push({
          name: "pill_Time",
          type: sql.NVarChar,
          value: pill_Time,
        });
      } else {
        updateParams.push({
          name: "pill_Time",
          type: sql.NVarChar,
          value: existingPillReminder.pill_Time,
        });
      }

      updatePillReminderQuery += "WHERE PillReminder_id = @PillReminder_id;";

      // Execute the update query
      for (const param of updateParams) {
        updatePillReminderRequest.input(param.name, param.type, param.value);
      }

      await updatePillReminderRequest
        .input("PillReminder_id", sql.Int, PillReminder_id)
        .query(updatePillReminderQuery);

      // Update reminder times if provided
      if (reminder_times !== undefined && reminder_times.length > 0) {
        // First delete existing reminder times
        const deleteReminderTimesQuery = `
                    DELETE FROM CareYou.PillReminder_Time WHERE PillReminder_id = @PillReminder_id;
                `;
        await pool
          .request()
          .input("PillReminder_id", sql.Int, PillReminder_id)
          .query(deleteReminderTimesQuery);

        // Then insert new reminder times
        const insertReminderTimesPromises = reminder_times.map(async (time) => {
          const formattedTime = `${time}:00`;
          const insertReminderTimeRequest = pool.request();
          const insertReminderTimeQuery = `
                        INSERT INTO CareYou.PillReminder_Time (PillReminder_id, reminder_times) 
                        VALUES (@PillReminder_id, @reminder_times);
                    `;
          try {
            await insertReminderTimeRequest
              .input("PillReminder_id", sql.Int, PillReminder_id)
              .input("reminder_times", sql.NVarChar, formattedTime)
              .query(insertReminderTimeQuery);
            console.log(`Inserted reminder time ${formattedTime}`);
          } catch (err) {
            console.error(
              `Failed to insert reminder time ${formattedTime}:`,
              err
            );
            throw err; // Propagate error to handle it at the top level
          }
        });

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
    return res
      .status(400)
      .send("PillReminder_id and reminder_time are required");
  }

  try {
    const pool = await sql.connect(config);

    // Update the status in the PillReminder_Time table
    const updateResult = await pool
      .request()
      .input("PillReminder_id", sql.Int, PillReminder_id)
      .input("reminder_times", sql.NVarChar, reminder_times)
      .input("status", sql.Int, 1) // status = 1 indicates taken
      .query(`
                UPDATE CareYou.PillReminder_Time 
                SET status = @status 
                WHERE PillReminder_id = @PillReminder_id 
                  AND reminder_times = @reminder_times
            `);

    if (updateResult.rowsAffected[0] === 0) {
      return res.status(404).send("Pill reminder time not found");
    }

    res.status(200).send("Pill status updated successfully");
  } catch (err) {
    console.error(err);
    res.status(500).send("Internal Server Error");
  }
});

router.put("/UpdatePillStatus", verifyToken, async (req, res) => {
  const { PillReminder_id, reminder_times } = req.body;

  // Validate request body
  if (!PillReminder_id || !reminder_times) {
    return res
      .status(400)
      .send("PillReminder_id and reminder_times are required");
  }

  try {
    const pool = await sql.connect(config); // Connect to the database pool
    const elderly_id = req.user.id; // Assuming elderly_id is obtained from the token

    // Verify that the PillReminder_id belongs to the elderly user
    const verifyPillReminder = await pool
      .request()
      .input("PillReminder_id", sql.Int, PillReminder_id)
      .input("elderly_id", sql.Int, elderly_id).query(`
                SELECT * FROM CareYou.Pill_Reminder 
                WHERE PillReminder_id = @PillReminder_id AND elderly_id = @elderly_id
            `);

    if (verifyPillReminder.recordset.length === 0) {
      return res
        .status(403)
        .send("Unauthorized access or PillReminder not found");
    }

    // Start a transaction
    const transaction = new sql.Transaction(pool);

    try {
      await transaction.begin(); // Begin the transaction

      // Insert into the TakenPill table
      const insertQuery = `
                INSERT INTO CareYou.TakenPill (PillReminder_id, reminderTimes, status)
                VALUES (@PillReminder_id, @reminderTimes, 1)
            `;
      await transaction
        .request()
        .input("PillReminder_id", sql.Int, PillReminder_id)
        .input("reminderTimes", sql.NVarChar, reminder_times)
        .query(insertQuery);

      // Delete from the PillReminder_Time table
      const deleteQuery = `
                DELETE FROM CareYou.PillReminder_Time 
                WHERE PillReminder_id = @PillReminder_id 
                  AND reminder_times = @reminder_times
            `;
      await transaction
        .request()
        .input("PillReminder_id", sql.Int, PillReminder_id)
        .input("reminder_times", sql.NVarChar, reminder_times)
        .query(deleteQuery);

      await transaction.commit(); // Commit the transaction

      res
        .status(200)
        .send("Pill status updated and moved to Takenpill successfully");
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
    const pool = await sql.connect(config.database);
    const id = req.user.id;
    const PillReminder_id = req.params.id;

    // Check if the user is a Caregiver or Elderly
    const RoleCheck = await pool.request().input("id", sql.Int, id).query(`
                SELECT role FROM CareYou.[Caregiver] WHERE id = @id
                UNION
                SELECT role FROM CareYou.[Elderly] WHERE id = @id
            `);

    if (RoleCheck.recordset.length === 0) {
      return res.status(403).send("Unauthorized access");
    }

    const userRole = RoleCheck.recordset[0].role;
    if (
      (userRole !== "Caregiver" && userRole !== "Elderly") ||
      userRole == "Elderly"
    ) {
      return res.status(403).send("Unauthorized access");
    }

    // Ensure the pill reminder exists and is associated with the current user
    const PillReminderCheck = await pool
      .request()
      .input("PillReminder_id", sql.Int, PillReminder_id)
      .query(
        "SELECT * FROM CareYou.[Pill_Reminder] WHERE PillReminder_id = @PillReminder_id"
      );

    if (PillReminderCheck.recordset.length === 0) {
      return res.status(404).send("Pill reminder not found");
    }

    const pillReminder = PillReminderCheck.recordset[0];
    if (userRole === "Caregiver" && pillReminder.caregiver_id !== id) {
      return res.status(403).send("Unauthorized access");
    }
    if (userRole === "Elderly" && pillReminder.elderly_id !== id) {
      return res.status(403).send("Unauthorized access");
    }

    // Delete associated reminder times
    await pool
      .request()
      .input("PillReminder_id", sql.Int, PillReminder_id)
      .query(
        "DELETE FROM CareYou.[PillReminder_Time] WHERE PillReminder_id = @PillReminder_id"
      );

    // Delete the pill reminder
    await pool
      .request()
      .input("PillReminder_id", sql.Int, PillReminder_id)
      .query(
        "DELETE FROM CareYou.[Pill_Reminder] WHERE PillReminder_id = @PillReminder_id"
      );

    res.status(200).send("Pill reminder deleted successfully");
  } catch (err) {
    console.error(err);
    res.status(500).send("Internal Server Error");
  }
});

module.exports = router;
