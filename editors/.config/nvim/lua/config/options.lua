--------------------------------------------------------------------------------
-- General Neovim settings and configuration
--------------------------------------------------------------------------------

-- Global Variables
local g = vim.g 

-- Set options
local o = vim.o

-- Set options (lua list/map-like)
local opt = vim.opt

--------------------------------------------------------------------------------
-- General 
--------------------------------------------------------------------------------

-- Use system clipboard as a buffer
o.clipboard = 'unnamedplus'

-- Highlight the current line
o.cursorline = true


o.cursorlineopt = "number"

-- Disable swap files
o.swapfile = false

o.completeopt = 'menuone,noinsert,noselect'

--------------------------------------------------------------------------------
-- Neovim UI 
--------------------------------------------------------------------------------

-- Display Line Numbers
o.number = true

-- Relative line numbers for easier navigation
o.relativenumber = true

-- Always show sign column
o.signcolumn = "yes"

-- Highlight matches
o.showmatch = true
o.splitright = true
o.splitbelow = true

-- Enable true-color support
o.termguicolors = true
o.laststatus = 3

--------------------------------------------------------------------------------
-- Tabs, Indent 
--------------------------------------------------------------------------------

o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.smartindent = true

--------------------------------------------------------------------------------
-- Memory, CPU 
--------------------------------------------------------------------------------

o.hidden = true
o.history = 100
o.lazyredraw = true
o.updatetime = 250
o.timeoutlen = 300

--------------------------------------------------------------------------------
-- Files
--------------------------------------------------------------------------------

o.backup = false
o.writebackup = false
o.undofile = true
o.undolevels = 10000
