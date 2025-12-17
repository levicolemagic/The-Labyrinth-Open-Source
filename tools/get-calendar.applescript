on run argv
	set output to "📅 Schedule (Today & Tomorrow):" & return
	set eventCount to 0

	set now to current date
	set startDate to now
	set time of startDate to 0
	
	-- Calculate End Date (Tomorrow 23:59:59)
	set endDate to startDate + (2 * days) - 1

	tell application "Calendar"
		if (count of argv) is 0 then
			-- Fallback default if no args provided
			set targetNames to {"Work", "Home"}
		else
			set targetNames to argv
		end if
		
		-- Iterate ALL calendars to avoid name resolution bugs
		set allCalendars to calendars
		repeat with aCal in allCalendars
			set calName to name of aCal
			-- Check if this calendar is in our requested list
			if calName is in targetNames then
				try
					-- Fetch events in date range
					set eventList to (every event of aCal whose start date is greater than or equal to startDate and start date is less than or equal to endDate)
					
					repeat with anEvent in eventList
						set evtSummary to summary of anEvent
						set evtStart to start date of anEvent
						set evtEnd to end date of anEvent
						
						set startStr to time string of evtStart
						set endStr to time string of evtEnd
						
						-- Format Date (e.g., "Monday, ")
						set dateStr to date string of evtStart
						
						set output to output & "[" & dateStr & " " & startStr & " - " & endStr & "] " & evtSummary & return
						set eventCount to eventCount + 1
					end repeat
				on error
					-- Ignore errors from specific calendars
				end try
			end if
		end repeat
	end tell

	if eventCount is 0 then
		-- Create comma-separated string of checked calendars
		set checkedList to ""
		repeat with n in targetNames
			set checkedList to checkedList & n & ", "
		end repeat
		if length of checkedList > 2 then
			set checkedList to text 1 thru -3 of checkedList -- remove trailing comma
		end if
		
		return "No events found (Checked: " & checkedList & ")."
	else
		return output
	end if
end run
