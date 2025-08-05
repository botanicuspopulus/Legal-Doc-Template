local function non_blank_lines(t)
	local out = {}
	for _, line in ipairs(t) do
		if line ~= "" then
			table.insert(out, line)
		end
	end

	return out
end

local function process_signatories(fp)
	local f = io.open(fp, "r")
	if not f then
		tex.error("cannot open")
		return
	end

	local json = require("external/dkjson")
	local file_content = f:read("*all")
	f:close()
	local json_content, pos, err = json.decode(file_content)
	if err then
		tex.error("Error decoding JSON: " .. err)
		return
	end

	return json_content.signatories
end

local function format_signatory(s)
	local output = {}

	table.insert(output, [[\begin{flushright}\begin{spacing}{1}]])
	table.insert(output, [[\rule{0.4\textwidth}{0.5pt}\\[0.5em]\\]])
	table.insert(output, string.format([[\textbf{%s}\\\textbf{%s}\\]], s.name, s.role))

	if s.address ~= nil then
		table.insert(output, string.format([[%s\\]], s.address))
	end

	if s.email ~= nil then
		table.insert(output, string.format([[E-mail: %s\\]], s.email))
	end

	if s.cell ~= nil then
		table.insert(output, string.format([[Cell: %s\\]], s.cell))
	end

	if s.phone ~= nil then
		table.insert(output, string.format([[Tel: %s\\]], s.phone))
	end

	if s.fax ~= nil then
		table.insert(output, string.format([[Fax: %s\\]], s.fax))
	end
	table.insert(output, [[\end{spacing}\end{flushright}]])

	return table.concat(output)
end

local function print_signatories(fp)
	local all_signatories = process_signatories(fp)

	if all_signatories == nil then
		return
	end

	local city = ""
	for _, signatory in ipairs(all_signatories) do
		if signatory.city ~= "" then
			city = signatory.city
			break
		end
	end

	local signed_at
	if city == "" then
		signed_at = [[\underline{\hspace{5cm}}]]
	else
		signed_at = string.format([[\textbf{\MakeUppercase{%s}}]], city)
	end

	tex.print(string.format([[Signed at %s on this day, \today.\\]], signed_at))

	for _, signatory in ipairs(all_signatories) do
		tex.print(format_signatory(signatory))
	end
end

return print_signatories
