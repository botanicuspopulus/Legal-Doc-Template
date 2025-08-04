local function process_content(filepath)
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
	local current_level = 0

	local function add_output(content)
		table.insert(output, content)
	end

	local function begin_enum(level)
		if level > 1 then
			add_output("\\begin{enumerate}[start=1]")
		else
			add_output("\\begin{enumerate}")
		end
	end

	local function end_enum()
		add_output("\\end{enumerate}")
	end

	local function par(content)
		add_output("\\par " .. content)
	end

	local function item(content)
		add_output("\\item " .. content)
	end

	local function section(level, content)
		if level == 1 then
			add_output("\\section{" .. content .. "}")
		elseif level == 2 then
			add_output("\\subsection{" .. content .. "}")
		elseif level == 3 then
			add_output("\\subsubsection{" .. content .. "}")
		end
	end

	local function parse_line(line)
		line = line:gsub("%*%*(.-)%*%*", "\\textbf{%1}")
		line = line:gsub("%*(.-)%*", "\\textit{%1}")
		line = line:gsub("&", "\\&")

		local hashes, heading = line:match("^(#+)%s+(.*)")
		if hashes then
			return "heading", #hashes, heading
		end

		local l1, rest1 = line:match("^(%d+%.)%s+(.*)")
		if l1 then
			return "enumerate", 1, rest1
		end

		local l2, rest2 = line:match("^(%([a-z]%))%s+(.*)")
		if l2 then
			return "enumerate", 2, rest2
		end

		local l3, rest3 = line:match("^(%(%d+%))%s+(.*)")
		if l3 then
			return "enumerate", 3, rest3
		end

		return "paragraph", 0, line
	end

	for _, line in ipairs(json_content.content) do
		line = line:match("^%s*(.-)%s*$")

		if line ~= "" then
			local line_type, level, line_content = parse_line(line)

			if line_type == "heading" then
				for _ = current_level, 1, -1 do
					end_enum()
				end
				current_level = 0

				section(level, line_content)
			elseif line_type == "paragraph" then
				for _ = current_level, 1, -1 do
					end_enum()
				end
				current_level = 0

				par(line_content)
			elseif line_type == "enumerate" then
				if level > current_level then
					for _ = current_level + 1, level do
						begin_enum(level)
					end
				elseif level < current_level then
					for _ = current_level, level + 1, -1 do
						end_enum()
					end
				end

				current_level = level
				item(line_content)
			else
				for _ = current_level, 1, -1 do
					end_enum()
				end
				current_level = 0

				par(line_content)
			end
		end
	end

	for _ = current_level, 1, -1 do
		end_enum()
	end

	for _, line in ipairs(output) do
		tex.print(line)
	end
end

return process_content
