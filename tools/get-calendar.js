#!/usr/bin/env osascript -l JavaScript

function run(argv) {
    const Calendar = Application("Calendar");
    const output = [];
    
    // Get today's date range
    const now = new Date();
    const startOfDay = new Date(now);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(now);
    endOfDay.setHours(23, 59, 59, 999);

    // Helper to format time
    function formatTime(date) {
        return date.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: false });
    }

    // Get all calendars
    const calendars = Calendar.calendars();

    for (let cal of calendars) {
        try {
            // Include main calendars, exclude holidays/birthdays if desired (but keeping simple for now)
            const events = cal.events.whose({
                startDate: { _greaterThan: startOfDay },
                endDate: { _lessThan: endOfDay }
            })();

            for (let event of events) {
                try {
                    const start = formatTime(event.startDate());
                    const end = formatTime(event.endDate());
                    const summary = event.summary();
                    const location = event.location() || "";
                    
                    let line = `[${start}-${end}] ${summary}`;
                    if (location) line += ` (@ ${location})`;
                    
                    output.push(line);
                } catch (e) {
                    // Skip problematic events
                }
            }
        } catch (e) {
            // Skip problematic calendars
        }
    }

    if (output.length === 0) {
        return "No events scheduled for today.";
    }

    return "📅 Today's Schedule:\n" + output.sort().join("\n");
}
