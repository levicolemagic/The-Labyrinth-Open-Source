use AppleScript version "2.4"
use scripting additions

set now to current date
set searchPhrase to "RV Living"
set output to "Searching for events containing '" & searchPhrase & "'..." & return

tell application "Calendar"
	set allCalendars to calendars
	repeat with aCal in allCalendars
		try
			set foundEvents to (every event of aCal whose summary contains searchPhrase and start date is greater than or equal to now)
			if (count of foundEvents) > 0 then
				set output to output & "FOUND in Calendar: " & (name of aCal) & return
				repeat with evt in foundEvents
					set output to output & " - " & (summary of evt) & " @ " & (start date of evt) & return
				end repeat
			end if
		on error
			-- skip broken calendars
		end try
	end repeat
end tell

return output
