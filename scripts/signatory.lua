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

	local file_content = f:read("*all")
	f:close()

	local blocks = {}
	for segment in (file_content .. "\n\n"):gmatch("(.-)\n%s*\n") do
		table.insert(blocks, segment)
	end

	local all = {}
	for _, block in ipairs(blocks) do
		local lines, index, city = {}, 1, nil
		for line in block:gmatch("[^\n]+") do
			line = line:match("^%s*(.-)%s*$") -- trim

			if index == 1 then
				table.insert(lines, "\\textbf{" .. line .. "}")
			elseif index == 2 then
				table.insert(lines, "\\textit{" .. line .. "}")
			elseif line:match("^City:") then
				city = line:match("^City:%s*(.+)$")
			else
				table.insert(lines, line)
			end

			index = index + 1
		end

		table.insert(all, { content = table.concat(non_blank_lines(lines), " \\\\"), city = city or "" })
	end

	return all
end

local function format_signatory(s)
	return string.format(
		[[\begin{flushright}
		    \begin{spacing}{1}
		      \rule{0.4\textwidth}{0.5pt}\\[0.5em]
		        %s
		    \end{spacing}
		  \end{flushright}]],
		s.content
	)
end

local function print_signatories()
	local all_signatories = process_signatories("content/signatory.txt")

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

	for i = 1, #all_signatories do
		tex.print(format_signatory(all_signatories[i]))
	end
end

return print_signatories
