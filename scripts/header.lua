case_info = {
	court = {
		location = "",
		name = "",
		district = "",
		division = "",
		heading = "",
	},
	reconvention = false,
	case_no = "",
	applicants = {},
	respondents = {},
}

function trim(s)
	return s and s:match("^%s*(.-)%s*$") or ""
end

function process_case_info(filepath)
	local file = io.open(filepath, "r")
	if not file then
		tex.error("Cannot open " .. filepath)
		return
	end

	local current_section = nil
	local info = {
		["court name"] = "",
		["court location"] = "",
		["court district"] = "",
		["court division"] = "",
		["case no"] = "",
		["reconvention"] = "",
	}

	for line in file:lines() do
		line = trim(line)

		if line ~= "" then
			local key, value = line:match("^(.-)%s*=%s*(.*)%s*$")

			if key and value then
				key = key:lower()
				if info[key] ~= nil then
					info[key] = value
				end
			elseif line == "[Applicants]" then
				current_section = "applicants"
			elseif line == "[Respondents]" then
				current_section = "respondents"
			elseif current_section == "applicants" then
				table.insert(case_info.applicants, line)
			elseif current_section == "respondents" then
				table.insert(case_info.respondents, line)
			end
		end
	end

	file:close()

	local court_name = info["court name"]:upper()
	local court_location = info["court location"]:upper()
	local court_division = info["court division"]:upper()
	local court_district = info["court district"]:upper()

	local heading = ""
	if court_name == "HIGH COURT OF SOUTH AFRICA" then
		heading = string.format("IN THE %s \\\\ (%s, %s)", court_name, court_division, court_location)
	elseif court_name == "MAGISTRATE'S COURT" then
		heading = string.format(
			"IN THE %s FOR THE DISTRICT OF %s \\\\ HELD AT %s",
			court_name,
			court_district,
			court_district,
			court_location
		)
	else
		heading = string.format("IN THE %s", court_name)
	end

	case_info.case_no = info["case no"]
	case_info.court.heading = string.format("\\textbf{%s}", heading)
	case_info.reconvention = (info["reconvention"] == "Yes")
end

function print_case_no()
	if case_info.case_no ~= "" then
		tex.print(string.format("\\textbf{CASE NO: %s}", case_info.case_no))
	else
		tex.print("\\setstretch{1}\\begin{Form}\\textbf{CASE NO: \\fieldinline{}{2cm}}\\end{Form}")
	end
end

function print_row(col1, col2, bold)
	local first = bold and ("\\bfseries " .. col1) or col1
	tex.print(first .. " & " .. col2 .. " \\\\")
end

function format_parties(parties, role, reconvention)
	local count = #parties

	local ordinals = {
		[1] = "First",
		[2] = "Second",
		[3] = "Third",
		[4] = "Fourth",
		[5] = "Fifth",
		[6] = "Sixth",
		[7] = "Seventh",
		[8] = "Eighth",
		[9] = "Ninth",
		[10] = "Tenth",
	}

	for i, name in ipairs(parties) do
		if reconvention then
			print_row(name, string.format("(%s %s in Reconvention)", ordinals[i], role), true)
		else
			print_row(name, string.format("(%s %s)", ordinals[i], role), true)
		end

		if i < count then
			print_row("And", "")
		end
	end
end

function print_parties()
	format_parties(case_info.applicants, "Applicant", case_info.reconvention)
	print_row("And", "")
	format_parties(case_info.respondents, "Respondent", case_info.reconvention)
end

process_case_info("content/caseinfo.txt")
