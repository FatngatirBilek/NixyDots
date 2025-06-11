{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # For LSP
    vtsls
    nodePackages.prettier
  ];
  programs.zed-editor = {
    enable = true;
    installRemoteServer = true;

    extensions = [
      # Language/Tool Support
      "html"
      "superhtml"
      "tera"
      "toml"
      "vue"
      "scss"
      "nix"
      "lua"
      "just"
      "scheme"
      "vento"
      "marksman"
      "svelte"
      "nu"
      "git-firefly"
      "dockerfile"

      "discord-presence"

      # Themes
      "material-icon-theme"
      "catppuccin"
      "tokyo-night"
    ];

    userSettings = lib.mkForce {
      base_keymap = "VSCode";
      theme = "Tokyo Night";
      icon_theme = "Material Icon Theme";
      ui_font_size = 16;
      buffer_font_size = 18;

      buffer_font_family = "JetBrainsMono Nerd Font";

      vim_mode = true;

      relative_line_numbers = true;
      tab_bar = {
        show = true;
      };
      scrollbar = {
        show = "never";
      };
      indent_guides = {
        enabled = true;
        coloring = "indent_aware";
      };
      # NOTE: Zen mode, refer https://github.com/zed-industries/zed/issues/4382 when it's resolved
      centered_layout = {
        left_padding = 0.15;
        right_padding = 0.15;
      };
      # Use Copilot Chat AI as default
      agent = {
        default_model = {
          provider = "copilot_chat";
          model = "claude-3-5-sonnet";
        };
        version = "2";
      };
      language_models = {
        ollama = {
          api_url = "http://localhost:11434";
        };
      };
      # Inlay hints preconfigured by Zed: Go, Rust, Typescript and Svelte
      inlay_hints = {
        enabled = true;
      };
      # LSP
      lsp = {
        tailwindcss-language-server = {
          settings = {
            classAttributes = ["class" "className" "ngClass" "styles"];
          };
        };
        eslint = {
          settings = {
            codeActionOnSave = {
              rules = ["import/order"];
            };
          };
        };

        nixd = {
          settings = {
            diagnostic = {
              suppress = ["sema-extra-with"];
            };
          };
        };
        nil = {
          settings = {
            diagnostics = {
              ignored = ["unused_binding"];
            };
          };
        };
      };

      features = {
        edit_prediction_provider = "zed";
        #inline_completion_provider = "copilot";
      };
      format_on_save = "on";
      languages = {
        TypeScript = {
          # Refer https://github.com/jellydn/ts-inlay-hints for how to setup for Neovim and VSCode
          inlay_hints = {
            enabled = true;
            show_parameter_hints = false;
            show_other_hints = true;
            show_type_hints = true;
          };
        };
        JavaScript = {
          code_actions_on_format = {
            "source.fixAll.eslint" = true;
          };
          formatter = {
            external = {
              command = "prettier";
              arguments = [
                "--stdin-filepath"
                "{buffer_path}"
              ];
            };
          };
        };
        Python = {
          format_on_save = {
            language_server = [
              "ruff"
            ];
          };
          formatter = {
            language_server = [
              "ruff"
            ];
          };
          language_servers = [
            "pyright"
            "ruff"
          ];
        };
        Nix = {
          formatter = {
            external = {
              command = "alejandra";
              arguments = [
                "--quiet"
                "--"
              ];
            };
          };
        };
      };
      terminal = {
        env = {
          EDITOR = "zed --wait";
        };
      };

      # File syntax highlighting
      file_types = {
        Dockerfile = [
          "Dockerfile"
          "Dockerfile.*"
        ];
        "JSON" = [
          "json"
          "jsonc"
          "*.code-snippets"
        ];
      };
      # File scan exclusions, hide on the file explorer and search
      file_scan_exclusions = [
        # "**/.git"
        "**/.svn"
        "**/.hg"
        "**/CVS"
        "**/.DS_Store"
        "**/Thumbs.db"
        "**/.classpath"
        "**/.settings"
        # above is default from Zed
        "**/out"
        # "**/dist"
        "**/.husky"
        "**/.turbo"
        "**/.vscode-test"
        "**/.vscode"
        # "**/.next"
        "**/.storybook"
        "**/.tap"
        "**/.nyc_output"
        "**/report"
        # "**/node_modules"
      ];
      # Turn off telemetry
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
      # Move all panel to the right
      project_panel = {
        button = true;
        dock = "left";
        git_status = true;
      };
      outline_panel = {
        dock = "right";
      };
      collaboration_panel = {
        dock = "right";
      };
      # Move some unnecessary panels to the left
      notification_panel = {
        dock = "right";
      };
      chat_panel = {
        dock = "right";
      };
    };
    userKeymaps = [
      {
        context = "Editor && (vim_mode == normal || vim_mode == visual) && !VimWaiting && !menu";
        bindings = {
          "g f" = "editor::OpenExcerpts";
          "space c p" = "agent::ToggleFocus";
          "space c z" = "workspace::ToggleCenteredLayout";
          "space f p" = "projects::OpenRecent";
          "space g h d" = "editor::ToggleSelectedDiffHunks";
          "space g h r" = "git::Restore";
          "space m P" = "markdown::OpenPreviewToTheSide";
          "space m p" = "markdown::OpenPreview";
          "space s w" = "pane::DeploySearch";
          "space t i" = "editor::ToggleInlayHints";
          "space u w" = "editor::ToggleSoftWrap";
        };
      }
      {
        context = "Editor && vim_mode == normal && !VimWaiting && !menu";
        bindings = {
          "[ d" = "editor::GoToPreviousDiagnostic";
          "[ e" = "editor::GoToPreviousDiagnostic";
          "[ h" = "editor::GoToPreviousHunk";
          "] d" = "editor::GoToDiagnostic";
          "] e" = "editor::GoToDiagnostic";
          "] h" = "editor::GoToHunk";
          "ctrl-h" = "workspace::ActivatePaneLeft";
          "ctrl-j" = "workspace::ActivatePaneDown";
          "ctrl-k" = "workspace::ActivatePaneUp";
          "ctrl-l" = "workspace::ActivatePaneRight";
          "ctrl-q" = "pane::CloseActiveItem";
          "ctrl-s" = "workspace::Save";
          "g D" = "editor::GoToDefinitionSplit";
          "g I" = "editor::GoToImplementationSplit";
          "g T" = "editor::GoToTypeDefinitionSplit";
          "g d" = "editor::GoToDefinition";
          "g i" = "editor::GoToImplementation";
          "g r" = "editor::FindAllReferences";
          "g t" = "editor::GoToTypeDefinition";
          "s S" = "project_symbols::Toggle";
          "s s" = "outline::Toggle";
          "shift-h" = "pane::ActivatePreviousItem";
          "shift-l" = "pane::ActivateNextItem";
          "shift-q" = "pane::CloseActiveItem";
          "space ." = "editor::ToggleCodeActions";
          "space /" = "pane::DeploySearch";
          "space b d" = "pane::CloseActiveItem";
          "space b o" = "pane::CloseInactiveItems";
          "space c a" = "editor::ToggleCodeActions";
          "space c r" = "editor::Rename";
          "space e" = "pane::RevealInProjectPanel";
          "space space" = "file_finder::Toggle";
          "space t h" = "terminal_panel::ToggleFocus";
          "space x x" = "diagnostics::Deploy";
        };
      }
      {
        context = "EmptyPane || SharedScreen || vim_mode == normal";
        bindings = {
          "space f p" = "projects::OpenRecent";
          "space space" = "file_finder::Toggle";
        };
      }
      {
        context = "Editor && vim_mode == visual && !VimWaiting && !menu";
        bindings = {
          "g c" = "editor::ToggleComments";
        };
      }
      {
        context = "Editor && vim_operator == c";
        bindings = {
          "c" = "vim::CurrentLine";
          "r" = "editor::Rename";
        };
      }
      {
        context = "Editor && vim_operator == c";
        bindings = {
          "a" = "editor::ToggleCodeActions";
          "c" = "vim::CurrentLine";
        };
      }
      {
        context = "Terminal";
        bindings = {
          "ctrl-h" = "workspace::ActivatePaneLeft";
          "ctrl-j" = "workspace::ActivatePaneDown";
          "ctrl-k" = "workspace::ActivatePaneUp";
          "ctrl-l" = "workspace::ActivatePaneRight";
        };
      }
      {
        context = "ProjectPanel && not_editing";
        bindings = {
          "A" = "project_panel::NewDirectory";
          "a" = "project_panel::NewFile";
          "c" = "project_panel::Copy";
          "ctrl-h" = "workspace::ActivatePaneLeft";
          "ctrl-j" = "workspace::ActivatePaneDown";
          "ctrl-k" = "workspace::ActivatePaneUp";
          "ctrl-l" = "workspace::ActivatePaneRight";
          "d" = "project_panel::Delete";
          "p" = "project_panel::Paste";
          "q" = "workspace::ToggleRightDock";
          "r" = "project_panel::Rename";
          "space e" = "workspace::ToggleRightDock";
          "x" = "project_panel::Cut";
        };
      }
      {
        context = "Dock";
        bindings = {
          "ctrl-w h" = "workspace::ActivatePaneLeft";
          "ctrl-w j" = "workspace::ActivatePaneDown";
          "ctrl-w k" = "workspace::ActivatePaneUp";
          "ctrl-w l" = "workspace::ActivatePaneRight";
        };
      }
      {
        context = "Workspace";
        bindings = {
          "cmd-b" = "workspace::ToggleRightDock";
        };
      }
      {
        context = "EmptyPane || SharedScreen || vim_mode == normal";
        bindings = {
          "space r t" = ["editor::SpawnNearestTask" {reveal = "no_focus";}];
        };
      }
    ];
  };
}
