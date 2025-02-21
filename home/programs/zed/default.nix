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

      "wakatime"
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
      assistant = {
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
          # Git
          "space g h d" = "editor::ToggleSelectedDiffHunks";
          "space g h r" = "editor::RevertSelectedHunks";

          # Toggle inlay hints
          "space t i" = "editor::ToggleInlayHints";

          # Toggle soft wrap
          "space u w" = "editor::ToggleSoftWrap";

          # NOTE: Toggle Zen mode, not fully working yet
          "space c z" = "workspace::ToggleCenteredLayout";

          # Open markdown preview
          "space m p" = "markdown::OpenPreview";
          "space m P" = "markdown::OpenPreviewToTheSide";

          # Open recent project
          "space f p" = "projects::OpenRecent";

          # Search word under cursor
          "space s w" = "pane::DeploySearch";

          # Chat with AI
          "space c p" = "assistant::ToggleFocus";

          # Go to file with `gf`
          "g f" = "editor::OpenExcerpts";
        };
      }
      {
        context = "Editor && vim_mode == normal && !VimWaiting && !menu";
        bindings = {
          # Window movement bindings
          "ctrl-h" = ["workspace::ActivatePaneInDirection" "Left"];
          "ctrl-l" = ["workspace::ActivatePaneInDirection" "Right"];
          "ctrl-k" = ["workspace::ActivatePaneInDirection" "Up"];
          "ctrl-j" = ["workspace::ActivatePaneInDirection" "Down"];

          # +LSP
          "space c a" = "editor::ToggleCodeActions";
          "space ." = "editor::ToggleCodeActions";
          "space c r" = "editor::Rename";
          "g d" = "editor::GoToDefinition";
          "g D" = "editor::GoToDefinitionSplit";
          "g i" = "editor::GoToImplementation";
          "g I" = "editor::GoToImplementationSplit";
          "g t" = "editor::GoToTypeDefinition";
          "g T" = "editor::GoToTypeDefinitionSplit";
          "g r" = "editor::FindAllReferences";
          "] d" = "editor::GoToDiagnostic";
          "[ d" = "editor::GoToPrevDiagnostic";
          "] e" = "editor::GoToDiagnostic";
          "[ e" = "editor::GoToPrevDiagnostic";

          # Symbol search
          "s s" = "outline::Toggle";
          "s S" = "project_symbols::Toggle";

          # Diagnostic
          "space x x" = "diagnostics::Deploy";

          # +Git
          "] h" = "editor::GoToHunk";
          "[ h" = "editor::GoToPrevHunk";

          # + Buffers
          "shift-h" = "pane::ActivatePrevItem";
          "shift-l" = "pane::ActivateNextItem";
          "shift-q" = "pane::CloseActiveItem";
          "ctrl-q" = "pane::CloseActiveItem";
          "space b d" = "pane::CloseActiveItem";
          "space b o" = "pane::CloseInactiveItems";

          # Save file
          "ctrl-s" = "workspace::Save";

          # File finder
          "space space" = "file_finder::Toggle";

          # Project search
          "space /" = "pane::DeploySearch";

          # Show project panel with current file
          "space e" = "pane::RevealInProjectPanel";

          # term
          "space t h" = "terminal_panel::ToggleFocus";
        };
      }
      {
        context = "EmptyPane || SharedScreen || vim_mode == normal";
        bindings = {
          "space space" = "file_finder::Toggle";
          "space f p" = "projects::OpenRecent";
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
          "c" = "vim::CurrentLine";
          "a" = "editor::ToggleCodeActions";
        };
      }
      {
        context = "Terminal";
        bindings = {
          "ctrl-h" = ["workspace::ActivatePaneInDirection" "Left"];
          "ctrl-l" = ["workspace::ActivatePaneInDirection" "Right"];
          "ctrl-k" = ["workspace::ActivatePaneInDirection" "Up"];
          "ctrl-j" = ["workspace::ActivatePaneInDirection" "Down"];
        };
      }
      {
        context = "ProjectPanel && not_editing";
        bindings = {
          "a" = "project_panel::NewFile";
          "A" = "project_panel::NewDirectory";
          "r" = "project_panel::Rename";
          "d" = "project_panel::Delete";
          "x" = "project_panel::Cut";
          "c" = "project_panel::Copy";
          "p" = "project_panel::Paste";
          "q" = "workspace::ToggleRightDock";
          "space e" = "workspace::ToggleRightDock";
          "ctrl-h" = ["workspace::ActivatePaneInDirection" "Left"];
          "ctrl-l" = ["workspace::ActivatePaneInDirection" "Right"];
          "ctrl-k" = ["workspace::ActivatePaneInDirection" "Up"];
          "ctrl-j" = ["workspace::ActivatePaneInDirection" "Down"];
        };
      }
      {
        context = "Dock";
        bindings = {
          "ctrl-w h" = ["workspace::ActivatePaneInDirection" "Left"];
          "ctrl-w l" = ["workspace::ActivatePaneInDirection" "Right"];
          "ctrl-w k" = ["workspace::ActivatePaneInDirection" "Up"];
          "ctrl-w j" = ["workspace::ActivatePaneInDirection" "Down"];
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
