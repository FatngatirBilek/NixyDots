{
  lib,
  pkgs,
  inputs,
  ...
}: let
  zedEditorFlakes = inputs.zed-editor-flake.packages.${pkgs.stdenv.hostPlatform.system}.zed-editor-preview-bin;
in {
  home.packages = with pkgs; [
    vtsls
    nodePackages.prettier
    rust-analyzer
    cargo
    rustc
    lldb
    gdb
  ];

  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor;
    installRemoteServer = true;

    extensions = [
      "html"
      "react-typescript-snippets"
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
      "live-server"
      "discord-presence"
      "material-icon-theme"
      "catppuccin"
      "tokyo-night"
    ];

    userSettings = lib.mkForce {
      vim_mode = true;
      # Panels & Docking
      debugger = {
        dock = "bottom";
      };
      agent = {
        dock = "right";
      };
      collaboration_panel = {
        button = false;
        dock = "right";
      };
      outline_panel = {
        button = false;
        dock = "right";
        default_width = 300;
        file_icons = true;
        folder_icons = true;
        git_status = true;
        indent_size = 20;
        auto_reveal_entries = true;
        auto_fold_dirs = true;
        indent_guides = {
          show = "always";
        };
        scrollbar = {
          show = null;
        };
      };
      notification_panel = {
        dock = "right";
      };

      # Appearance
      icon_theme = "Material Icon Theme";
      theme = "Tokyo Night";
      buffer_font_family = "JetBrainsMono Nerd Font";
      buffer_font_size = 16;
      ui_font_size = 17;
      wrap_guides = [
        80
        120
      ];
      soft_wrap = "editor_width";

      # Editor Preferences
      diagnostics_max_severity = "hint";
      inlay_hints = {
        show_type_hints = true;
        show_parameter_hints = true;
        show_other_hints = true;
        show_background = false;
        edit_debounce_ms = 700;
        scroll_debounce_ms = 50;
        toggle_on_modifiers_press = {
          control = true;
        };
        show_value_hints = true;
      };

      # Status Bar
      status_bar = {
        active_language_button = true;
        cursor_position_button = false;
      };

      # Tabs
      tab_bar = {
        show = true;
        show_nav_history_buttons = false;
        show_tab_bar_buttons = false;
      };
      tab_size = 2;
      tabs = {
        close_position = "right";
        file_icons = true;
        git_status = true;
        activate_on_close = "neighbour";
        show_close_button = "hover";
        show_diagnostics = "all";
      };

      # Title Bar
      title_bar = {
        show_branch_icon = true;
        show_branch_name = false;
        show_project_items = false;
        show_onboarding_banner = false;
        show_user_picture = false;
        show_sign_in = true;
        show_menus = false;
      };

      # Toolbar
      toolbar = {
        breadcrumbs = true;
        quick_actions = true;
        selections_menu = true;
        agent_review = true;
      };

      # Minimap
      minimap = {
        show = "never";
        thumb = "always";
        thumb_border = "left_open";
        current_line_highlight = null;
      };

      # Git
      git = {
        git_gutter = "tracked_files";
        inline_blame = {
          enabled = true;
          show_commit_summary = true;
          padding = 7;
        };
        branch_picker = {
          show_author_name = true;
        };
        hunk_style = "unstaged_hollow";
      };

      # Editor
      cursor_blink = true;
      show_whitespaces = "none";
      indent_guides = {
        enabled = true;
        line_width = 1;
        active_line_width = 0;
        coloring = "indent_aware";
        background_coloring = "disabled";
      };

      # Project Panel / Explorer
      project_panel = {
        button = true;
        dock = "left";
        default_width = 240;
        folder_icons = false;
        indent_size = 20;
        auto_fold_dirs = false;
        drag_and_drop = true;
        git_status = true;
        auto_reveal_entries = true;
        entry_spacing = "comfortable";
        starts_open = true;
        scrollbar = {
          show = null;
        };
        indent_guides = {
          show = "always";
        };
      };

      # Scrollbar
      scrollbar = {
        show = "never";
        cursors = true;
      };

      # File types
      file_types = {
        css = ["*.css"];
        json = [".prettierrc"];
        dotenv = [".env.*"];
        Dockerfile = [
          "Dockerfile"
          "Dockerfile.*"
        ];
        JSON = [
          "json"
          "jsonc"
          "*.code-snippets"
        ];
      };

      # File scan exclusions
      file_scan_exclusions = [
        "**/.svn"
        "**/.hg"
        "**/CVS"
        "**/.DS_Store"
        "**/Thumbs.db"
        "**/.classpath"
        "**/.settings"
        "**/out"
        "**/.husky"
        "**/.turbo"
        "**/.vscode-test"
        "**/.vscode"
        "**/.storybook"
        "**/.tap"
        "**/.nyc_output"
        "**/report"
      ];

      # Telemetry
      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      # Edit Predictions
      edit_predictions = {
        mode = "subtle";
        copilot = {
          proxy = null;
          proxy_no_verify = null;
          enterprise_uri = null;
        };
        enabled_in_text_threads = false;
      };

      # Agent config
      agent = {
        default_model = {
          provider = "copilot_chat";
          model = "gpt-4.1";
        };
      };

      # Language Models
      language_models = {
        ollama = {
          api_url = "http://localhost:11434";
        };
      };

      # LSP
      lsp = {
        tailwindcss-language-server = {
          settings = {
            classAttributes = [
              "class"
              "className"
              "ngClass"
              "styles"
            ];
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

        rust-analyzer = {
          binary = {
            # Optionally force Zed to use this binary only:
            # ignore_system_version = true;
            # path = "${pkgs.rust-analyzer}/bin/rust-analyzer";
            # arguments = [];
          };
          initialization_options = {
            inlayHints = {
              maxLength = null;
              lifetimeElisionHints = {
                enable = "skip_trivial";
                useParameterNames = true;
              };
              closureReturnTypeHints = {
                enable = "always";
              };
            };
            rust = {
              analyzerTargetDir = true;
            };
          };
          enable_lsp_tasks = true;
        };
      };

      # Features
      features = {
        edit_prediction_provider = "copilot";
      };

      format_on_save = "on";

      # Languages
      languages = {
        TypeScript = {
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
          "space b o" = "pane::CloseOtherItems";
          "space c a" = "editor::ToggleCodeActions";
          "space c r" = "editor::Rename";
          "space e" = "pane::RevealInProjectPanel";
          "space space" = "file_finder::Toggle";
          "space t h" = "terminal_panel::Toggle";
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
          "space r t" = [
            "editor::SpawnNearestTask"
            {reveal = "no_focus";}
          ];
        };
      }
    ];
  };
}
