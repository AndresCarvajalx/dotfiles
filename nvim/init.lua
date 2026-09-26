vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.termguicolors = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.signcolumn = 'yes'
vim.g.mapleader = ' '

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Error al clonar lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPresiona cualquier tecla para salir..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "blazkowolf/gruber-darker.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("gruber-darker")
    end,
  },

  -- Servidores LSP y Mason
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "neovim/nvim-lspconfig" },

  -- Autocompletado
  {
    'saghen/blink.cmp',
    dependencies = 'rafamadriz/friendly-snippets',
    version = '*', 
    opts = {
      keymap = { 
        preset = 'default',
        ['<CR>'] = { 'accept', 'fallback' },
        ['<Tab>'] = { 'select_next', 'fallback' },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono'
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
    },
    opts_extend = { "sources.default" }
  },

  -- Autocerrado de paréntesis, llaves y comillas
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true,
      })
    end
  },

  -- Salir de parentesis y etc
  {
    'abecodes/tabout.nvim',
    event = 'InsertEnter',
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "windwp/nvim-autopairs"
    },
    config = function()
      require('tabout').setup({
        tabkey = '<Tab>',
        backtabkey = '<S-Tab>',
        act_as_tab = true,
        act_as_shift_tab = true,
        default_tab = '<C-t>', 
        default_shift_tab = '<C-d>',
        enable_backwards = true,
        completion = false,
        tabouts = {
          { open = "'", close = "'" },
          { open = '"', close = '"' },
          { open = '`', close = '`' },
          { open = '(', close = ')' },
          { open = '[', close = ']' },
          { open = '{', close = '}' }
        },
        ignore_beginning = '',
        exclude = {}
      })
    end,
  },

  -- Gitsigns para estados de Git
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = '┃' },
          change       = { text = '┃' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        current_line_blame = true,
        current_line_blame_opts = { delay = 500 },
      })
    end
  },

  -- Comentar rapido
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("Comment").setup()
    end
  },

  -- Terminal integrada flotante
  {
    "akinsho/toggleterm.nvim",
    version = '*',
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<C-\>]], -- Control + Barra invertida abre/cierra la terminal general
        hide_numbers = true,
        shade_terminals = true,
        direction = 'float',
        close_on_exit = true,
        shell = vim.o.shell,
        float_opts = {
          border = 'curved',
          winblend = 3,
        },
      })
    end
  },

  -- Menu de ayuda visual de atajos
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      preset = "modern",
    },
  },

  -- Barra de estado
  { "nvim-lualine/lualine.nvim", dependencies = { 'nvim-tree/nvim-web-devicons' } },
  
  -- Buscador Difuso
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },

  -- Barra lateral
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        filesystem = {
          filtered_items = {
            visible = false, 
            hide_dotfiles = false,
            hide_gitignored = false,
          },
          follow_current_file = { enabled = true },
        },
        window = {
          width = 32,
          mappings = { ["<space>"] = "none" }
        }
      })
    end
  },

  -- Resaltado de sintaxis
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-treesitter.install").prefer_git = true
      require("nvim-treesitter").setup({
        ensure_installed = { "lua", "vim", "vimdoc", "python", "html", "css", "c", "cpp" },
        highlight = {
          enable = true, 
          additional_vim_regex_highlighting = false,
        },
      })
    end,
   },
})

-- Configuraciones externas de plugins
require('lualine').setup({ options = { theme = 'auto' } })
require("mason").setup()

local lspconfig = require('lspconfig')
local capabilities = require('blink.cmp').get_lsp_capabilities()

require("mason-lspconfig").setup({
  ensure_installed = { "pyright", "html", "cssls", "clangd" },
  handlers = {
    function(server_name)
      lspconfig[server_name].setup({
        capabilities = capabilities,
      })
    end,
  }
})


vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = "Moverse a la ventana izquierda" })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = "Moverse a la ventana de abajo" })
vim.keymap.set('n', '<C-w>k', '<C-w>k', { desc = "Moverse a la ventana de arriba" })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = "Moverse a la ventana derecha" })

vim.keymap.set('n', '<leader>h', '<cmd>nohlsearch<CR>', { desc = "Quitar resaltado" })

-- LSP
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Ir a definición" })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "Ver documentación" })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = "Renombrar variable" })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = "Acciones de código" })

-- Buscador y Barra Lateral
vim.keymap.set('n', '<leader>f', ':Telescope find_files<CR>', { desc = "Buscar archivos" })
vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle left<CR>', { desc = "Alternar barra lateral Neo-tree" })

-- Git
vim.keymap.set('n', '<leader>gp', '<cmd>Gitsigns preview_hunk<CR>', { desc = "Previsualizar cambios Git" })
vim.keymap.set('n', '<leader>gb', '<cmd>Gitsigns toggle_current_line_blame<CR>', { desc = "Alternar autoría de línea" })
vim.keymap.set('n', ']c', '<cmd>Gitsigns next_hunk<CR>', { desc = "Siguiente cambio Git" })
vim.keymap.set('n', '[c', '<cmd>Gitsigns prev_hunk<CR>', { desc = "Anterior cambio Git" })

-- ToggleTerm
vim.keymap.set('n', '<leader>t', '<cmd>ToggleTerm direction=float<CR>', { desc = "Abrir terminal flotante" })

function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], opts)
end
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
