const express = require('express');
const router = express.Router();
const sql = require('mysql2');
const config = require('../config');
const verifyToken = require('../middleware/verifyToken');
const {pool} = require("../config"); 

router.get(
    "/GetUpcomingPillReminders",
    verifyToken,
    async (req, res) => {
        try {
            const elderly_id = req.user.id;

            // Get today's date and current time
            const currentTime = new Date();
            const year = currentTime.getFullYear();
            const month = String(currentTime.getMonth() + 1).padStart(2, "0");
            const day = String(currentTime.getDate()).padStart(2, "0");
            const hours = String(currentTime.getHours()).padStart(2, "0");
            const minutes = String(currentTime.getMinutes()).padStart(2, "0");
            const currentMinute = `${hours}:${minutes}:00`;
            const todayDate = `${year}-${month}-${day}`;

            console.log(currentMinute);
            console.log(todayDate);

            // Query to get upcoming pill reminders
            const [upcomingRemindersResult] = await config.pool.promise().query(
                `SELECT 
                    prt.time_id,
                    pr.Pill_name, 
                    pr.Pill_type, 
                    pr.NumberofPills,
                    pr.Pill_Time,
                    DATE_FORMAT(prt.reminderDates, '%Y-%m-%d') AS reminderDates,
                    DATE_FORMAT(prt.reminder_times, '%H:%i:%s') AS reminder_times
                FROM 
                    careyou.Pill_Reminder pr
                JOIN 
                    careyou.PillReminder_Time prt ON pr.PillReminder_id = prt.PillReminder_id
                WHERE 
                    pr.elderly_id = ? 
                    AND prt.reminderDates = ?
                    AND prt.reminder_times >= ?
                ORDER BY 
                    prt.reminderDates ASC, prt.reminder_times ASC`,
                [elderly_id, todayDate, currentMinute]
            );

            if (upcomingRemindersResult.length > 0) {
                console.log(upcomingRemindersResult);
                res.status(200).json(upcomingRemindersResult);
            } else {
                res.status(201).json({ message: "No pills to take at this time." });
            }
        } catch (error) {
            console.error(error);
            res.status(500).send("Internal Server Error");
        }
    }
);



module.exports = router;
