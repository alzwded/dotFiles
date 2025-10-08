if vim.fn.has("win32") == 1 then
    vim.cmd('set runtimepath^=~/vimFiles runtimepath+=~/vimFiles/after')
    vim.o.packpath = vim.o.runtimepath
    vim.cmd('source ~/_vimrc')
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

strategies = {
    chat = {
      tools = {
        opts = {
          default_tools = {
            "my_tool",
            "my_tool_group"
          }
        },
      }
    }
  }

--lllmodel = "claude-sonnet-4"
lllmodel = "gpt-4.1"
require("codecompanion").setup({
  memory = {
    opts = {
      chat = {
        enabled = true,
      },
    },
  },
  strategies = {
    chat = {
      adapter = {
        name = "copilot",
        model = lllmodel,
      },
      tools = {
          opts = {
              default_tools = {
                "cmd_runner",
                "create_file",
                "file_search",
                "get_changed_files",
                --"grep_search", -- requires ripgrep to be installed
                "insert_edit_into_file",
                "list_code_usages",
                "read_file",
              }
          },
          ["cmd_runner"] = {
              opts = {
                  requires_approval = true,
                  auto_submit_errors = true,
                  auto_submit_success = true,
              }
          }
      },
    },
    inline = {
      adapter = {
        name = "copilot",
        model = lllmodel,
      },
      tools = {
          ["cmd_runner"] = {
              opts = {
                  requires_approval = true,
                  auto_submit_errors = true,
                  auto_submit_success = true,
              }
          }
      },
    },
    agent = {
      adapter = {
        name = "copilot",
        model = lllmodel,
      },
      tools = {
          ["cmd_runner"] = {
              opts = {
                  requires_approval = true,
                  auto_submit_errors = true,
                  auto_submit_success = true,
              }
          }
      },
    }
  },
  opts = {
    log_level = "DEBUG",
  },
})

require("mini.pick").setup()

