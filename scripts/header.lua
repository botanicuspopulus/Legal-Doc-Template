local M = {}

local case_info = {
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

function M.process_case_info(filepath)
	local file = io.open(filepath, "r")
	if not file then
		tex.error("Cannot open " .. filepath)
		return
	end

	local json = require("external/dkjson")
	local json_content = json.decode(file:read("*all"))
	file:close()

	case_info.case_no = json_content.case.number
	case_info.court.heading = json_content.court.heading
	case_info.reconvention = json_content.case.reconvention == "Yes"
	case_info.parties = json_content.parties
end

function M.print_case_no()
	local output
	if case_info.case_no ~= "" then
		output = string.format("\\textbf{CASE NO: %s}", case_info.case_no)
	else
		output = "\\setstretch{1}\\begin{Form}\\textbf{CASE NO: \\fieldinline{}{2cm}}\\end{Form}"
	end
	tex.print(output)
end

local function print_row(col1, col2, bold)
	local first = bold and ("\\bfseries " .. col1) or col1
	tex.print(first .. " & " .. col2 .. " \\\\")
end

local function format_parties(parties, reconvention)
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

	for i, party in ipairs(parties) do
		local ordinal = ordinals[i]
		local role = party.role
		local name = party.name
		local id = party.id

		local formatted_role
		if reconvention then
			formatted_role = string.format("(%s %s in Reconvention)", ordinal, role)
		else
			formatted_role = string.format("(%s %s)", ordinal, role)
		end

		print_row(string.format("%s\\\\(%s)", name, id), formatted_role, true)

		if i < count then
			print_row("And", "")
		end
	end
end

function M.print_court_heading()
	tex.print(string.format(
		[[
		\vspace{0.25cm}\hrule\vspace{0.25cm}
	  \begin{center}%s\end{center}
	  \vspace{0.25cm}\hrule\vspace{0.25cm}
	  ]],
		case_info.court.heading
	))
end

function M.print_parties()
	format_parties(case_info.parties, case_info.reconvention)
end

return M
