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
            package = pkgs.vimPlugins.codesnap-nvim.overrideAttrs (old: {
              postPatch = ''
                ${old.postPatch or ""}
                substituteInPlace lua/codesnap/init.lua \
                  --replace-fail 'string.match(static.config.save_path,' 'string.match(save_path,' \
                  --replace-fail 'require("generator").save_snapshot(config)' 'generator.save(save_path, config_module.get_config())' \
                  --replace-fail 'vim.notify("Save snapshot in " .. config.save_path .. " successfully")' 'vim.cmd("delmarks <>"); vim.notify("Save snapshot in " .. save_path .. " successfully")'
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
