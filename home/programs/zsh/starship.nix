{lib, ...}: let
  accent = "#cba6f7";
  background-alt = "#1b1b1b";
in {
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;

      "$schema" = "https://starship.rs/config-schema.json";
      palette = "catppuccin_mocha";
      format = lib.concatStrings [
        "[](mauve)"
        "$os"
        "$username"
        "[](bg:pink fg:mauve)"
        "$directory"
        "[](bg:lavender fg:pink)"
        "$git_branch"
        "$git_status"
        "[](fg:lavender bg:blue)"
        "$c"
        "$rust"
        "$golang"
        "$nodejs"
        "$php"
        "$java"
        "$kotlin"
        "$haskell"
        "$python"
        "[](fg:blue bg:sapphire)"
        "[](fg:sapphire)"
        "$line_break"
        "$character"
      ];

      right_format = lib.concatStrings [
        "$cmd_duration"
        "$line_break"
        "[](fg:lavender)"
        "$time"
        "[](fg:lavender)"
      ];

      os = {
        disabled = false;
        style = "bg:mauve fg:crust";
        symbols = {
          Windows = "";
          Ubuntu = "󰕈";
          SUSE = "";
          Raspbian = "󰐿";
          Mint = "󰣭";
          Macos = "󰀵";
          Manjaro = "";
          Linux = "󰌽";
          Gentoo = "󰣨";
          Fedora = "󰣛";
          Alpine = "";
          Amazon = "";
          Android = "";
          AOSC = "";
          Arch = "󰣇";
          Artix = "󰣇";
          CentOS = "";
          Debian = "󰣚";
          Redhat = "󱄛";
          RedHatEnterprise = "󱄛";
          NixOS = "";
        };
      };

      username = {
        show_always = true;
        style_user = "bg:mauve fg:crust";
        style_root = "bg:mauve fg:crust";
        format = "[ $user]($style)";
      };

      directory = {
        style = "bg:pink fg:crust";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        substitutions = {
          Documents = "󰈙 ";
          Downloads = " ";
          Music = "󰝚 ";
          Pictures = " ";
          Developer = "󰲋 ";
        };
      };

      git_branch = {
        symbol = "";
        style = "bg:lavender";
        format = "[[ $symbol $branch ](fg:crust bg:lavender)]($style)";
      };

      git_status = {
        style = "bg:lavender";
        format = "[[($all_status$ahead_behind )](fg:crust bg:lavender)]($style)";
      };

      nodejs = {
        symbol = "";
        style = "bg:blue";
        format = "[[ $symbol( $version) ](fg:crust bg:blue)]($style)";
      };

      c = {
        symbol = " ";
        style = "bg:blue";
        format = "[[ $symbol( $version) ](fg:crust bg:blue)]($style)";
      };

      rust = {
        symbol = "";
        style = "bg:blue";
        format = "[[ $symbol( $version) ](fg:crust bg:blue)]($style)";
      };

      golang = {
        symbol = "";
        style = "bg:blue";
        format = "[[ $symbol( $version) ](fg:crust bg:blue)]($style)";
      };

      php = {
        symbol = "";
        style = "bg:blue";
        format = "[[ $symbol( $version) ](fg:crust bg:blue)]($style)";
      };

      java = {
        symbol = " ";
        style = "bg:blue";
        format = "[[ $symbol( $version) ](fg:crust bg:blue)]($style)";
      };

      kotlin = {
        symbol = "";
        style = "bg:blue";
        format = "[[ $symbol( $version) ](fg:crust bg:blue)]($style)";
      };

      haskell = {
        symbol = "";
        style = "bg:blue";
        format = "[[ $symbol( $version) ](fg:crust bg:blue)]($style)";
      };

      python = {
        symbol = "";
        style = "bg:blue";
        format = "[[ $symbol( $version)(\\(#$virtualenv\\)) ](fg:crust bg:blue)]($style)";
      };

      docker_context = {
        symbol = "";
        style = "bg:sapphire";
        format = "[[ $symbol( $context) ](fg:crust bg:sapphire)]($style)";
      };

      conda = {
        symbol = "  ";
        style = "fg:crust bg:sapphire";
        format = "[$symbol$environment ]($style)";
        ignore_base = false;
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:lavender";
        format = "[[  $time ](fg:crust bg:lavender)]($style)";
      };

      line_break = {
        disabled = true;
      };

      character = {
        disabled = false;
        success_symbol = "[❯](bold fg:green)";
        error_symbol = "[❯](bold fg:red)";
        vimcmd_symbol = "[❮](bold fg:green)";
        vimcmd_replace_one_symbol = "[❮](bold fg:lavender)";
        vimcmd_replace_symbol = "[❮](bold fg:lavender)";
        vimcmd_visual_symbol = "[❮](bold fg:yellow)";
      };

      cmd_duration = {
        show_milliseconds = true;
        format = " in $duration ";
        style = "bg:lavender";
        disabled = false;
        show_notifications = true;
        min_time_to_notify = 45000;
      };

      palettes = {
        catppuccin_mocha = {
          rosewater = "#f5e0dc";
          flamingo = "#f2cdcd";
          pink = "#f5c2e7";
          mauve = "#cba6f7";
          red = "#f38ba8";
          maroon = "#eba0ac";
          peach = "#fab387";
          yellow = "#f9e2af";
          green = "#a6e3a1";
          teal = "#94e2d5";
          sky = "#89dceb";
          sapphire = "#74c7ec";
          blue = "#89b4fa";
          lavender = "#b4befe";
          text = "#cdd6f4";
          subtext1 = "#bac2de";
          subtext0 = "#a6adc8";
          overlay2 = "#9399b2";
          overlay1 = "#7f849c";
          overlay0 = "#6c7086";
          surface2 = "#585b70";
          surface1 = "#45475a";
          surface0 = "#313244";
          base = "#1e1e2e";
          mantle = "#181825";
          crust = "#11111b";
        };
      };
    };
  };
}
