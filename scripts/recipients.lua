function process_recipients(filepath)
	local file = io.open(filepath, "r")
	if not file then
		tex.error("Unable to open " .. filepath)
		return
	end

	local i = 1
	local output = {}

	for line in file:lines() do
		line = line:gsub("^%s*(.-)%s*$", "%1")

		if i == 1 then
			table.insert(output, "\\textbf{TO:} \\\\")
			table.insert(output, string.format("\\textbf{%s} \\\\", line))
		elseif i == 2 then
			table.insert(output, string.format("\\textbf{%s} \\\\", line))
		elseif line ~= "" then
			table.insert(output, string.format("%s \\\\", line))
		else
			table.insert(output, "\\vspace{1cm} \\\\")
			table.insert(output, "\\textbf{AND }")
			i = 0
		end

		i = i + 1
	end

	file:close()

	tex.print(table.concat(output, "\n"))
end
