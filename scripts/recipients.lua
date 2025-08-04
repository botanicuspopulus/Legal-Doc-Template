local function process_recipients(filepath)
	local file = io.open(filepath, "r")
	if not file then
		tex.error("Unable to open " .. filepath)
		return
	end

	local json = require("external/dkjson")
	local json_content, pos, err = json.decode(file:read("*all"))
	file:close()

	if err then
		tex.error("Error decoding JSON: " .. err)
		return
	end

	local output = {}
	local recipient_count = #json_content.recipients

	for i, recipient in ipairs(json_content.recipients) do
		table.insert(output, [[\noindent\begin{spacing}{1}]])

		if (i > 1) and (i <= recipient_count) then
			table.insert(output, [[\textbf{AND }]])
		end

		table.insert(
			output,
			string.format([[\textbf{TO:}\\\textbf{%s}\\\textbf{%s}\\]], recipient.name, recipient.role)
		)

		if recipient.address ~= nil then
			table.insert(output, string.format([[Address: %s\\]], recipient.address))
		end

		if recipient.email ~= nil then
			table.insert(output, string.format([[E-mail: %s\\]], recipient.email))
		end

		if recipient.cell ~= nil then
			table.insert(output, string.format([[Cell: %s\\]], recipient.cell))
		end

		if recipient.fax ~= nil then
			table.insert(output, string.format([[Fax: %s\\]], recipient.fax))
		end

		if recipient.phone ~= nil then
			table.insert(output, string.format([[Tel: %s\\]], recipient.phone))
		end

		table.insert(output, [[\end{spacing}]])
	end

	tex.print(table.concat(output, "\n"))
end

return process_recipients
