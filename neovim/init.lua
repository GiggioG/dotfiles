--[[
Inspired by:

1. The vimrc in this repo
2. Sylvan Franklin's minimalist neovim configuration
3. kickstart.nvim

--]]

vim.o.tabstop = 4
vim.o.shiftwidth = 0
vim.o.cursorline = true

vim.o.number = true
vim.o.relativenumber = true
vim.o.wildmenu = true
vim.o.showmatch = true

vim.o.incsearch = true
vim.o.hlsearch = true
vim.o.signcolumn = "yes"

vim.g.mapleader = " "
vim.keymap.set('n', "<leader><space>", ":nohlsearch<CR>")

vim.o.completeopt = "menu,popup,fuzzy,menuone,longest,preview"
vim.o.splitright = true
vim.o.splitbelow = true

vim.keymap.set('n', "<leader>sc", ":update<CR>:source<CR>")

vim.o.textwidth = 120
vim.o.ignorecase = true
vim.o.smartcase = true
vim.cmd("colorscheme unokai")

vim.opt.winborder = "rounded"

require "runcpp"
require "comp_infos"

vim.keymap.set('i', "„", "<")
vim.keymap.set('i', "“", ">")
vim.keymap.set('i', "№", "#")
vim.keymap.set('i', "€", "^")
vim.keymap.set('i', "§", "&")

vim.keymap.set('n', "<leader>bf", vim.lsp.buf.format)

-- package stuff

if (vim.pack ~= nil) then
	vim.pack.add({
		{ src = "https://github.com/neovim/nvim-lspconfig" },
		{ src = "https://github.com/mason-org/mason.nvim" },
		{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
		{ src = "https://github.com/vyfor/cord.nvim" },
	})
	vim.lsp.enable({ "lua_ls", "rust_analyzer", "clangd", "eslint-lsp", "arduino-ls", "ast-grep" })

	vim.lsp.config("lua_ls", {
		settings = {
			Lua = {
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true),
				}
			}
		}
	})

	vim.api.nvim_create_autocmd('PackChanged', {
	  callback = function(opts)
		if opts.data.spec.name == 'cord.nvim' and opts.data.kind == 'update' then 
		  vim.cmd 'Cord update'
		end
	  end
	})

	require "mason".setup()
	require "nvim-treesitter.configs".setup({
		highlight = { enable = true }
	})
end
