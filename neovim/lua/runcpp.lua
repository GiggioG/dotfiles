M = {
	started = false, 
	inputModified = true,
	sourceCodeModified = true
}

M.placeStaleMark = function()
	if not M.outputWin or not vim.api.nvim_win_is_valid(M.outputWin) then return end
	M.outputBuf = vim.api.nvim_win_get_buf(M.outputWin)
	if M.staleMark and #vim.api.nvim_buf_get_extmark_by_id(M.outputBuf, M.staleBannerNS, M.staleMark, {}) ~= 0 then return end
	M.staleMark = vim.api.nvim_buf_set_extmark(M.outputBuf, M.staleBannerNS, 0, 0, {
		virt_text = {
			{ "Output is stale", "WarningMsg"}
		},
		virt_text_pos = "right_align",
	})
end

M.ensureInputWin = function()
	if M.inputWin and vim.api.nvim_win_is_valid(M.inputWin) then return end
	M.inputWin = vim.api.nvim_open_win(0, true, {
		win = M.mainWin,
		split = "right",
		width = 40,
		style = "minimal"
	})
	vim.api.nvim_win_call(M.inputWin, function() vim.cmd.edit(M.inputFile) end)
	M.inputBuf = vim.api.nvim_win_get_buf(M.inputWin)
	vim.api.nvim_create_autocmd("BufModifiedSet", {
		buffer = M.inputBuf,
		group = vim.api.nvim_create_augroup("runcpp_inputbuf-modified", {clear = true}),
		callback = function ()
			if not vim.api.nvim_get_option_value("modified", { buf = M.inputBuf }) then return end
			M.inputModified = true
			M.placeStaleMark()
		end
	})
end

M.ensureOutputWin = function()
	if M.outputWin and vim.api.nvim_win_is_valid(M.outputWin) then return end
	M.ensureInputWin()
	M.outputWin = vim.api.nvim_open_win(0, false, {
		win = M.inputWin,
		split = "below",
		height = vim.api.nvim_win_get_height(M.inputWin) / 2,
		style = "minimal"
	})
end

M.start = function()
	local fileType = vim.api.nvim_get_option_value("filetype", {buf = vim.api.nvim_win_get_buf(vim.api.nvim_get_current_win())} )
	if fileType ~= "cpp" then
		print("Not a cpp file.")
		return
	end

	M.mainWin = vim.api.nvim_get_current_win()
	M.mainBuf = vim.api.nvim_win_get_buf(M.mainWin)
	M.staleBannerNS = vim.api.nvim_create_namespace("runcpp_stale-output-banner")
	vim.api.nvim_create_autocmd("BufModifiedSet", {
		buffer = M.mainBuf,
		group = vim.api.nvim_create_augroup("runcpp_sourceBuf-modified", {clear = true}),
		callback = function ()
			if not vim.api.nvim_get_option_value("modified", { buf = M.sourceBuf }) then return end
			M.sourceCodeModified = true
			M.placeStaleMark()
		end
	})

	local sourceFile = vim.api.nvim_buf_get_name(M.mainBuf)
	local withoutExtension = sourceFile:match("^(.+)%.(.+)$")
	M.sourceFile = sourceFile
	M.binaryFile = withoutExtension
	M.inputFile = withoutExtension .. ".in"
	M.outputFile = withoutExtension .. ".out"

	vim.api.nvim_create_autocmd("WinClosed", {
		group = vim.api.nvim_create_augroup("runcpp_mainwin-closed", {clear = true}),
		pattern = { tostring(M.mainWin) },
		callback = function ()
			vim.cmd("wqa")
		end
	})
	M.ensureInputWin()
	M.started = true
end

M.openOutput = function()
	M.ensureOutputWin()
	vim.api.nvim_win_call(M.outputWin, function() vim.cmd.edit(M.outputFile) end)
	M.outputBuf = vim.api.nvim_win_get_buf(M.outputWin)
	vim.api.nvim_win_call(M.outputWin, function() vim.cmd("set readonly") end)
	vim.api.nvim_set_current_win(M.mainWin)
end

M.runFile = function()
	if not M.started then 
		print("Start runcpp first.")
		return
	end
	M.ensureInputWin()

	if M.sourceCodeModified then
		vim.api.nvim_win_call(M.mainWin, function() vim.cmd("write") end)
		local compiledOk = os.execute("g++ \"" .. M.sourceFile .. "\" -DGIGO_DEBUG -o \"" .. M.binaryFile .. "\" >\"" .. M.outputFile .. "\" 2>&1")
		if compiledOk ~= 0 then
			M.inputModified = false
			vim.cmd("cgetfile " .. M.outputFile)
			M.openOutput()
			vim.api.nvim_buf_clear_namespace(M.outputBuf, M.staleBannerNS, 0, -1)
			return
		end
	end
	if (M.sourceCodeModified or M.inputModified) then
		vim.api.nvim_win_call(M.inputWin, function() vim.cmd("write") end)
		os.execute("\"" .. M.binaryFile .. "\" <\"" .. M.inputFile .. "\" >\"" .. M.outputFile .. "\" 2>&1")

		M.inputModified = false
		M.sourceCodeModified = false

		M.openOutput()
		vim.api.nvim_buf_clear_namespace(M.outputBuf, M.staleBannerNS, 0, -1)
	end
end

vim.keymap.set("n", "<leader>io", M.start)
vim.keymap.set("n", "<leader>ir", M.runFile)
