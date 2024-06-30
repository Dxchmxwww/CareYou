const express = require('express');
const router = express.Router();
const sql = require('mssql');
const config = require('../config');
const verifyToken = require('../middleware/verifyToken');

router.get('/GetUpcomingPillReminders', verifyToken, async (req, res) => {
    const elderly_id = req.user.id;

    try {
        const pool = await sql.connect(config.database);
        const currentTime = new Date();

        const year = currentTime.getFullYear();
        const month = String(currentTime.getMonth() + 1).padStart(2, "0");
        const day = String(currentTime.getDate()).padStart(2, "0");
        const hours = String(currentTime.getHours()).padStart(2, "0");
        const minutes = String(currentTime.getMinutes()).padStart(2, "0");
        // const minutesplus = String(currentTime.getMinutes()+2).padStart(2, "0");
        const currentMinute = `${hours}:${minutes}:00`;
        // const currentMinutePlus = `${hours}:${minutesplus}:00`;
        console.log(currentMinute)
        console.log(`${year}-${month}-${day}`)

        const getUpcomingRemindersQuery = `
            SELECT 
                prt.time_id,
                pr.Pill_name, 
                pr.Pill_type, 
                pr.NumberofPills,
                pr.Pill_Time,
                CONVERT(VARCHAR, prt.reminderDates, 23) AS reminderDates,
                CONVERT(VARCHAR, prt.reminder_times, 108) AS reminder_times
            FROM 
                CareYou.Pill_Reminder pr
            JOIN 
                CareYou.PillReminder_Time prt ON pr.PillReminder_id = prt.PillReminder_id
            WHERE 
                pr.elderly_id = @elderly_id 
                AND prt.reminderDates = @today
                AND prt.reminder_times >= @currentMinute    
               
            ORDER BY 
                prt.reminderDates ASC, prt.reminder_times ASC;
        `;
        console.log(getUpcomingRemindersQuery);
        // AND prt.reminder_times = @currentMinute
        const result = await pool.request()
            .input('elderly_id', sql.Int, elderly_id)
            .input('today', sql.Date, `${year}-${month}-${day}`)
            .input('currentMinute', sql.VarChar, currentMinute)
            // .input('currentMinute2', sql.VarChar, currentMinutePlus)
            .query(getUpcomingRemindersQuery);

        const upcomingReminders = result.recordset;

        if (upcomingReminders.length > 0) {
            console.log(upcomingReminders);
            res.status(200).json(upcomingReminders);
        } else {
            res.status(201).json({ message: 'No pills to take at this time.' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).send('Internal Server Error');
    }
});


module.exports = router;
