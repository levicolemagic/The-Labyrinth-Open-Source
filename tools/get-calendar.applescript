on run argv
	set output to "📅 Schedule (Today & Tomorrow):" & return
	set eventCount to 0

	set now to current date
	set startDate to now
	set time of startDate to 0
	set endDate to startDate + (2 * days) - 1

	tell application "Calendar"
		if (count of argv) is 0 then
			set targetNames to {"Work", "Home"}
		else
			set targetNames to argv
		end if
		
		-- 1. Batch Fetch All Names (Safe operation)
		-- This avoids iterating through broken calendar objects directly
		set allNames to name of calendars
		
		-- 2. Process each requested calendar
		repeat with reqName in targetNames
			set foundIndex to 0
			
			-- Find index in the safe name list
			repeat with i from 1 to count of allNames
				if item i of allNames is (reqName as string) then
					set foundIndex to i
					exit repeat
				end if
			end repeat
			
			-- 3. Access by Index if found
			if foundIndex > 0 then
				try
					set targetCal to calendar foundIndex
					
					-- Fetch events (Safe since we have a valid reference)
					set eventList to (every event of targetCal whose start date is greater than or equal to startDate and start date is less than or equal to endDate)
					
					repeat with anEvent in eventList
						set evtSummary to summary of anEvent
						set evtStart to start date of anEvent
						set evtEnd to end date of anEvent
						
						set startStr to time string of evtStart
						set endStr to time string of evtEnd
						set dateStr to date string of evtStart
						
						set output to output & "[" & dateStr & " " & startStr & " - " & endStr & "] " & evtSummary & return
						set eventCount to eventCount + 1
					end repeat
				on error
					-- Ignore transient errors on specific calendars
				end try
			end if
		end repeat
	end tell

	if eventCount is 0 then
		set checkedList to ""
		repeat with n in targetNames
			set checkedList to checkedList & n & ", "
		end repeat
		if length of checkedList > 2 then
			set checkedList to text 1 thru -3 of checkedList
		end if
		return "No events found (Checked: " & checkedList & ")."
	else
		return output
	end if
end run
