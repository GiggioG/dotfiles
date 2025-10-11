require "lfs"

local M = {
	zapiskiCppBuf = nil,
	startStr = [[
#include <bits/stdc++.h>
using namespace std;

#ifndef GIGO_DEBUG
#define cerr if(false) cerr
#endif

int main(){
//    ios_base::sync_with_stdio(false);
//    cin.tie(nullptr);
//    cout.tie(nullptr);



    return 0;
}
]]
}

-- from https://gist.github.com/kgriffs/124aae3ac80eefe57199451b823c24ec
M.string_contains = function(str, sub)
    return str:find(sub, 1, true) ~= nil
end
M.string_startswith = function(str, start)
    return str:sub(1, #start) == start
end
M.string_endswith = function(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end
-- from https://stackoverflow.com/questions/10460126/how-to-remove-spaces-from-a-string-in-lua
M.string_trim = function(str)
   return str:match( "^%s*(.-)%s*$" )
end

M.exists = function(file) -- from https://stackoverflow.com/questions/1340230/check-if-directory-exists-in-lua
	local ok, err, code = os.rename(file, file)
	if not ok then
		if code == 13 then
			 -- Permission denied, but it exists
			return true
		end
	end
	return ok, err
end

M.makeDir = function()
	if not vim.api.nvim_get_option_value("filetype", {}) == "netrw" then return end
	local path = vim.fn.expand("%:p:h")
	if not M.string_contains(path, "comp_infos/") then return end

	local filename = os.date("shkola_%Y-%m-%d")
	if M.string_endswith(path, "reshavamSiZadachi") then
		filename = "newFolder_" .. tostring(math.random()):sub(3)
	end

	local fullPath = path .. "/" .. filename
	local fileExists = M.exists(fullPath)

	if fileExists then return end

	lfs.mkdir(fullPath)
	vim.api.nvim_set_current_dir(fullPath)
	vim.cmd.edit(fullPath)
end

M.extractMarkdown = function()
	if not M.string_contains(vim.fn.expand("%:p"), "comp_infos/") then return end
	if not M.string_endswith(vim.fn.expand("%:p"), "_zapiski.md") then return end
	local fileLocation = vim.fn.expand("%:p:h")

	if M.zapiskiCppBuf == nil then
		M.zapiskiCppBuf = vim.api.nvim_create_buf(false, true)
	end

	vim.api.nvim_buf_set_lines(M.zapiskiCppBuf, 0, -1, false, { "#include \"glib.h\"", "" })

	local addLine = false
	lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	for i, line in ipairs(lines) do
		local trimmed = M.string_trim(line)
		if addLine and trimmed == "```" then
			vim.api.nvim_buf_set_lines(M.zapiskiCppBuf, -1, -1, false, { "" })
			addLine = false
		end
		if addLine then
			vim.api.nvim_buf_set_lines(M.zapiskiCppBuf, -1, -1, false, { line })
		end
		if trimmed == "```cpp" then
			addLine = true
		end
	end

	vim.api.nvim_buf_call(M.zapiskiCppBuf, function() vim.cmd.write({ fileLocation .. "/_zapiski.cpp", bang=true }) end)
end

-- M.beginProb = function()
-- 	local cwd = vim.fn.getcwd()
-- 	if not M.string_contains(cwd, "comp_infos/") then return end
-- 	local link = vim.fn.input("Link: ")
-- 	print("\n")
--
-- 	local _, dirEnd = cwd:find("comp_infos/")
-- 	local scriptPath = cwd:sub(1, dirEnd) .. "_beginProb.js"
--
-- 	local cmdObj = vim.system({"node", scriptPath, link}, {text=true}):wait()
--
-- 	if cmdObj.code ~= 0 then
-- 		print(cmdObj.stderr)
-- 		return
-- 	end
--
-- 	vim.cmd.edit(cmdObj.stdout:sub(1, -2))
-- end

M.curl = function(url)
	local reqObj = vim.system({ "curl", "-i", url }, { text = true }):wait()
	local output = reqObj.stdout

	local httpVersion = nil
	local statusCode = nil
	local statusMessage = nil
	local headers = {}
	local body = ""

	local state = "PROTOCOL"; -- or HEADERS or BODY
	function processLine(line)
		if state == "PROTOCOL" then
			local ver, cod, msg = line:match("HTTP/([%d.]+) (%d+) (.*)")
			httpVersion = tonumber(ver)
			statusCode = tonumber(cod)
			statusMessage = msg
			state = "HEADERS"
		elseif state == "HEADERS" then
			if line == "" then
				state = "BODY"
			else
				local key, value = line:match("([%w-]+: ?(.*))")
				headers[key] = value
end
		else
			if #body > 0 then body = "\n" .. body end
			body = body .. line
		end
	end

	for line in output:gmatch("(.-)\n") do
		processLine(line)
	end
	local _, lastLineMatch = output:match("(.*)\n(.*)$")
	if lastLineMatch and #lastLineMatch > 0 then
		processLine(lastLineMatch)
	end

	return {
		httpVersion = httpVersion,
		statusCode = statusCode,
		statusMessage = statusMessage,
		headers = headers,
		body = body
	}
end

M.parseArenaProblemLink = function(link)
	local INFOSBG_REGEX = "^https?://arena%.infosbg%.com/#/catalog/(%d+)/problem/(%d+)/?$";
	local OLIMPIICI_REGEX = "^https?://arena%.olimpiici%.com/#/catalog/(%d+)/problem/(%d+)/?$";

	local compId, probId = link:match(INFOSBG_REGEX)
	if compId == nil then
		compId, probId = link:match(OLIMPIICI_REGEX)
	end
	
	if compId == nil then return nil end
	return {
		compId = compId,
		probId = probId
	}
end

M.jq = function(json, query)
	return vim.system({ "jq", "-c", query }, { text = true, stdin = json }):wait().stdout
end

M.shlyokavica = function(text)
	function cod(chr) return chr:byte(1)*256+chr:byte(2) end

	local shlyok = {"a", "b", "v", "g", "d", "e", "j", "z", "i", "j", "k", "l", "m", "n", "o", "p", "r", "s", "t", "u", "f", "h", "c", "ch", "sh", "sht", "u", "y", "yu", "q"}
	local smallCyr = "абвгдежзийклмнопрстуфхцчшщъьюя"
	local capCyr = "АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЬЮЯ"

	result = ""
	local i = 1
	while i <= #text do
		local c = text:sub(i, i)
		local b = c:byte()
		if b > 127 then -- apparently lua doesn't support unicode...
			c = text:sub(i, i+1)
			b = cod(c)
			i = i+1
		end

		local resChar = nil
		for j=1,#smallCyr,2 do
			if smallCyr:sub(j,j+1) == c then
				resChar = shlyok[(j-1)/2 + 1]
				break
			end
		end
		if resChar == nil then
			for j=1,#capCyr,2 do
				if capCyr:sub(j,j+1) == c then
					resChar = shlyok[(j-1)/2 + 1]:upper()
					break
				end
			end
		end

		if resChar ~= nil then
			result = result .. resChar
		elseif c == ' ' or c == '.' then
			result = result .. '-'
		else
			result = result .. c
		end

		i=i+1
	end

	return result
end

M.getArenaProblemPathName = function(id, label)
	local PATH_NAMES = {
		[489] = "NOI1",
		[495] = "NOI2",
		[501] = "NOI3",
		[572] = "IATI",
		[507] = "ET",
		[513] = "ZT",
		[519] = "PT",
		[525] = "LT",
		[415] = "KMMO",
		[565] = "KSO",
		[384] = "SfOpen-Aut",
		[635] = "SfOpen-Spr",
		[439] = "MladenManev",
		[469] = "EJOI",
		[609] = "IOI",
		[613] = "EGOI",
		[645] = "RMI",
		[676] = "CodeIT",
		[447] = "Studentska",
		[480] = "Singapore",

		[579] = "Senior",
		[573] = "Junior"
	}

	-- if PATH_NAMES[id] ~= nil then
	-- 	return PATH_NAMES[id]
	-- end
	if label == "Тренировъчно състезание" then
		return "Tren"
	end
	local kontrolno = label:match("^Контролно (%d+)$")
	if kontrolno then
		return "K" .. kontrolno
	end
	return M.shlyokavica(label)
end

function M.getArenaProblemInfo(link)
	local linkInfo = M.parseArenaProblemLink(link)

	local prob_req = M.curl("https://arena.infosbg.com/api/competitions/" ..
	linkInfo.compId .. "/problem/" .. linkInfo.probId).body
	local path_req = M.curl("https://arena.infosbg.com/api/competitions/" .. linkInfo.compId .. "/path").body

	local path = M.jq(path_req, "[ .[] | select(.id != 1 and .id != 479) ]") -- Zadachi i Drugi
	local compId = tonumber(M.jq(path, ".[0].id"))
	local compYear = tonumber(M.jq(prob_req, ".year"))
	local title = M.jq(prob_req, ".title"):sub(2, -3)
	path = M.jq(path, "[ .[] | select(.label != \"" .. tostring(compYear) .. "\")]")

	local pathSimple = M.jq(path, ".[] | [.id, .label]")
	local pathNames = {}
	for pathEntry in pathSimple:gmatch("(%[.-%])\n") do
		local id, label = pathEntry:match("%[(%d+),\"(.+)\"%]")
		id = tonumber(id)
		table.insert(pathNames, M.getArenaProblemPathName(id, label))
	end
	table.insert(pathNames, 2, tostring(compYear))

	local doc = {
		{"name", title},
		{"link", link},
		{"from", table.concat(pathNames, " / ")}
	}
	table.insert(pathNames, title)
	return {
		fileName = table.concat(pathNames, '_'),
		probName = title,
		doc = doc
	}
end

M.genDocString = function(doc)
	local s = "/**\n"
	for _, e in ipairs(doc) do
		s = s .. string.format(" * @%s %s\n", e[1], e[2])
	end
	s = s .. " * @solutionBy Gigo_G\n */\n"
	return s
end


M.beginProb = function(call)
	if not vim.api.nvim_get_option_value("filetype", {}) == "netrw" then return end
	local path = vim.fn.expand("%:p:h")
	if not M.string_contains(path, "comp_infos/") then return end

	local link = nil
	if not call or not call.args.link then
		link = vim.fn.input("Link: ")
	else
		link = call.args.link
	end

	if M.parseArenaProblemLink(link) == nil then return end

	local info = M.getArenaProblemInfo(link)
	local fileContents = M.genDocString(info.doc) .. M.startStr
	
	local probBuf = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_set_lines(probBuf, 0, -1, false, {"EMPTY_LINE"})
	for line in fileContents:gmatch("(.-)\n") do
		vim.api.nvim_buf_set_lines(probBuf, -1, -1, false, {line})
	end
	vim.api.nvim_buf_set_lines(probBuf, 0, 1, false, {})

	vim.api.nvim_set_current_dir(path)
	vim.api.nvim_buf_call(probBuf, function() vim.cmd.write({ info.fileName .. ".cpp" }) end)
	vim.cmd.edit(info.fileName .. ".cpp")
	vim.cmd("18")
end

vim.api.nvim_create_autocmd("BufWritePost", {
	group = vim.api.nvim_create_augroup("comp-infos_zapiski_updated", {clear = true}),
	pattern = "_zapiski.md",
	callback = M.extractMarkdown
})


vim.api.nvim_create_user_command("MakeDir", M.makeDir, {})
vim.api.nvim_create_user_command("ExtractMarkdown", M.extractMarkdown, {})
vim.api.nvim_create_user_command("BeginProb", M.beginProb, {})

vim.keymap.set("n", "<leader>cid", M.makeDir)
vim.keymap.set("n", "<leader>cem", M.extractMarkdown)
vim.keymap.set("n", "<leader>cbp", M.beginProb)
