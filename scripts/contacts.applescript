-- contacts.applescript
-- Usage: osascript contacts.applescript <action> [args...]
-- Actions:
--   list                        → list all contacts (name + phone + email)
--   search <query>              → search by name
--   get <name>                  → get full details for a contact

on run argv
	set action to item 1 of argv

	if action is "list" then
		return listContacts()
	else if action is "search" then
		set query to item 2 of argv
		return searchContacts(query)
	else if action is "get" then
		set contactName to item 2 of argv
		return getContact(contactName)
	else
		return "Unknown action: " & action
	end if
end run

on listContacts()
	set output to ""
	tell application "Contacts"
		set allPeople to every person
		repeat with p in allPeople
			set pName to name of p
			set pLine to pName
			try
				set pPhone to value of phone 1 of p
				set pLine to pLine & " | " & pPhone
			end try
			try
				set pEmail to value of email 1 of p
				set pLine to pLine & " | " & pEmail
			end try
			set output to output & pLine & linefeed
		end repeat
	end tell
	return output
end listContacts

on searchContacts(query)
	set output to ""
	set lQuery to do shell script "echo " & quoted form of query & " | tr '[:upper:]' '[:lower:]'"
	tell application "Contacts"
		set allPeople to every person
		repeat with p in allPeople
			set pName to name of p
			set lName to do shell script "echo " & quoted form of pName & " | tr '[:upper:]' '[:lower:]'"
			if lName contains lQuery then
				set pLine to pName
				try
					set pPhone to value of phone 1 of p
					set pLine to pLine & " | " & pPhone
				end try
				try
					set pEmail to value of email 1 of p
					set pLine to pLine & " | " & pEmail
				end try
				set output to output & pLine & linefeed
			end if
		end repeat
	end tell
	if output is "" then return "No contacts found for: " & query
	return output
end searchContacts

on getContact(contactName)
	set output to ""
	tell application "Contacts"
		set matches to (every person whose name contains contactName)
		repeat with p in matches
			set output to output & "Name: " & name of p & linefeed
			try
				set phones to every phone of p
				repeat with ph in phones
					set output to output & "Phone (" & label of ph & "): " & value of ph & linefeed
				end repeat
			end try
			try
				set emails to every email of p
				repeat with em in emails
					set output to output & "Email (" & label of em & "): " & value of em & linefeed
				end repeat
			end try
			try
				set output to output & "Birthday: " & (birth date of p as string) & linefeed
			end try
			try
				set output to output & "Note: " & note of p & linefeed
			end try
			set output to output & "---" & linefeed
		end repeat
	end tell
	if output is "" then return "No contact found: " & contactName
	return output
end getContact
