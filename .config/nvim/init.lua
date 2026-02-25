if vim.fn.has("win32") == 1 then
    vim.cmd('set runtimepath^=~/vimFiles runtimepath+=~/vimFiles/after')
    vim.o.packpath = vim.o.runtimepath
    vim.cmd('source ~/_vimrc')
    vim.env.PYTHONIOENCODING = "utf-8"
    vim.env.PYTHONLEGACYWINDOWSSTDIO = "utf-8"
else
    vim.cmd('set runtimepath^=~/.vim runtimepath+=~/.vim/after')
    vim.o.packpath = vim.o.runtimepath
    vim.cmd('source ~/.vimrc')
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- add your plugins here
    { 'nvim-mini/mini.nvim', version = '*' },
    {
        "olimorris/codecompanion.nvim",
        opts = {},
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
    },
    {
        "github/copilot.vim",
    },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

llladapters = {
    copilot = {
      name = "copilot",
      model = "gpt-4.1",
      --model = "claude-sonnet-4",
    },
    -- for gemini, `setenv GEMINI_MODEL gemini-2.5-flash` to change model
    gemini_cli = "gemini_cli",
}
-- comment out to get the default, i.e. pro with fallback to flash (if I understand correctly)
-- otherwise, gemini-2.5-flash, gemini-2.5-pro, gemini-3-flash-preview etc
vim.env.GEMINI_MODEL = 'gemini-2.5-flash'
lllchatadapter = "gemini_cli"
lllotheradapter = "copilot"
llldefault_tools = {
    "cmd_runner",
    "create_file",
    "file_search",
    --"get_changed_files",
    --"grep_search", -- requires ripgrep to be installed
    "insert_edit_into_file",
    --"list_code_usages",
    "read_file",
    --"memory",
}
lllcommon_adapter_tools = {
    opts = {
        default_tools = llldefault_tools,
        auto_submit_errors = true,
        auto_submit_success = true,
    },
    ["cmd_runner"] = {
        opts = {
            requires_approval_before = true,
            auto_submit_errors = true,
            auto_submit_success = true,
        }
    }
}
require("codecompanion").setup({
  adapters = {
    acp = {
      gemini_cli = function()
        return require ("codecompanion.adapters").extend("gemini_cli", {
            defaults = {
                auth_method = "oauth-personal", -- also the default
                timeout = 120000, -- slow laptop needs a minute; default was 20s
            },
            env = {
                GEMINI_MODEL = vim.env.GEMINI_MODEL or "gemini-2.5-flash",
            },
        });
      end,
    },
  },
  rules = {
    opts = {
      chat = {
        enabled = true,
      },
    },
  },
  interactions = {
    chat = {
        adapter = llladapters[lllchatadapter],
        tools = lllcommon_adapter_tools,
    },
    inline = {
        adapter = llladapters[lllotheradapter],
        tools = lllcommon_adapter_tools,
    },
    agent = {
        adapter = llladapters[lllotheradapter],
        tools = lllcommon_adapter_tools,
    },
  },
  opts = {
    log_level = "DEBUG",
  },
})

require("mini.pick").setup()
