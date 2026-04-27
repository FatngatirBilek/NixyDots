{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nvf.homeManagerModules.default
  ];
  programs.nvf = {
    enable = true;
    # your settings need to go into the settings attribute set
    # most settings are documented in the appendix
    settings = {
      vim = {
        viAlias = false;
        vimAlias = false;

        extraPlugins = {
          codesnap = {
            # codesnap-nvim 2.0.1 upstream bugs fixed via postPatch:
            #
            # 1. CodeSnapSave broken: save_path variable scoping and wrong API calls
            #    in the upstream save() function — patched to use the correct
            #    generator.save(path, config) signature.
            #
            # 2. CodeSnap (copy to clipboard) broken: generator.copy() uses the
            #    `arboard` Rust library which spawns a background thread to serve
            #    Wayland clipboard requests. That thread is killed when the Lua call
            #    returns, so the clipboard is never actually populated.
            #    Fix: save to a temp PNG then pipe it to wl-copy, which is a proper
            #    long-running clipboard server that keeps serving until ownership
            #    is transferred.
            package = let
              # The patched init.lua — rewrite copy_highlight and save_highlight in full.
              # Upstream bugs:
              # 1. copy_highlight calls get_config() a second time inside the modal callback,
              #    but by then visual marks '</'> are gone → "No code is selected" error.
              # 2. save_highlight is a no-op stub.
              # 3. generator.copy() uses arboard which dies on Wayland; use wl-copy instead.
              patchedInitLua = pkgs.writeText "codesnap-init.lua" ''
                local static = require("codesnap.static")
                local table_utils = require("codesnap.utils.table")
                local module = require("codesnap.module")
                local config_module = require("codesnap.config")
                local modal = require("codesnap.modal")
                local path = require("codesnap.path")

                local generator = module.load_generator()

                local main = {
                  cwd = static.cwd,
                  highlight_mode_config = nil,
                }

                function main.setup(config)
                  static.config = table_utils.merge_config(static.config, config == nil and {} or config)
                  if static.config.snapshot_config then
                    path.expand_paths_in_config(static.config.snapshot_config)
                  end
                end

                function main.save(save_path)
                  if save_path == nil then
                    error("Save path is not specified", 0)
                  end
                  local matched_extension = string.match(save_path, "%.(.+)$")
                  if matched_extension ~= "png" and matched_extension ~= nil then
                    error("The extension of save_path should be .png", 0)
                  end
                  generator.save(save_path, config_module.get_config())
                  vim.cmd("delmarks <>")
                  vim.notify("Save snapshot in " .. save_path .. " successfully")
                end

                function main.copy()
                  local cfg = config_module.get_config()
                  local _tmp = os.tmpname() .. ".png"
                  generator.save(_tmp, cfg)
                  os.execute("${pkgs.wl-clipboard}/bin/wl-copy -t image/png < " .. _tmp)
                  os.remove(_tmp)
                  vim.cmd("delmarks <>")
                  vim.notify("The snapshot is copied into clipboard successfully!")
                end

                function main.copy_ascii()
                  generator.copy_ascii(config_module.get_config())
                  vim.cmd("delmarks <>")
                  vim.notify("The ASCII code snapshot is copied into clipboard successfully!")
                end

                local function highlight_copy_or_save(cb)
                  local original_config = config_module.get_config()
                  if not original_config or not original_config.content or not original_config.content.content then
                    vim.notify("No code is selected", vim.log.levels.ERROR)
                    return
                  end
                  local selected_text = original_config.content.content
                  local filetype = vim.bo.filetype
                  modal.pop_modal(selected_text, filetype, function(selection)
                    if not selection then
                      vim.notify("Selection cancelled", vim.log.levels.INFO)
                      return
                    end
                    local lines = vim.split(selected_text, "\n", { plain = true })
                    local start_line, end_line = selection[1], selection[2]
                    if start_line < 1 or end_line > #lines or start_line > end_line then
                      vim.notify("Invalid selection range", vim.log.levels.ERROR)
                      return
                    end
                    original_config.content.highlight_lines = {
                      { start_line, end_line, static.config.highlight_color },
                    }
                    cb(original_config)
                  end)
                end

                function main.copy_highlight()
                  highlight_copy_or_save(function(cfg)
                    local _tmp = os.tmpname() .. ".png"
                    generator.save(_tmp, cfg)
                    os.execute("${pkgs.wl-clipboard}/bin/wl-copy -t image/png < " .. _tmp)
                    os.remove(_tmp)
                    vim.cmd("delmarks <>")
                    vim.notify("The snapshot is copied into clipboard successfully!")
                  end)
                end

                function main.save_highlight(save_path)
                  highlight_copy_or_save(function(cfg)
                    local sp = save_path or static.config.save_path
                    generator.save(sp, cfg)
                    vim.cmd("delmarks <>")
                    vim.notify("Save snapshot in " .. sp .. " successfully")
                  end)
                end

                return main
              '';
            in pkgs.vimPlugins.codesnap-nvim.overrideAttrs (old: {
              postPatch = ''
                ${old.postPatch or ""}
                cp ${patchedInitLua} lua/codesnap/init.lua
              '';
            });
            setup = "require('codesnap').setup({ save_path = '~/Pictures/codesnap.png' })";
          };
        };

        maps = {
          normal = {
            "<Space>ee" = {
              action = ":NvimTreeToggle<CR>";
              silent = true;
              desc = "Toggle file tree";
            };
            "<Space>/" = {
              action = "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>";
              silent = true;
              desc = "Toggle comment line";
            };
          };
          visual = {
            "<Space>/" = {
              action = "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>";
              silent = true;
              desc = "Toggle comment selection";
            };
          };
        };

        debugger = {
          nvim-dap = {
            enable = true;
            ui.enable = true;
          };
        };
        # startPlugins = [
        #   pkgs.vimPlugins.alpha-nvim
        #   pkgs.vimPlugins.plenary-nvim
        # ];

        lsp = {
          enable = true;
          presets.tailwindcss-language-server.enable = true;
          formatOnSave = true;
          lspkind.enable = false;
          lightbulb.enable = true;
          lspsaga.enable = false;
          trouble.enable = true;
          otter-nvim.enable = true;
          nvim-docs-view.enable = true;

          servers = {
            nixd = {
              enable = true;
              settings = {
                diagnostic = {
                  suppress = ["sema-extra-with"];
                };
              };
            };

            rust_analyzer = {
              enable = true;
              settings = {
                rust-analyzer = {
                  inlayHints = {
                    closureReturnTypeHints = {
                      enable = "always";
                    };
                    lifetimeElisionHints = {
                      enable = "skip_trivial";
                      useParameterNames = true;
                    };
                  };
                };
              };
            };
          };
        };
        languages = {
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;

          nix = {
            enable = true;
            lsp.servers = ["nixd"];
            format = {
              enable = true;
              type = ["alejandra"];
            };
          };

          markdown.enable = true;

          # Languages that are enabled in the maximal configuration.
          bash.enable = true;
          clang.enable = true;
          css.enable = true;
          html.enable = true;
          sql.enable = true;
          java.enable = true;
          kotlin.enable = true;
          typescript = {
            enable = true;
            format = {
              enable = true;
              type = ["prettier"];
            };
          };
          go.enable = true;
          lua.enable = true;
          zig.enable = true;
          python.enable = true;
          typst.enable = true;
          rust = {
            enable = true;
            lsp = {
              enable = true;
              opts = ''
                ["rust-analyzer"] = {
                  checkOnSave = true,
                  check = {
                    command = "clippy",
                  },
                  inlayHints = {
                    closureReturnTypeHints = {
                      enable = "always",
                    },
                    lifetimeElisionHints = {
                      enable = "skip_trivial",
                      useParameterNames = true,
                    },
                  },
                },
              '';
            };
            extensions.crates-nvim.enable = true;
          };

          # Language modules that are not as common.
          assembly.enable = false;
          astro.enable = true;
          nu.enable = false;
          csharp.enable = false;
          julia.enable = false;
          vala.enable = false;
          scala.enable = false;
          r.enable = false;
          gleam.enable = false;
          dart.enable = false;
          ocaml.enable = false;
          elixir.enable = false;
          haskell.enable = false;
          ruby.enable = false;
          fsharp.enable = false;
        };
        visuals = {
          nvim-scrollbar.enable = true;
          nvim-web-devicons.enable = true;
          nvim-cursorline.enable = true;
          cinnamon-nvim.enable = true;
          fidget-nvim.enable = true;

          highlight-undo.enable = true;
          indent-blankline.enable = true;

          # Fun
          cellular-automaton.enable = false;
        };

        statusline = {
          lualine = {
            enable = true;
          };
        };
        theme = {
          enable = true;
          name = "catppuccin";
          style = "mocha";
          transparent = false;
        };
        autopairs.nvim-autopairs.enable = true;

        # nvf provides various autocomplete options. The tried and tested nvim-cmp
        # is enabled in default package, because it does not trigger a build. We
        # enable blink-cmp in maximal because it needs to build its rust fuzzy
        # matcher library.
        autocomplete = {
          nvim-cmp.enable = false;
          blink-cmp.enable = true;
        };
        snippets.luasnip.enable = true;

        filetree = {
          nvimTree = {
            enable = true;
            openOnSetup = false;
          };
          neo-tree = {
            enable = false;
          };
        };

        tabline = {
          nvimBufferline.enable = true;
        };

        treesitter.context.enable = true;

        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
        };

        telescope.enable = true;

        git = {
          enable = true;
          gitsigns.enable = true;
          gitsigns.codeActions.enable = false; # throws an annoying debug message
          neogit.enable = true;
        };
        minimap = {
          minimap-vim.enable = false;
          codewindow.enable = false; # disabled: requires nvim-treesitter.ts_utils which breaks startup
        };
        dashboard = {
          dashboard-nvim.enable = false;
          alpha.enable = true;
        };

        notify = {
          nvim-notify.enable = true;
        };

        projects = {
          project-nvim.enable = true;
        };
        utility = {
          ccc.enable = true;
          diffview-nvim.enable = true;
          yanky-nvim.enable = false;
          icon-picker.enable = true;
          surround.enable = true;
          multicursors.enable = true;
          smart-splits.enable = true;
          undotree.enable = true;
          nvim-biscuits.enable = false;

          motion = {
            hop.enable = true;
            leap.enable = true;
            precognition.enable = true;
          };
          images = {
            image-nvim.enable = false;
            img-clip.enable = true;
          };
        };
        clipboard = {
          enable = true;
          providers.wl-copy.enable = true;
          registers = "unnamedplus";
        };
        notes = {
          obsidian.enable = false; # FIXME: neovim fails to build if obsidian is enabled
          neorg.enable = false;
          orgmode.enable = false;
          mind-nvim.enable = true;
          todo-comments.enable = true;
        };

        terminal = {
          toggleterm = {
            enable = true;
            lazygit.enable = true;
          };
        };

        options = {
          tabstop = 2;
          shiftwidth = 2;
          softtabstop = 2;
          expandtab = true;
          autoindent = true;
          smartindent = false;
        };

        autocmds = [
          {
            event = ["FileType"];
            pattern = ["*"];
            desc = "Disable aggressive indentexpr globally";
            command = "setlocal indentexpr=";
          }
        ];

        luaConfigRC = {
          copilot-inline = ''
            local ok, copilot = pcall(require, "copilot")
            if ok then
              copilot.setup({
                suggestion = {
                  enabled = true,
                  auto_trigger = true,
                  hide_during_completion = false,
                  debounce = 40,
                },
                panel = {
                  enabled = false,
                },
              })

              local sug_ok, suggestion = pcall(require, "copilot.suggestion")
              if sug_ok then
                vim.keymap.set("i", "<C-y>", function()
                  suggestion.accept()
                end, {silent = true, desc = "Copilot Accept"})
                vim.keymap.set("i", "<C-n>", function()
                  suggestion.next()
                end, {silent = true, desc = "Copilot Next"})
                vim.keymap.set("i", "<C-p>", function()
                  suggestion.prev()
                end, {silent = true, desc = "Copilot Prev"})
                vim.keymap.set("i", "<C-e>", function()
                  suggestion.dismiss()
                end, {silent = true, desc = "Copilot Dismiss"})
              end

              vim.api.nvim_set_hl(0, "CopilotSuggestion", {fg = "#7f849c", italic = true})
              vim.api.nvim_set_hl(0, "CopilotAnnotation", {fg = "#6c7086", italic = true})

              vim.api.nvim_create_autocmd({"InsertEnter", "TextChangedI"}, {
                callback = function()
                  pcall(function()
                    suggestion.next()
                  end)
                end,
              })
            end
          '';
        };

        ui = {
          borders.enable = true;
          noice.enable = true;
          colorizer.enable = true;
          modes-nvim.enable = false; # the theme looks terrible with catppuccin
          illuminate.enable = true;
          breadcrumbs = {
            enable = true;
            navbuddy.enable = true;
          };
          smartcolumn = {
            enable = true;
            setupOpts.custom_colorcolumn = {
              # this is a freeform module, it's `buftype = int;` for configuring column position
              nix = "110";
              ruby = "120";
              java = "130";
              go = ["90" "130"];
            };
          };
          fastaction.enable = true;
        };

        assistant = {
          chatgpt.enable = false;
          copilot = {
            enable = true;
            cmp.enable = false;
          };
          codecompanion-nvim.enable = true;
          avante-nvim.enable = false;
        };

        session = {
          nvim-session-manager.enable = false;
        };

        gestures = {
          gesture-nvim.enable = false;
        };

        comments = {
          comment-nvim.enable = true;
        };

        presence = {
          neocord = {
            enable = true;
            setupOpts = {
              logo = "https://cdn.dribbble.com/userupload/19822122/file/original-3ada64eb8b66542028842030018a22ef.png?resize=752x&vertical=center";
              logo_tooltip = "Nvim niehh bOszzz senggol dong";
            };
          };
        };
      };
    };
  };
}
